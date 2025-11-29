import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";


if (!admin.apps.length) {
    admin.initializeApp();
}


export const verificarValidadeProdutos = functions.pubsub
    .schedule('every day 09:00')
    .timeZone('America/Sao_Paulo')
    .onRun(async () => {

        const DIAS_PARA_AVISAR = 5;
        const hoje = new Date();

        const dataAlvo = new Date();
        dataAlvo.setDate(hoje.getDate() + DIAS_PARA_AVISAR);

        const inicioDoDia = new Date(dataAlvo);
        inicioDoDia.setHours(0, 0, 0, 0);

        const fimDoDia = new Date(dataAlvo);
        fimDoDia.setHours(23, 59, 59, 999);

        console.log(`🔎 Buscando produtos vencendo entre ${inicioDoDia.toISOString()} e ${fimDoDia.toISOString()}`);

        try {
            const snapshot = await admin.firestore()
                .collection('produtos')
                .where('validade', '>=', inicioDoDia)
                .where('validade', '<=', fimDoDia)
                .get();

            if (snapshot.empty) {
                console.log('✅ Nenhum produto vencendo nesta data.');
                return null;
            }

            console.log(`⚠️ Encontrados ${snapshot.size} produtos para processar.`);

            const promessas = snapshot.docs.map(async (docProduto) => {
                const produto = docProduto.data();
                const userId = produto.userId;

                const qtd = Number(produto.quantidade);
                if (!qtd || qtd <= 0) return;


                if (userId) {
                    const userDoc = await admin.firestore().collection('users').doc(userId).get();
                    const fcmToken = userDoc.data()?.fcmToken;

                    if (fcmToken) {
                        const message = {
                            notification: {
                                title: "Produto Vencendo! ⚠️",
                                body: `Seu item "${produto.nome}" vence em ${DIAS_PARA_AVISAR} dias. Adicionamos à lista de compras!`
                            },
                            token: fcmToken
                        };
                        await admin.messaging().send(message).catch(e => console.error(`Erro notificação:`, e));
                    }
                }


                const jaNaLista = await admin.firestore()
                    .collection('shopping_list')
                    .where('nome', '==', produto.nome)
                    .where('isAutomatic', '==', true)
                    .limit(1)
                    .get();

                if (jaNaLista.empty) {
                    await admin.firestore().collection('shopping_list').add({
                        nome: produto.nome,
                        quantidade: "1",
                        categoria: produto.categoria || "Geral",
                        isChecked: false,
                        isAutomatic: true,
                        prioridade: true,
                        userId: userId,
                        criadoEm: admin.firestore.FieldValue.serverTimestamp()
                    });
                }
            });

            await Promise.all(promessas);

        } catch (error) {
            console.error("❌ Erro fatal na função:", error);
        }

        return null;
    });


export const verificarEstoqueBaixo = functions.firestore
    .document('produtos/{produtoId}')
    .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {


        if (!change.after.exists) return null;

        const dadosNovos = change.after.data();
        if (!dadosNovos) return null;

        const nomeProduto = dadosNovos.nome;
        const userId = dadosNovos.userId;
        const qtdAtual = Number(dadosNovos.quantidade);


        if (qtdAtual <= 1) {
            console.log(`📉 Estoque baixo detectado para: ${nomeProduto} (Qtd: ${qtdAtual})`);

            const querySnapshot = await admin.firestore()
                .collection('shopping_list')
                .where('nome', '==', nomeProduto)
                .where('isAutomatic', '==', true)
                .where('isChecked', '==', false)
                .get();

            if (!querySnapshot.empty) {
                console.log(`✋ ${nomeProduto} já está na lista.`);
                return null;
            }

            await admin.firestore().collection('shopping_list').add({
                nome: nomeProduto,
                quantidade: "1",
                categoria: dadosNovos.categoria || "Geral",
                isChecked: false,
                isAutomatic: true,
                prioridade: true,
                userId: userId,
                criadoEm: admin.firestore.FieldValue.serverTimestamp()
            });

            console.log(`✅ ${nomeProduto} adicionado à lista automaticamente!`);
        }

        return null;
    });