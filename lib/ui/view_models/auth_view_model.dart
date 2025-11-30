import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notifications_service.dart';
import '../../data/services/user_service.dart';
import '../../models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final PushNotificationService _notificationService;
  final UserService _userService;

  User? _usuario;
  User? get usuario => _usuario;

  String? _familyId;
  String? get familyId => _familyId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthViewModel(this._authService, this._notificationService, this._userService) {
    _monitorarStatusAuth();
  }

  void _monitorarStatusAuth() {
    _authService.authStateChanges.listen((user) async {
      _usuario = user;

      if (user != null) {
        // 1. Busca o ID da família
        _familyId = await _userService.getOrCreateFamilyId(user);

        // 2. Inicializa o serviço de notificações
        await _notificationService.initialize();

        // 3. Verifica se tem produtos vencendo na família
        if (_familyId != null) {
          _notificationService.verificarValidadePorFamilia(_familyId!);
        }
      } else {
        _familyId = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> cadastrar(String email, String password, {String? familyId}) async {
    await _authService.signUp(email: email, password: password);

    if (_authService.currentUser != null) {
      await _userService.createUserProfile(_authService.currentUser!, familyId: familyId);

      if (familyId != null) {
        _familyId = familyId;
      }
    }
  }

  Future<void> sair() async {
    await _authService.signOut();
  }

  Future<void> entrarEmFamilia(String novoIdFamilia) async {
    if (_usuario == null) return;

    try {
      await _userService.joinFamily(_usuario!.uid, novoIdFamilia);
      _familyId = novoIdFamilia;

      // CORREÇÃO: Passamos apenas o novoIdFamilia, pois o serviço já sabe o que fazer
      _notificationService.verificarValidadePorFamilia(novoIdFamilia);

      notifyListeners();
    } catch (e) {
      print("Erro ao entrar na família: $e");
      rethrow;
    }
  }

  Stream<List<AppUser>> getFamilyMembers() {
    if (_familyId == null) return Stream.value([]);
    return _userService.getFamilyMembersStream(_familyId!);
  }
}