import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notifications_service.dart';


class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final PushNotificationService _notificationService; // <--- Novo campo

  User? _usuario;
  User? get usuario => _usuario;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Atualize o construtor para pedir o NotificationService
  AuthViewModel(this._authService, this._notificationService) {
    _monitorarStatusAuth();
  }

  void _monitorarStatusAuth() {
    _authService.authStateChanges.listen((user) {
      _usuario = user;
      _isLoading = false;

      // --- AUTOMATIZAÇÃO ---
      // Se detectamos um usuário logado, já inicializamos as notificações
      // e salvamos o token no Firestore automaticamente.
      if (user != null) {
        print("Usuário logado (${user.email}). Inicializando notificações...");
        _notificationService.initialize(user.uid);
      }

      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> cadastrar(String email, String password) async {
    await _authService.signUp(email: email, password: password);
  }

  Future<void> sair() async {
    await _authService.signOut();
  }
}