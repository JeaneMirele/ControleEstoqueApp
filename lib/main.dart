import 'package:controle_estoque_app/ui/views/estoque_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import para o teste
import 'firebase_options.dart';
import 'core/di/configure_providers.dart';
import 'ui/views/shopping_list_page.dart'; // MUDANÇA: Importa a tela da lista de compras

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- INÍCIO: Teste Rápido de Conexão com o Firebase ---
  try {
    print("--- INICIANDO TESTE DE CONEXÃO COM FIREBASE ---");
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection("test_connection").doc("test_doc");
    await docRef.set({
      'timestamp': FieldValue.serverTimestamp(),
      'test_message': 'Se você vê isso no Firestore, a conexão está funcionando!'
    });
    print("--- SUCESSO! A escrita no Firestore funcionou. ---");
  } catch (e) {
    print("--- FALHA NA CONEXÃO! Erro ao escrever no Firestore: $e ---");
  }
  // --- FIM: Teste Rápido de Conexão com o Firebase ---

  final data = await ConfigureProviders.createDependencyTree();

  runApp(
    MultiProvider(
      providers: data.providers,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Controle de Estoque',
        // MUDANÇA: A tela inicial agora é a Lista de Compras, que está dentro do escopo do Provider.
        home: EstoquePage(),
      ),
    ),
  );
}
