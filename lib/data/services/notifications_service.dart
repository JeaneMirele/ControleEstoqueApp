import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class PushNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _currentUserId;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher'); 

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    // Solicita permissão para Android 13+ (API 33 ou superior)
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  Future<void> verificarValidadeFirebase() async {
    // Tenta usar o ID passado na inicialização ou pega o atual
    final uid = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
    
    if (uid == null) return;

    print("🔥 Consultando Firebase Firestore direto do App...");

    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final fimAmanha = DateTime(agora.year, agora.month, agora.day + 2)
        .subtract(const Duration(milliseconds: 1));

    try {
      // Busca por data de validade
      // Nota: Se os produtos agora são salvos por familyId, pode ser necessário ajustar aqui no futuro.
      // Mas por enquanto, mantemos a busca por userId para garantir compatibilidade ou ajustar conforme a necessidade.
      // Se o usuário não ver notificações, pode ser porque os produtos estão com familyId mas a busca é por userId.
      // Vamos tentar buscar pelo userId primeiro.
      
      final snapshot = await _firestore
          .collection('estoque')
          .where('userId', isEqualTo: uid)
          .where('validade', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoje))
          .where('validade', isLessThanOrEqualTo: Timestamp.fromDate(fimAmanha))
          .get();

      print("📦 Produtos encontrados no Firebase: ${snapshot.docs.length}");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] ?? 'Produto sem nome';

        await _showNotification(
          "Vencimento Próximo! ⚠️",
          "O item '$nome' vence hoje ou amanhã!",
        );
      }
    } catch (e) {
      print("❌ Erro ao buscar no Firebase: $e");
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_validade_id',
      'Alertas de Validade',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
