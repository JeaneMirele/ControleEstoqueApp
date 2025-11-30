import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; // <--- Necessário para usar Colors.red
import 'dart:io';

class PushNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Inicializa
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  // Busca por Família
  Future<void> verificarValidadePorFamilia(String familyId) async {
    if (familyId.isEmpty) return;

    print("🔔 [PushNotification] Buscando produtos para família: $familyId");

    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final fimAmanha = DateTime(agora.year, agora.month, agora.day + 2)
        .subtract(const Duration(milliseconds: 1));

    try {
      final snapshot = await _firestore
          .collection('estoque')
          .where('familyId', isEqualTo: familyId)
          .where('validade', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoje))
          .where('validade', isLessThanOrEqualTo: Timestamp.fromDate(fimAmanha))
          .get();

      if (snapshot.docs.isEmpty) {
        print("✅ Nenhum produto vencendo encontrado.");
        return;
      }

      print("⚠️ Encontrados ${snapshot.docs.length} produtos vencendo.");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] ?? 'Produto';

        final validadeTimestamp = data['validade'] as Timestamp;
        final validade = validadeTimestamp.toDate();

        // Pequena correção na lógica de dias para ser mais precisa (zerando horas)
        final dataValidadeZerada = DateTime(validade.year, validade.month, validade.day);
        final diferenca = dataValidadeZerada.difference(inicioHoje).inDays;

        final textoQuando = diferenca < 0 ? "VENCEU!" : (diferenca == 0 ? "Vence HOJE!" : "Vence AMANHÃ!");

        await _showNotification(
          id: doc.id.hashCode,
          title: "Validade Próxima: $nome",
          body: "$textoQuando Verifique seu estoque.",
        );
      }
    } catch (e) {
      // DICA IMPORTANTE: O erro de índice aparecerá aqui na primeira vez
      print("❌ Erro ao buscar validares no Firebase: $e");
    }
  }

  Future<void> _showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_validade_id',
      'Alertas de Validade',
      channelDescription: 'Notifica sobre produtos vencendo',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.red, // <--- CORRIGIDO: Adicionei uma cor aqui
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id,
      title,
      body,
      details,
    );
  }
}