import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String? familyId;
  final String? name;

  AppUser({
    required this.id,
    required this.email,
    this.familyId,
    this.name,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      familyId: data['familyId'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'familyId': familyId,
      'name': name,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? familyId,
    String? name,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
    );
  }
}
