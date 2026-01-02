import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Authentication result containing user data or error
class AuthResult {
  final User? user;
  final String? errorMessage;
  final bool success;

  const AuthResult._({this.user, this.errorMessage, required this.success});

  factory AuthResult.success(User user) =>
      AuthResult._(user: user, success: true);

  factory AuthResult.error(String message) =>
      AuthResult._(errorMessage: message, success: false);
}

/// Authentication service using Firebase Auth with Email/Password
///
/// This service handles user authentication, registration, and session management
/// using Firebase Authentication's createUserWithEmailAndPassword method.
class AuthService {
  final fb.FirebaseAuth _auth;
  final DatabaseReference _usersRef;

  AuthService({fb.FirebaseAuth? auth, DatabaseReference? usersRef})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _usersRef = usersRef ?? FirebaseDatabase.instance.ref('users');

  /// Get current Firebase user
  fb.User? get currentFirebaseUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email and password
  ///
  /// Creates a Firebase Auth account and stores user profile in Realtime Database.
  Future<AuthResult> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.error('Failed to create user account');
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user profile in Realtime Database
      final user = User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        status: UserStatus.active,
        createdAt: DateTime.now(),
      );

      await _usersRef.child(firebaseUser.uid).set(user.toJson());

      debugPrint('✅ User registered: ${user.name} (${user.role.name})');
      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e.code);
      debugPrint('❌ Registration error: $message');
      return AuthResult.error(message);
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      return AuthResult.error('An unexpected error occurred: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.error('Failed to sign in');
      }

      // Fetch user profile from Realtime Database
      final snapshot = await _usersRef.child(firebaseUser.uid).get();

      User user;
      if (!snapshot.exists) {
        // Profile doesn't exist - auto-create one
        // This handles manually created Firebase Auth accounts
        debugPrint('ℹ️ Profile not found, creating one for: $email');

        // Determine role from email pattern
        final role = _getRoleFromEmail(email);

        user = User(
          id: firebaseUser.uid,
          email: email,
          name: firebaseUser.displayName ?? email.split('@').first,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          role: role,
          status: UserStatus.active,
          createdAt: DateTime.now(),
        );

        // Save profile to database
        await _usersRef.child(firebaseUser.uid).set(user.toJson());
        debugPrint('✅ Profile created for: ${user.name} (${user.role.name})');
      } else {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        user = User.fromJson(userData);
      }

      debugPrint('✅ User signed in: ${user.name} (${user.role.name})');
      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e.code);
      debugPrint('❌ Sign in error: $message');
      return AuthResult.error(message);
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      return AuthResult.error('An unexpected error occurred: $e');
    }
  }

  /// Determine user role from email pattern
  UserRole _getRoleFromEmail(String email) {
    final emailLower = email.toLowerCase();
    if (emailLower.contains('owner') || emailLower.contains('admin')) {
      return UserRole.owner;
    }
    if (emailLower.contains('manager')) return UserRole.manager;
    if (emailLower.contains('frontdesk')) return UserRole.frontDesk;
    if (emailLower.contains('chef')) return UserRole.chef;
    if (emailLower.contains('waiter')) return UserRole.waiter;
    if (emailLower.contains('housekeeping')) return UserRole.housekeeping;
    if (emailLower.contains('maintenance')) return UserRole.maintenance;
    if (emailLower.contains('security')) return UserRole.security;
    // Default to owner for manually created accounts
    return UserRole.owner;
  }

  /// Get current user profile from database
  Future<User?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final snapshot = await _usersRef.child(userId).get();
      if (!snapshot.exists) return null;

      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      return User.fromJson(userData);
    } catch (e) {
      debugPrint('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(User user) async {
    try {
      await _usersRef.child(user.id).update(user.toJson());
      debugPrint('✅ User profile updated: ${user.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to $email');
      return true;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.message}');
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Delete user data from database
      await _usersRef.child(user.uid).remove();

      // Delete Firebase Auth account
      await user.delete();

      debugPrint('✅ User account deleted');
      return true;
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      return false;
    }
  }

  /// Create a staff account (admin/manager only)
  ///
  /// This creates a Firebase Auth account with default password '111111'
  /// and stores the user profile in the database.
  /// Note: Firebase Auth requires re-authentication for this to work properly
  /// in production. For now, we create the account in the database and
  /// the user can sign in with the default password.
  Future<AuthResult> createStaffAccount({
    required String email,
    required String name,
    required String phoneNumber,
    required UserRole role,
    String password = '111111',
  }) async {
    try {
      // Create a secondary app instance to avoid logging out current user
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
      }

      final secondaryAuth = fb.FirebaseAuth.instanceFor(app: secondaryApp);

      // Create Firebase Auth account for new staff using secondary auth instance
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.error('Failed to create staff account');
      }

      // Update display name on secondary auth instance
      await firebaseUser.updateDisplayName(name);

      // Create user profile in Realtime Database using primary database reference
      final user = User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        status: UserStatus.active,
        createdAt: DateTime.now(),
      );

      await _usersRef.child(firebaseUser.uid).set(user.toJson());

      // Sign out the newly created user in the secondary app instance
      await secondaryAuth.signOut();
      // Optional: delete secondary app instance, though often better to reuse
      // await secondaryApp.delete();

      debugPrint(
        '✅ Staff account created without logging out admin: ${user.name}',
      );
      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e.code);
      debugPrint('❌ Create staff error: $message');
      return AuthResult.error(message);
    } catch (e) {
      debugPrint('❌ Create staff error: $e');
      return AuthResult.error('An unexpected error occurred: $e');
    }
  }

  /// Seed default accounts for the hotel
  ///
  /// Creates default accounts with password '111111' if they don't exist.
  /// Should be called during initial app setup.
  static Future<void> seedDefaultAccounts() async {
    final auth = fb.FirebaseAuth.instance;
    final usersRef = FirebaseDatabase.instance.ref('users');

    final defaultAccounts = [
      {
        'email': 'owner@sargon.com',
        'name': 'Hotel Owner',
        'role': UserRole.owner,
      },
      {
        'email': 'manager@sargon.com',
        'name': 'Hotel Manager',
        'role': UserRole.manager,
      },
      {
        'email': 'frontdesk@sargon.com',
        'name': 'Front Desk',
        'role': UserRole.frontDesk,
      },
      {'email': 'chef@sargon.com', 'name': 'Head Chef', 'role': UserRole.chef},
      {'email': 'waiter@sargon.com', 'name': 'Waiter', 'role': UserRole.waiter},
      {
        'email': 'housekeeping@sargon.com',
        'name': 'Housekeeping',
        'role': UserRole.housekeeping,
      },
    ];

    for (final account in defaultAccounts) {
      try {
        // Try to create the account
        final credential = await auth.createUserWithEmailAndPassword(
          email: account['email'] as String,
          password: '111111',
        );

        final firebaseUser = credential.user;
        if (firebaseUser != null) {
          await firebaseUser.updateDisplayName(account['name'] as String);

          final user = User(
            id: firebaseUser.uid,
            email: account['email'] as String,
            name: account['name'] as String,
            phoneNumber: '',
            role: account['role'] as UserRole,
            status: UserStatus.active,
            createdAt: DateTime.now(),
          );

          await usersRef.child(firebaseUser.uid).set(user.toJson());
          debugPrint('✅ Created default account: ${account['email']}');
        }

        // Sign out after creating each account
        await auth.signOut();
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          debugPrint('ℹ️ Account already exists: ${account['email']}');
        } else {
          debugPrint('❌ Failed to create ${account['email']}: ${e.message}');
        }
      }
    }

    debugPrint('✅ Default accounts seeding complete');
  }

  /// Convert Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
