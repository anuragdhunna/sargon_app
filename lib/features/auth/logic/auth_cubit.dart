import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hotel_manager/core/models/user_model.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/migration_service.dart';
import 'auth_state.dart';

/// Authentication Cubit
///
/// Manages authentication state using Firebase Auth with email/password.
/// Supports:
/// - Email/password registration (createUserWithEmailAndPassword)
/// - Email/password sign in
/// - Password reset
/// - Mock login for development/testing
class AuthCubit extends Cubit<AuthState> {
  final AuthService? _authService;
  StreamSubscription? _authStateSubscription;
  bool _migrationsRun = false; // Track if migrations have been executed

  AuthCubit({AuthService? authService})
    : _authService = authService,
      super(AuthInitial()) {
    // Listen to auth state changes if service is available
    if (_authService != null) {
      _authStateSubscription = _authService.authStateChanges.listen(
        _onAuthStateChanged,
      );
    }
  }

  /// Handle Firebase auth state changes
  Future<void> _onAuthStateChanged(dynamic firebaseUser) async {
    if (firebaseUser == null) {
      emit(AuthInitial());
    } else {
      // User is signed in, try to get profile
      final user = await _authService?.getCurrentUserProfile();
      if (user != null) {
        emit(
          AuthVerified(role: user.role, userId: user.id, userName: user.name),
        );

        // Run migrations and bootstrap defaults after authentication if user is Owner/Manager
        if (!_migrationsRun &&
            (user.role == UserRole.owner || user.role == UserRole.manager)) {
          _migrationsRun = true;
          _runMigrationsInBackground();
          _bootstrapDatabaseData();
        }
      }
    }
  }

  /// Run migrations in background (non-blocking)
  void _runMigrationsInBackground() {
    MigrationService().runMigrations().catchError((e) {
      debugPrint('⚠️ Migration error: $e');
    });
  }

  /// Bootstrap essential data (Rules, Tables, etc.) if they don't exist
  void _bootstrapDatabaseData() async {
    final databaseService = DatabaseService();
    // Verify we have a real Firebase user before attempting to bootstrap
    if (_authService?.currentFirebaseUser == null) {
      debugPrint('ℹ️ skipping bootstrapping: No Firebase User (Mock Auth)');
      return;
    }

    try {
      debugPrint('🚀 Bootstrapping database defaults...');
      await databaseService.initializeBillingDefaults();
      await databaseService.initializeDummyTables();
      await databaseService.initializeDummyRooms();
      debugPrint('✅ Database bootstrapping complete');
    } catch (e) {
      debugPrint('❌ Bootstrapping error (likely role permission issue): $e');
    }
  }

