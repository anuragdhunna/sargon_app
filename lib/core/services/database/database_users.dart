part of '../database_service.dart';

extension DatabaseUsers on DatabaseService {
  DatabaseReference get usersRef => _ref('users');

  /// Stream all users (real-time)
  Stream<List<User>> streamUsers() {
    return usersRef.onValue.map((event) {
      if (event.snapshot.value == null) return <User>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <User>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final userData = _toMap(e.value);
        return User.fromJson(userData);
      }).toList();
    });
  }

  /// Get user by ID
  Future<User?> getUser(String userId) async {
    final snapshot = await usersRef.child(userId).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return User.fromJson(_toMap(snapshot.value));
  }

  /// Save user
  Future<void> saveUser(User user) async {
    await usersRef.child(user.id).set(user.toJson());
  }
}
