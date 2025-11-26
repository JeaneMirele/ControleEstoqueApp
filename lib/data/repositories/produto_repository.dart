
import '../../models/Produto.dart';
import '../services/FirestoreService.dart';

class ProdutoRepository {
  final FirestoreService _service;

  final String _collectionPath = 'estoque';

  ProdutoRepository(this._service);

  Stream<List<Produto>> getAllProducts() {
    return _service.getCollectionStream(_collectionPath).map((snapshot) {
      return snapshot.docs.map((doc) {

        return Produto.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }


  Future<void> addProduct(Produto produto) {
    return _service.addDocument(_collectionPath, produto.toMap());
  }

  Future<void> updateProduct(Produto produto) {
    return _service.updateDocument(
        _collectionPath,
        produto.id!,
        produto.toMap()
    );
  }

  Future<void> deleteProduct(String id) {
    return _service.deleteDocument(_collectionPath, id);
  }
}