  /// Register a new user with email and password
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
  }) async {
    emit(AuthLoading());

    if (_authService == null) {
      // Fallback to mock registration for development
      await Future.delayed(const Duration(seconds: 1));
      emit(
        AuthVerified(
          role: role,
          userId: 'mock_${email.hashCode}',
          userName: name,
        ),
      );
      return;
    }

    final result = await _authService.registerWithEmailPassword(
      email: email,
      password: password,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
    );

    if (result.success && result.user != null) {
      emit(
        AuthVerified(
          role: result.user!.role,
          userId: result.user!.id,
          userName: result.user!.name,
        ),
      );
    } else {
      emit(AuthError(result.errorMessage ?? 'Registration failed'));
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    if (_authService == null) {
      // Fallback to mock sign in for development
      await Future.delayed(const Duration(seconds: 1));
      final role = _getRoleFromMockEmail(email);
      emit(
        AuthVerified(
          role: role,
          userId: 'mock_${email.hashCode}',
          userName: _getUserNameForRole(role),
        ),
      );
      return;
    }

    final result = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      emit(
        AuthVerified(
          role: result.user!.role,
          userId: result.user!.id,
          userName: result.user!.name,
        ),
      );
    } else {
      emit(AuthError(result.errorMessage ?? 'Sign in failed'));
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());

    if (_authService == null) {
      emit(const AuthError('Password reset is not available in demo mode'));
      return;
    }

    final success = await _authService.sendPasswordResetEmail(email);
    if (success) {
      emit(AuthInitial()); // Return to login with success message
    } else {
      emit(const AuthError('Failed to send password reset email'));
    }
  }

  // =========================================================================
  // LEGACY OTP METHODS (for backward compatibility)
  // =========================================================================

  /// Step 1: Send OTP to Phone (Legacy - redirects to mock)
  Future<void> sendOtp(String phoneNumber) async {
    emit(AuthLoading());

    // Mock Logic for development
    if (_isMockNumber(phoneNumber)) {
      await Future.delayed(const Duration(seconds: 1));
      emit(const AuthCodeSent(verificationId: 'mock_verification_id'));
      return;
    }

    emit(
      const AuthError(
        'Phone authentication is deprecated. Please use email/password.',
      ),
    );
  }

  /// Step 2: Verify OTP (Legacy - redirects to mock)
  Future<void> verifyOtp(String otp) async {
    // Mock Logic
    if (otp == '111111') {
      final role = UserRole.waiter;
      emit(
        AuthVerified(
          role: role,
          userId: 'mock_user',
          userName: _getUserNameForRole(role),
        ),
      );
      return;
    }

    emit(const AuthError('Invalid OTP'));
  }

  // =========================================================================
  // PERSONA LOGIN (for development/testing)
  // =========================================================================

  /// Quick login as a specific persona (development only)
  void loginAsPersona(UserRole role) async {
    emit(AuthLoading());

    // Map role to seeded account for real Firebase Auth session
    final email = '${role.name}@sargon.com';
    const password = '111111';

    try {
      if (_authService != null) {
        // 1. Try Sign In
        final loginResult = await _authService.signInWithEmailPassword(
          email: email,
          password: password,
        );

        if (loginResult.success) {
          _bootstrapDatabaseData();
          return; // AuthVerified will be emitted by _onAuthStateChanged
        }

        // 2. If User not found, try to Register (Self-healing for dev)
        // Normalize check for "invalid-credential" and "user-not-found"
        final isNotFound =
            loginResult.errorMessage?.toLowerCase().contains('not found') ==
                true ||
            loginResult.errorMessage?.toLowerCase().contains('invalid') ==
                true ||
            loginResult.errorMessage?.toLowerCase().contains('credential') ==
                true ||
            loginResult.errorMessage?.toLowerCase().contains('password') ==
                true;

        if (isNotFound) {
          debugPrint(
            'ℹ️ Persona not found/invalid, attempting registration: $email',
          );
          final regResult = await _authService.registerWithEmailPassword(
            email: email,
            password: password,
            name: _getUserNameForRole(role),
            phoneNumber: '9876543210',
            role: role,
          );

          if (regResult.success) {
            _bootstrapDatabaseData();
            return;
          } else {
            debugPrint(
              '❌ Self-healing registration failed: ${regResult.errorMessage}',
            );
          }
        }
      }

      // Fallback only as last resort (Warning: this will likely cause permission errors)
      debugPrint('⚠️ Warning: Proceeding with Mock Auth. DB access may fail.');
      emit(
        AuthVerified(
          role: role,
          userId: 'persona_${role.name}',
          userName: _getUserNameForRole(role),
        ),
      );
    } catch (e) {
      debugPrint('❌ Persona login error: $e');
      emit(AuthError('Failed to establish Firebase session: $e'));
    }
  }

  // =========================================================================
  // LOGOUT
  // =========================================================================

  /// Sign out current user
  void logout() async {
    try {
      await _authService?.signOut();
    } catch (e) {
      // Ignore errors during logout
    }
    emit(AuthInitial());
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  bool _isMockNumber(String phone) {
    return [
      '9876543210',
      '9876543211',
      '9876543212',
      '9876543213',
      '9876543214',
      '9876543215',
    ].contains(phone);
  }

  UserRole _getRoleFromMockEmail(String email) {
    final emailLower = email.toLowerCase();
    if (emailLower.contains('owner')) return UserRole.owner;
    if (emailLower.contains('manager')) return UserRole.manager;
    if (emailLower.contains('chef')) return UserRole.chef;
    if (emailLower.contains('waiter')) return UserRole.waiter;
    if (emailLower.contains('housekeeping')) return UserRole.housekeeping;
    if (emailLower.contains('frontdesk')) return UserRole.frontDesk;
    return UserRole.waiter;
  }

  String _getUserNameForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Hotel Owner';
      case UserRole.manager:
        return 'Hotel Manager';
      case UserRole.frontDesk:
        return 'Front Desk Staff';
      case UserRole.chef:
        return 'Head Chef';
      case UserRole.waiter:
        return 'Waiter';
      case UserRole.housekeeping:
        return 'Housekeeping Staff';
      case UserRole.maintenance:
        return 'Maintenance Staff';
      case UserRole.security:
        return 'Security Staff';
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
