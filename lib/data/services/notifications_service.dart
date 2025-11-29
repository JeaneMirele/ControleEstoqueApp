import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize(String userId) async {

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissão concedida');


      String? token = await _fcm.getToken();
      print("Token do dispositivo: $token");


      if (token != null) {
        await _saveTokenToDatabase(token, userId);
      }
    }
  }

  Future<void> _saveTokenToDatabase(String token, String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'fcmToken': token,
      'platform': Platform.operatingSystem,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}