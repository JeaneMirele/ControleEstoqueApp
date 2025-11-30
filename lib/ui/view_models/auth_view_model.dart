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
        print("Usuário logado (${user.email}). Inicializando serviços...");
        

        _familyId = await _userService.getOrCreateFamilyId(user);
        
        _notificationService.initialize(user.uid);
        _notificationService.verificarValidadeFirebase();

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
    
    // Se o cadastro for bem sucedido e tivermos um usuário, cria o perfil (com ou sem família vinculada)
    if (_authService.currentUser != null) {
       await _userService.createUserProfile(_authService.currentUser!, familyId: familyId);
       // Atualiza o ID localmente para refletir a mudança imediatamente se necessário
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
