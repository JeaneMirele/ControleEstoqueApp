import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:controle_estoque_app/models/app_user.dart';

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

    final newFamilyId = user.uid; 
    
    await userDocRef.set({
      'email': user.email,
      'familyId': newFamilyId,
      'name': user.displayName ?? user.email?.split('@')[0] ?? 'Usuário',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return newFamilyId;
  }


  Future<void> createUserProfile(User user, {String? familyId}) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    

    final finalFamilyId = (familyId != null && familyId.isNotEmpty) ? familyId : user.uid;

    await userDocRef.set({
      'email': user.email,
      'familyId': finalFamilyId,
      'name': user.displayName ?? user.email?.split('@')[0] ?? 'Usuário',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> joinFamily(String userId, String familyId) async {

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

  Stream<List<AppUser>> getFamilyMembersStream(String familyId) {
    return _firestore.collection('users')
      .where('familyId', isEqualTo: familyId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }
}
