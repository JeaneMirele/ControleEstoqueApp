import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/di/configure_providers.dart';
import 'ui/views/estoque_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final data = await ConfigureProviders.createDependencyTree();

  runApp(
    MultiProvider(
      providers: data.providers,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Controle de Estoque',
        home: EstoquePage(),
      ),
    ),
  );
}