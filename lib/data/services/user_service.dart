import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getOrCreateFamilyId(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['familyId'] != null) {
        return userData['familyId'];
      }
    }

    // Se não tem família, cria uma nova (usando o próprio UID como ID da família inicialmente)
    // Ou gera um ID único novo
    final newFamilyId = user.uid; 
    
    await userDocRef.set({
      'email': user.email,
      'familyId': newFamilyId,
      'name': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return newFamilyId;
  }

  Future<void> joinFamily(String userId, String familyId) async {
    // Verifica se a família existe (opcional, depende da regra de negócio. 
    // Se família for apenas um ID compartilhado, não precisa validar tabela 'families')
    
    await _firestore.collection('users').doc(userId).update({
      'familyId': familyId,
    });
  }
  
  Future<AppUser?> getUser(String userId) async {
     final doc = await _firestore.collection('users').doc(userId).get();
     if (doc.exists) {
       return AppUser.fromFirestore(doc);
     }
     return null;
  }
}
