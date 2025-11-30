import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shopping_list_item.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ShoppingListRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ShoppingListRepository(this._firestoreService);

  Stream<List<ShoppingListItem>> getShoppingList({String? userId, String? familyId}) {
    
    // Se não passar ID, tenta pegar do user atual (compatibilidade)
    final currentUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;

    return _firestoreService.getCollectionStream(
      'shopping_list',
      queryBuilder: (query) {
        var q = query.orderBy('criadoEm', descending: true);
        
        if (familyId != null && familyId.isNotEmpty) {
           return q.where('familyId', isEqualTo: familyId);
        } else if (currentUserId != null) {
           return q.where('userId', isEqualTo: currentUserId);
        }
        return q;
      },
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ShoppingListItem.fromMap(data, doc.id);
      }).toList();
    });
  }

  Future<void> addItem(ShoppingListItem item) async {
    final userId = item.userId ?? FirebaseAuth.instance.currentUser?.uid;

    if (userId == null && item.familyId == null) return;

    final nomeNormalizado = item.nome.trim();


    Query query = _db.collection('shopping_list');
    
    if (item.familyId != null && item.familyId!.isNotEmpty) {
      query = query.where('familyId', isEqualTo: item.familyId);
    } else {
      query = query.where('userId', isEqualTo: userId);
    }
    
    query = query.where('nome', isEqualTo: nomeNormalizado).limit(1);
        
    final querySnapshot = await query.get();

    if (querySnapshot.docs.isEmpty) {
      final itemToSave = ShoppingListItem(
        nome: nomeNormalizado,
        quantidade: item.quantidade,
        categoria: item.categoria,
        isAutomatic: item.isAutomatic,
        isChecked: item.isChecked,
        prioridade: item.prioridade,
        userId: userId,
        familyId: item.familyId,
        criadoEm: item.criadoEm
      );

      await _firestoreService.addDocument(
        'shopping_list',
        itemToSave.toMap(),
      );
    }
  }

  Future<ShoppingListItem?> findItemByProductName(String productName, String userId, {String? familyId}) async {
    final nomeNormalizado = productName.trim();
    Query query = _db.collection('shopping_list');
    
    if (familyId != null && familyId.isNotEmpty) {
      query = query.where('familyId', isEqualTo: familyId);
    } else {
      query = query.where('userId', isEqualTo: userId);
    }
    
    query = query.where('nome', isEqualTo: nomeNormalizado).limit(1);
    
    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return ShoppingListItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateItem(String id, bool isChecked) {
    return _firestoreService.updateDocument(
      'shopping_list',
      id,
      {'isChecked': isChecked},
    );
  }

  Future<void> deleteItem(String id) {
    return _firestoreService.deleteDocument(
      'shopping_list',
      id,
    );
  }
}
