import 'package:cloud_firestore/cloud_firestore.dart';

typedef QueryBuilder = Query Function(Query query);

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCollectionStream(String path, {QueryBuilder? queryBuilder}) {
    Query query = _db.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  Future<void> addDocument(String path, Map<String, dynamic> data) {
    return _db.collection(path).add(data);
  }

  Future<void> updateDocument(String path, String docId, Map<String, dynamic> data) {
    return _db.collection(path).doc(docId).update(data);
  }

  Future<void> deleteDocument(String path, String docId) {
    return _db.collection(path).doc(docId).delete();
  }
}