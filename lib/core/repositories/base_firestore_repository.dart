import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/base_entity.dart';

/// Generic repository for Firestore operations with built-in auditing support.
/// All child repositories should extend this class.
abstract class BaseFirestoreRepository<T extends BaseEntity> {
  final FirebaseFirestore firestore;
  final String collectionPath;
  final FirebaseAuth auth;

  BaseFirestoreRepository({
    required this.collectionPath,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
       auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(collectionPath);

  /// Current user ID for audit injection
  String? get currentUserId => auth.currentUser?.uid;

  /// Injects the current user's ID into the data to be consumed by Cloud Functions.
  Map<String, dynamic> _withAuditFields(Map<String, dynamic> data) {
    if (currentUserId == null) {
      throw Exception('Authentication required for auditing operations.');
    }
    return {...data, '_userId': currentUserId};
  }

  /// Create a new document.
  Future<void> create(T entity) async {
    final data = entity.toJson();
    await collection.doc(entity.id).set(_withAuditFields(data));
  }

  /// Update an existing document using the entity.
  Future<void> update(T entity) async {
    final data = entity.toJson();
    await collection.doc(entity.id).update(_withAuditFields(data));
  }

  /// Update specific fields of a document by ID.
  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    await collection.doc(id).update(_withAuditFields(fields));
  }

  /// Soft delete a document.
  Future<void> delete(String id) async {
    await collection.doc(id).update(_withAuditFields({'isDeleted': true}));
  }

  /// Get a single document by ID.
  Future<T?> getById(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists || doc.data()?['isDeleted'] == true) return null;
    return fromJson(doc.data()!);
  }

  /// Get all non-deleted documents.
  Future<List<T>> getAll() async {
    final snapshot = await baseQuery.get();
    return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
  }

  /// Stream all non-deleted documents.
  Stream<List<T>> streamAll() {
    return baseQuery.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => fromJson(doc.data())).toList(),
    );
  }

  /// Base query that filters out deleted documents.
  Query<Map<String, dynamic>> get baseQuery =>
      collection.where('isDeleted', isEqualTo: false);

  /// Child classes must implement this to convert Firestore data to [T].
  T fromJson(Map<String, dynamic> json);
}
