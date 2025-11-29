import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shopping_list_item.dart';
import '../services/firestore_service.dart';

class ShoppingListRepository {
  final FirestoreService _firestoreService;

  final FirebaseFirestore _db = FirebaseFirestore.instance;


  ShoppingListRepository(this._firestoreService);


  Stream<List<ShoppingListItem>> getShoppingList() {

    return _firestoreService.getCollectionStream('shopping_list').map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ShoppingListItem.fromMap(data, doc.id);
      }).toList();
    });
  }


  Future<void> addItem(ShoppingListItem item) async {

    final query = _db.collection('shopping_list').where('nome', isEqualTo: item.nome).limit(1);
    final querySnapshot = await query.get();

    if (querySnapshot.docs.isEmpty) {

      await _firestoreService.addDocument(
        'shopping_list',
        item.toMap(),
      );
    }

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
