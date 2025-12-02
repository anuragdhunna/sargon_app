import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

// Assuming UserRole enum is defined in auth_state.dart or a similar file
// For example:
// enum UserRole { admin, user, guest }

class AuthCubit extends Cubit<AuthState> {
  // Lazy load FirebaseAuth to avoid crash if Firebase.initializeApp() hasn't run
  FirebaseAuth get _auth => FirebaseAuth.instance;
  String? _verificationId;
  String? _phoneNumber; // Store phone number for mock verification

  AuthCubit() : super(AuthInitial());

  // Step 1: Send OTP to Phone
  Future<void> sendOtp(String phoneNumber) async {
    _phoneNumber = phoneNumber; // Store for verification
    emit(AuthLoading());
    
    // Mock Logic: If it's a dev number, skip Firebase
    if (_isMockNumber(phoneNumber)) {
      await Future.delayed(const Duration(seconds: 1));
      _verificationId = 'mock_verification_id'; // Store verification ID
      emit(const AuthCodeSent(verificationId: 'mock_verification_id'));
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber', // Assuming Indian context as per summary
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(e.message ?? 'Verification Failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          emit(AuthCodeSent(verificationId: verificationId, resendToken: resendToken));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOtp(String otp) async {
    // Mock Logic
    if (_verificationId == 'mock_verification_id' && otp == '111111') {
      final phone = _phoneNumber ?? '';
      final role = _getRoleForMockNumber(phone);
      final userId = _getUserIdForMockNumber(phone);
      final userName = _getUserNameForRole(role);
      emit(AuthVerified(
        role: role,
        userId: userId,
        userName: userName,
      ));
      return;
    }

    if (_verificationId == null) {
      emit(const AuthError('Verification ID is missing. Request OTP again.'));
      return;
    }
    emit(AuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  bool _isMockNumber(String phone) {
    return ['9876543210', '9876543211', '9876543212', '9876543213', '9876543214', '9876543215'].contains(phone);
  }

  UserRole _getRoleForMockNumber(String phone) {
    switch (phone) {
      case '9876543210':
        return UserRole.owner;
      case '9876543215':
        return UserRole.manager;
      case '9876543211':
        return UserRole.frontDesk;
      case '9876543212':
        return UserRole.housekeeping;
      case '9876543213':
        return UserRole.waiter;
      case '9876543214':
        return UserRole.chef;
      default:
        return UserRole.waiter;
    }
  }

  String _getUserIdForMockNumber(String phone) {
    return 'user_${phone.substring(phone.length - 4)}';
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

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        // In real scenario, fetch role from Firestore using user.uid
        // In real scenario, fetch role from Firestore using user.uid
        final role = _getRoleForMockNumber(_phoneNumber ?? '');
        final userId = user.uid;
        final userName = user.displayName ?? _getUserNameForRole(role);
        emit(AuthVerified(
          role: role,
          userId: userId,
          userName: userName,
        ));
      } else {
        emit(const AuthError('User is null after sign-in.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void loginAsPersona(UserRole role) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthVerified(
      role: role,
      userId: 'persona_${role.name}',
      userName: _getUserNameForRole(role),
    ));
  }

  void logout() {
    // Clear stored phone and verification ID
    _phoneNumber = null;
    _verificationId = null;
    
    // Try to sign out from Firebase if initialized, but don't fail if not
    try {
      _auth.signOut();
    } catch (e) {
      // Firebase not initialized, ignore
    }
    
    emit(AuthInitial());
  }
}
