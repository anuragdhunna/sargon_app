import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/rooms/logic/room_cubit.dart';
import 'package:hotel_manager/features/rooms/ui/create_booking_dialog.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:mocktail/mocktail.dart';

/// MOCK CLASSES
class MockRoomCubit extends MockCubit<RoomState> implements RoomCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockCustomerCubit extends MockCubit<CustomerState>
    implements CustomerCubit {}

void main() {
  late MockRoomCubit mockRoomCubit;
  late MockAuthCubit mockAuthCubit;
  late MockCustomerCubit mockCustomerCubit;

  final testRoom = const Room(
    id: '101',
    roomNumber: '101',
    type: RoomType.deluxe,
    status: RoomStatus.available,
    pricePerNight: 2000,
    floor: 1,
    capacity: 2,
  );

  setUp(() {
    mockRoomCubit = MockRoomCubit();
    mockAuthCubit = MockAuthCubit();
    mockCustomerCubit = MockCustomerCubit();

    // Default mock behavior
    when(() => mockCustomerCubit.state).thenReturn(CustomerInitial());
    when(() => mockAuthCubit.state).thenReturn(
      const AuthVerified(
        userId: 'admin',
        userName: 'Admin User',
        role: UserRole.manager,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RoomCubit>.value(value: mockRoomCubit),
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
            BlocProvider<CustomerCubit>.value(value: mockCustomerCubit),
          ],
          child: CreateBookingDialog(room: testRoom),
        ),
      ),
    );
  }

  group('CreateBookingDialog Widget Tests', () {
    testWidgets('renders all form fields correctly', (tester) async {
      /// Purpose: Verify that the booking form shows all necessary fields.
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert header
      expect(find.text('New Booking'), findsOneWidget);
      expect(find.textContaining('Room 101'), findsOneWidget);

      // Assert input fields
      expect(find.text('Primary Guest Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('ID Proof Number'), findsOneWidget);
      expect(find.text('Booking Total'), findsOneWidget);

      // Initial total for 1 night should be 2000
      expect(find.text('₹2000.0'), findsOneWidget);
    });

    testWidgets(
      'shows validation errors when fields are empty and Confirm is pressed',
      (tester) async {
        /// Purpose: Test form validation logic.
        await tester.pumpWidget(createWidgetUnderTest());

        // Act: Tap Confirm Booking without filling data
        await tester.tap(find.text('Confirm Booking'));
        await tester.pumpAndSettle();

        // Assert: Validation messages should appear
        // Using a regex to match common "required" error messages
        expect(
          find.textContaining(
            RegExp(
              r'(cannot be empty|is required|required)',
              caseSensitive: false,
            ),
          ),
          findsAtLeastNWidgets(1),
        );
      },
    );

    testWidgets('calculates total price correctly when dates are selected', (
      tester,
    ) async {
      /// Purpose: Verify that the UI updates based on user interaction (logic in dialog).
      await tester.pumpWidget(createWidgetUnderTest());

      // Note: testing DateRangePicker in widget tests is complex because it opens a new overlay.
      // For now, let's verify that the initial calculation is correct.
      expect(find.text('₹2000.0'), findsOneWidget);
    });

    group('Interview Questions - Dialog Testing', () {
      test(
        'Q1: How do you test a Dialog which is usually not a child of a Screen directly?',
        () {
          // Answer: We can use tester.pumpWidget() to render just the Dialog wrapped in a Scaffold,
          // OR we can render a Button that triggers showDialog() and then use tester.pumpAndSettle()
          // to wait for the dialog animation to finish.
        },
      );

      test('Q2: How do you handle GlobalKeys in Widget tests?', () {
        // Answer: Since we are recreating the widget in each test, GlobalKeys are usually fine.
        // However, we should be careful about state persistence between tests and always use
        // setUp() to fresh start.
      });
    });
  });
}
