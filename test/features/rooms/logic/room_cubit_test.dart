import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/rooms/data/room_repository.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

class MockChecklistCubit extends Mock implements ChecklistCubit {}

class FakeBooking extends Fake implements Booking {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

void main() {
  late RoomCubit roomCubit;
  late MockRoomRepository mockRoomRepository;
  late MockChecklistCubit mockChecklistCubit;

  // We use StreamControllers to precisely control WHEN data is sent to the Cubit.
  // Interviewer Question: "Why use StreamControllers in Cubit tests?"
  // Answer: To simulate the real-time nature of Firebase. We can test how the UI
  // reacts to loading state, then data state, then updates.
  late StreamController<List<Room>> roomsController;
  late StreamController<List<Booking>> bookingsController;

  setUpAll(() {
    registerFallbackValue(FakeBooking());
    registerFallbackValue(RoomStatus.available);
  });

  setUp(() {
    mockRoomRepository = MockRoomRepository();
    mockChecklistCubit = MockChecklistCubit();
    roomsController = StreamController<List<Room>>.broadcast();
    bookingsController = StreamController<List<Booking>>.broadcast();

    // Link the repository mocks to our controllers
    when(
      () => mockRoomRepository.streamRooms(),
    ).thenAnswer((_) => roomsController.stream);
    when(
      () => mockRoomRepository.streamBookings(),
    ).thenAnswer((_) => bookingsController.stream);
    when(
      () => mockRoomRepository.bookingsRef,
    ).thenReturn(MockDatabaseReference());

    // Initialize Cubit (it will start listening to streams)
    roomCubit = RoomCubit(
      repository: mockRoomRepository,
      checklistCubit: mockChecklistCubit,
    );
  });

  tearDown(() {
    roomsController.close();
    bookingsController.close();
    roomCubit.close();
  });

  group('RoomCubit Unit Tests', () {
    test('initial state is RoomLoading', () {
      /// Purpose: Verify that the Cubit starts in Loading state while waiting for data.
      expect(roomCubit.state, isA<RoomLoading>());
    });

    blocTest<RoomCubit, RoomState>(
      'emits [RoomLoaded] when data arrives from streams',
      build: () => roomCubit,
      act: (cubit) {
        // Send data through the controllers
        roomsController.add([]);
        bookingsController.add([]);
      },
      expect: () => [isA<RoomLoaded>()],
      verify: (_) {
        // One call from constructor, one (potentially) if we called loadRooms again.
        // But here we didn't call loadRooms in act, we just pushed data.
        verify(() => mockRoomRepository.streamRooms()).called(1);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'emits RoomError when stream has error',
      build: () => roomCubit,
      act: (cubit) {
        roomsController.addError('Database Error');
      },
      expect: () => [
        isA<RoomError>().having(
          (e) => e.message,
          'message',
          contains('Database Error'),
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'createBooking fails if guest phone is empty',
      build: () => roomCubit,
      act: (cubit) => cubit.createBooking(
        roomId: '1',
        guestName: 'John Doe',
        guestPhone: '',
        checkIn: DateTime.now(),
        checkOut: DateTime.now().add(const Duration(days: 1)),
        totalAmount: 1000,
        bookedByUserId: 'admin',
        bookedByUserName: 'Admin',
        bookedByUserRole: 'admin',
      ),
      expect: () => [
        isA<RoomError>().having(
          (e) => e.message,
          'message',
          contains('Phone number is mandatory'),
        ),
      ],
    );

    blocTest<RoomCubit, RoomState>(
      'createBooking successfully saves booking',
      build: () {
        when(
          () => mockRoomRepository.saveBooking(any()),
        ).thenAnswer((_) async => Future.value());
        when(
          () => mockRoomRepository.updateRoomStatus(any(), any()),
        ).thenAnswer((_) async => Future.value());
        return roomCubit;
      },
      act: (cubit) => cubit.createBooking(
        roomId: '101',
        guestName: 'Jane Smith',
        guestPhone: '9876543210',
        checkIn: DateTime.now(),
        checkOut: DateTime.now().add(const Duration(days: 2)),
        totalAmount: 5000,
        bookedByUserId: 'user1',
        bookedByUserName: 'Staff One',
        bookedByUserRole: 'staff',
      ),
      verify: (_) {
        verify(() => mockRoomRepository.saveBooking(any())).called(1);
      },
    );

    test('isRoomAvailable logic test', () async {
      final from = DateTime(2026, 1, 15);
      final to = DateTime(2026, 1, 18);

      final existingBooking = Booking(
        id: 'b1',
        guestName: 'Guest',
        guestPhone: '123',
        roomId: '101',
        checkIn: from,
        checkOut: to,
        status: BookingStatus.confirmed,
        totalAmount: 3000,
        bookedBy: 'Admin',
        createdAt: DateTime.now(),
      );

      // Push data to transition to RoomLoaded
      roomsController.add([]);
      bookingsController.add([existingBooking]);

      // Wait for state transition
      await expectLater(roomCubit.stream, emitsThrough(isA<RoomLoaded>()));

      // Test overlap (Starts before, ends during)
      expect(
        roomCubit.isRoomAvailable(
          '101',
          from.subtract(const Duration(days: 1)),
          from.add(const Duration(days: 1)),
        ),
        isFalse,
      );

      // Test overlap (Starts during, ends after)
      expect(
        roomCubit.isRoomAvailable(
          '101',
          from.add(const Duration(days: 1)),
          to.add(const Duration(days: 1)),
        ),
        isFalse,
      );

      // Test no overlap (Ends before)
      expect(
        roomCubit.isRoomAvailable(
          '101',
          from.subtract(const Duration(days: 5)),
          from.subtract(const Duration(days: 2)),
        ),
        isTrue,
      );
    });
  });
}
