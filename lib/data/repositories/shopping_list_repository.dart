import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shopping_list_item.dart';
import '../services/firestore_service.dart';

class ShoppingListRepository {
  final FirestoreService _firestoreService;
  // Use a direct instance for custom queries not covered by the generic service
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  ShoppingListRepository(this._firestoreService);

  // Get all shopping list items as a stream
  Stream<List<ShoppingListItem>> getShoppingList() {
    // getCollectionStream returns a raw QuerySnapshot stream.
    // The repository is responsible for mapping this to a list of model objects.
    return _firestoreService.getCollectionStream('shopping_list').map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ShoppingListItem.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Add a new item to the shopping list, only if it doesn't exist yet
  Future<void> addItem(ShoppingListItem item) async {
    // The service is too generic for a 'get where' query, so we use the db instance directly.
    // This kind of specific logic belongs in the repository.
    final query = _db.collection('shopping_list').where('nome', isEqualTo: item.nome).limit(1);
    final querySnapshot = await query.get();

    if (querySnapshot.docs.isEmpty) {
      // Use the generic service to add the document
      await _firestoreService.addDocument(
        'shopping_list',
        item.toMap(),
      );
    }
    // If it already exists, do nothing.
  }

  // Update an existing item (e.g., to check/uncheck it)
  Future<void> updateItem(String id, bool isChecked) {
    // Call the service method with the correct positional arguments.
    return _firestoreService.updateDocument(
      'shopping_list',
      id,
      {'isChecked': isChecked},
    );
  }

  // Delete an item from the shopping list
  Future<void> deleteItem(String id) {
    // Call the service method with the correct positional arguments.
    return _firestoreService.deleteDocument(
      'shopping_list',
      id,
    );
  }
}
