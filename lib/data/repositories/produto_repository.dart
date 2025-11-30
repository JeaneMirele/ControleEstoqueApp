import '../../models/produto.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProdutoRepository {
  final FirestoreService _service;

  final String _collectionPath = 'estoque';

  ProdutoRepository(this._service);

  Stream<List<Produto>> getAllProducts({String? userId, String? familyId}) {
    return _service.getCollectionStream(_collectionPath, queryBuilder: (query) {
      if (familyId != null && familyId.isNotEmpty) {
        return query.where('familyId', isEqualTo: familyId);
      } else if (userId != null && userId.isNotEmpty) {
        return query.where('userId', isEqualTo: userId);
      }
      // Segurança: Se não tiver user nem família, filtra por algo impossível para retornar vazio
      // em vez de retornar todo o banco de dados.
      return query.where(FieldPath.documentId, isEqualTo: 'non_existent_id_security_check'); 
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Produto.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Produto>> getShoppingList({String? userId, String? familyId}) {
    return _service.getCollectionStream(
      _collectionPath,
      queryBuilder: (query) {
        var q = query.where('comprado', isEqualTo: false);
        if (familyId != null && familyId.isNotEmpty) {
          return q.where('familyId', isEqualTo: familyId);
        } else if (userId != null && userId.isNotEmpty) {
          return q.where('userId', isEqualTo: userId);
        }
        return q.where(FieldPath.documentId, isEqualTo: 'non_existent_id_security_check');
      },
    ).map((snapshot) {
      return snapshot.docs.map((doc) => Produto.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addProduct(Produto produto) {
    return _service.addDocument(_collectionPath, produto.toMap());
  }

  Future<void> updateProduct(Produto produto) {
    return _service.updateDocument(
      _collectionPath,
      produto.id!,
      produto.toMap(),
    );
  }

  Future<void> deleteProduct(String id) {
    return _service.deleteDocument(_collectionPath, id);
  }
}
