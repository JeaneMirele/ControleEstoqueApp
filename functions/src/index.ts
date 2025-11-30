import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
    admin.initializeApp();
}

// --- Função 1: Notificação de Validade (Roda todo dia às 09:00) ---
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
                .collection('estoque')
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

                if (!userId) {
                    console.log(`⚠️ Produto ${docProduto.id} sem userId. Ignorando.`);
                    return;
                }

                // 1. Enviar Notificação (se o usuário tiver token)
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

                // 2. Adicionar à Lista de Compras
                const jaNaLista = await admin.firestore()
                    .collection('shopping_list')
                    .where('userId', '==', userId)
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

// --- Função 2: Monitoramento de Estoque em Tempo Real ---
export const verificarEstoqueBaixo = functions.firestore
    .document('estoque/{produtoId}')
    .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
        // Lógica desativada para evitar duplicidade. 
        // O gerenciamento da lista de compras (Adicionar/Remover) agora é feito diretamente 
        // pelo App (Client-side) no arquivo 'estoque_view_model.dart' para garantir resposta imediata.
        
        console.log("ℹ️ Mudança no estoque detectada. O gerenciamento da lista agora é responsabilidade do App.");
        return null;
    });
