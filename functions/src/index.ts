import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";


if (!admin.apps.length) {
    admin.initializeApp();
}


export const verificarValidadeProdutos = functions.pubsub
    .schedule('every day 09:00')
    .timeZone('America/Sao_Paulo')
    .onRun(async (context) => {


        const hoje = new Date();


        const inicioDoDia = new Date(hoje);
        inicioDoDia.setHours(0, 0, 0, 0);


        const fimDoDia = new Date(hoje);
        fimDoDia.setDate(hoje.getDate() + 1);
        fimDoDia.setHours(23, 59, 59, 999);

        console.log(`🔎 MODO TESTE: Buscando produtos vencendo entre ${inicioDoDia.toISOString()} e ${fimDoDia.toISOString()}`);

        try {
            const snapshot = await admin.firestore()
                .collection('estoque')
                .where('validade', '>=', inicioDoDia)
                .where('validade', '<=', fimDoDia)
                .get();

            if (snapshot.empty) {
                console.log('✅ Nenhum produto vencendo hoje ou amanhã.');
                return null;
            }

            console.log(`⚠️ Encontrados ${snapshot.size} produtos para processar.`);

            const promessas = snapshot.docs.map(async (docProduto) => {
                const produto = docProduto.data();
                const userId = produto.userId;
                const familyId = produto.familyId;
                const qtd = Number(produto.quantidade);

                if (!qtd || qtd <= 0) return;
                if (!userId) {
                    console.log(`⚠️ Produto ${docProduto.id} sem userId. Ignorando.`);
                    return;
                }


                const dataValidade = (produto.validade && typeof produto.validade.toDate === 'function')
                    ? produto.validade.toDate()
                    : new Date(produto.validade);

                const diffTempo = dataValidade.getTime() - hoje.getTime();
                const diasRestantes = Math.ceil(diffTempo / (1000 * 3600 * 24));
                const textoDias = diasRestantes <= 0 ? "HOJE" : "AMANHÃ";


                const userDoc = await admin.firestore().collection('users').doc(userId).get();
                const userData = userDoc.data();
                const fcmToken = userData?.fcmToken;

                if (fcmToken) {
                    const message = {
                        notification: {
                            title: "Produto Vencendo! ⚠️",
                            body: `Atenção: Seu item "${produto.nome}" vence ${textoDias}. Adicionamos à lista!`
                        },
                        token: fcmToken
                    };
                    await admin.messaging().send(message).catch(e => console.error(`Erro notificação:`, e));
                }


                let query = admin.firestore().collection('shopping_list');

                if (familyId) {
                    query = query.where('familyId', '==', familyId);
                } else {
                    query = query.where('userId', '==', userId);
                }

                const jaNaLista = await query
                    .where('nome', '==', produto.nome)
                    .where('isAutomatic', '==', true)
                    .limit(1)
                    .get();

                if (jaNaLista.empty) {
                    const itemToAdd: any = {
                        nome: produto.nome,
                        quantidade: "1",
                        categoria: produto.categoria || "Geral",
                        isChecked: false,
                        isAutomatic: true,
                        prioridade: true,
                        userId: userId,
                        criadoEm: admin.firestore.FieldValue.serverTimestamp()
                    };

                    if (familyId) {
                        itemToAdd.familyId = familyId;
                    }

                    await admin.firestore().collection('shopping_list').add(itemToAdd);
                }
            });

            await Promise.all(promessas);

        } catch (error) {
            console.error("❌ Erro fatal na função:", error);
        }
        return null;
    });

exports.verificarEstoqueBaixo = functions.firestore
    .document('estoque/{produtoId}')
    .onWrite(async (change, context) => {
    console.log("ℹ️ Mudança no estoque detectada. O gerenciamento da lista agora é responsabilidade do App.");
    return null;
});
