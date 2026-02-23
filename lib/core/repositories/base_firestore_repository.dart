import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/models.dart';
import '../services/audit_service.dart';
import '../models/base_entity.dart';
import '../models/user_model.dart';

/// Generic repository for Firestore operations with built-in auditing support.
/// All child repositories should extend this class.
abstract class BaseFirestoreRepository<T extends BaseEntity> {
  final FirebaseFirestore firestore;
  final String collectionPath;
  final FirebaseAuth auth;
  final IAuditService auditService;

  BaseFirestoreRepository({
    required this.collectionPath,
    IAuditService? auditService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : auditService = auditService ?? AuditService(),
       firestore = firestore ?? FirebaseFirestore.instance,
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
  Future<List<T>> getAll({String? hotelId}) async {
    final snapshot = await getBaseQuery(hotelId: hotelId).get();
    return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
  }

  /// Stream all non-deleted documents.
  Stream<List<T>> streamAll({String? hotelId}) {
    return getBaseQuery(hotelId: hotelId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => fromJson(doc.data())).toList(),
    );
  }

  /// Base query that filters out deleted documents.
  Query<Map<String, dynamic>> getBaseQuery({String? hotelId}) {
    var query = collection.where('isDeleted', isEqualTo: false);
    if (hotelId != null) {
      query = query.where('hotelId', isEqualTo: hotelId);
    }
    return query;
  }

  /// Simplified logging helper for repositories.
  /// Automatically uses the current session performer if not provided.
  Future<void> logAction({
    User? performer,
    required AuditAction action,
    required String description,
    String? targetUserId,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
  }) async {
    await auditService.logUserAction(
      performer: performer,
      action: action,
      description: description,
      targetUserId: targetUserId,
      hotelId: performer?.hotelId,
      previousData: previousData,
      newData: newData,
    );
  }

  /// Child classes must implement this to convert Firestore data to [T].
  T fromJson(Map<String, dynamic> json);
}
