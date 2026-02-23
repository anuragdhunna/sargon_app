import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/auth_service.dart';
import 'package:hotel_manager/core/services/database_service.dart';

abstract class OwnerRegistrationState extends Equatable {
  const OwnerRegistrationState();
  @override
  List<Object?> get props => [];
}

class OwnerRegistrationInitial extends OwnerRegistrationState {}

class OwnerRegistrationLoading extends OwnerRegistrationState {}

class OwnerRegistrationSuccess extends OwnerRegistrationState {
  final String message;
  const OwnerRegistrationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class OwnerRegistrationError extends OwnerRegistrationState {
  final String message;
  const OwnerRegistrationError(this.message);
  @override
  List<Object?> get props => [message];
}

class OwnerRegistrationCubit extends Cubit<OwnerRegistrationState> {
  final AuthService _authService;
  final DatabaseService _databaseService;

  OwnerRegistrationCubit({
    required AuthService authService,
    required DatabaseService databaseService,
  }) : _authService = authService,
       _databaseService = databaseService,
       super(OwnerRegistrationInitial());

  Future<void> registerOwner({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? existingHotelId,
    String? newHotelName,
    String? newHotelAddress,
  }) async {
    emit(OwnerRegistrationLoading());
    try {
      String finalHotelId = '';

      // 1. Create a new hotel if selected
      if (newHotelName != null && newHotelName.isNotEmpty) {
        final docRef = _databaseService.firestore.collection('hotels').doc();
        final newHotel = Hotel(
          id: docRef.id,
          hotelId: docRef.id, // For a hotel, its hotelId is its own id
          name: newHotelName,
          address: newHotelAddress ?? '',
          status: 'active',
          createdOn: DateTime.now(),
        );
        await _databaseService.saveHotel(newHotel);
        finalHotelId = newHotel.id;
      } else if (existingHotelId != null && existingHotelId.isNotEmpty) {
        finalHotelId = existingHotelId; // Use existing
      }

      // 2. Create the owner auth account
      final authResult = await _authService.createOwnerAccount(
        email: email,
        name: name,
        phoneNumber: phone,
        password: password,
        hotelIds: finalHotelId.isNotEmpty ? [finalHotelId] : [],
      );

      if (!authResult.success || authResult.user == null) {
        // In a complex app, we might safely delete the created hotel if user creation fails.
        emit(
          OwnerRegistrationError(
            authResult.errorMessage ?? 'Failed to create owner account',
          ),
        );
        return;
      }

      // 3. Link owner back to the hotel
      if (finalHotelId.isNotEmpty) {
        await _databaseService.assignOwnerToHotel(
          hotelId: finalHotelId,
          ownerId: authResult.user!.id,
        );
      }

      emit(const OwnerRegistrationSuccess('Owner created successfully!'));
    } catch (e) {
      emit(OwnerRegistrationError(e.toString()));
    }
  }
}
