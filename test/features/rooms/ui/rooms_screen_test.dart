import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/rooms/ui/rooms_screen.dart';
import 'package:mocktail/mocktail.dart';

/// MOCK CLASSES
class MockRoomCubit extends MockCubit<RoomState> implements RoomCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockRoomCubit mockRoomCubit;
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockRoomCubit = MockRoomCubit();
    mockAuthCubit = MockAuthCubit();

    // Default mock behavior for initialization
    when(() => mockRoomCubit.loadRooms()).thenReturn(null);
    when(() => mockRoomCubit.getFilteredRooms()).thenReturn([]);
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RoomCubit>.value(value: mockRoomCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const RoomsScreen(),
      ),
    );
  }

  group('RoomsScreen Widget Tests', () {
    testWidgets('renders CircularProgressIndicator when state is RoomLoading', (
      tester,
    ) async {
      when(() => mockRoomCubit.state).thenReturn(RoomLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'renders Error message and Retry button when state is RoomError',
      (tester) async {
        const errorMessage = 'Failed to load rooms';
        when(
          () => mockRoomCubit.state,
        ).thenReturn(const RoomError(errorMessage));

        await tester.pumpWidget(createWidgetUnderTest());

        // Note: loadRooms() is called once in initState
        verify(() => mockRoomCubit.loadRooms()).called(1);

        expect(find.text('Error: $errorMessage'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // Act: Tap Retry
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Verify: Logic was called again (Total 2)
        verify(() => mockRoomCubit.loadRooms()).called(1);
      },
    );

    testWidgets('renders Room grid when state is RoomLoaded', (tester) async {
      final rooms = [
        const Room(
          id: '101',
          roomNumber: '101',
          type: RoomType.single,
          status: RoomStatus.available,
          pricePerNight: 1000,
          floor: 1,
          capacity: 2,
        ),
      ];

      when(() => mockRoomCubit.state).thenReturn(
        RoomLoaded(
          rooms: rooms,
          allBookings: const [],
          activeBookings: const {},
        ),
      );
      when(() => mockRoomCubit.getFilteredRooms()).thenReturn(rooms);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('101'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('category filter chips are present and functional', (
      tester,
    ) async {
      final rooms = [
        const Room(
          id: '101',
          roomNumber: '101',
          type: RoomType.single,
          status: RoomStatus.available,
          pricePerNight: 1000,
          floor: 1,
          capacity: 2,
        ),
      ];

      when(() => mockRoomCubit.state).thenReturn(
        RoomLoaded(
          rooms: rooms,
          allBookings: const [],
          activeBookings: const {},
        ),
      );
      when(() => mockRoomCubit.getFilteredRooms()).thenReturn(rooms);

      await tester.pumpWidget(createWidgetUnderTest());

      // Initially All Rooms is selected
      expect(find.text('All Rooms (1)'), findsOneWidget);

      // Find Single chip
      final singleChip = find.textContaining('Single');
      expect(singleChip, findsOneWidget);

      // Tap the Single chip
      await tester.tap(singleChip);
      await tester.pumpAndSettle();

      // Verification: The chip should now be selected (UI side test)
      // Since it uses setState, we check if it survived the pump
      expect(find.byType(FilterChip), findsAtLeastNWidgets(2));
    });
    group('Interview Questions - Widget Testing', () {
      test('Q1: What does Mocktail\'s verify().called(n) do?', () {
        // Answer: It ensures a method was called exactly n times.
        // In our error test, it helped us catch that loadRooms()
        // runs once on initState and once more on Retry tap.
      });

      test('Q2: Why use pumpAndSettle() instead of pump()?', () {
        // Answer: pumpAndSettle() waits for all animations and scheduled microtasks to finish.
        // pump() only triggers one frame. For complex transitions or dialogs,
        // pumpAndSettle() is safer.
      });
    });
  });
}
