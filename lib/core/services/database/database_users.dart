part of '../database_service.dart';

extension DatabaseUsers on DatabaseService {
  CollectionReference _usersRef() => firestore.collection('users');

  /// Stream all users (real-time)
  Stream<List<User>> streamUsers(String hotelId) {
    return _usersRef().where('hotelId', isEqualTo: hotelId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return User.fromJson(data);
      }).toList();
    });
  }

  /// Get user by ID
  Future<User?> getUser(String hotelId, String userId) async {
    final doc = await _usersRef().doc(userId).get();
    if (!doc.exists) return null;
    return User.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Save user
  Future<void> saveUser(User user) async {
    await _usersRef().doc(user.id).set(user.toJson());
  }

  /// Update user status
  Future<void> updateUserStatus(
    String hotelId,
    String userId,
    bool isActive,
  ) async {
    await _usersRef().doc(userId).update({
      'status': isActive ? UserStatus.active.name : UserStatus.inactive.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Delete user
  Future<void> deleteUser(String hotelId, String userId) async {
    await _usersRef().doc(userId).delete();
  }
}
