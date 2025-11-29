import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/di/configure_providers.dart';
import 'ui/views/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  final data = await ConfigureProviders.createDependencyTree();


  runApp(MyApp(providers: data.providers));
}

class MyApp extends StatelessWidget {
  final List<SingleChildWidget> providers;

  const MyApp({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'Controle de Estoque',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}