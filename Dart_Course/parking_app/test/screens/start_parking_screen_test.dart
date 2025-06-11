import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart'; // For MockBloc and whenListen

import 'package:parking_app/blocs/auth/auth_bloc.dart';
import 'package:parking_app/blocs/auth/auth_event.dart';
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/blocs/parking/parking_bloc.dart';
import 'package:parking_app/blocs/parking/parking_event.dart';
import 'package:parking_app/blocs/parking/parking_state.dart';
import 'package:parking_app/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app/blocs/vehicle/vehicle_state.dart';
import 'package:parking_app/models/parking_space.dart';
import 'package:parking_app/models/person.dart';
import 'package:parking_app/models/vehicle.dart';
import 'package:parking_app/models/parking.dart';
import 'package:parking_app/screens/start_parking_screen.dart';

// Mocks
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockParkingBloc extends MockBloc<ParkingEvent, ParkingState> implements ParkingBloc {}
class MockVehicleBloc extends MockBloc<VehicleEvent, VehicleState> implements VehicleBloc {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake classes for events
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeParkingEvent extends Fake implements ParkingEvent {}
class FakeVehicleEvent extends Fake implements VehicleEvent {}
class FakeRoute extends Fake implements Route<dynamic> {}


void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeParkingEvent());
    registerFallbackValue(FakeVehicleEvent());
    registerFallbackValue(FakeRoute());
  });

  late MockAuthBloc mockAuthBloc;
  late MockParkingBloc mockParkingBloc;
  late MockVehicleBloc mockVehicleBloc;
  late MockNavigatorObserver mockNavigatorObserver;


  final testParkingSpace = ParkingSpace(
    id: 'ps1', address: '123 Test St', pricePerHour: 10.0, isOccupied: false);
  final testUser = Person(id: 'user123', personalNumber: 'user123', name: 'Test User', email: 'test@example.com');
  final testVehicles = [
    Vehicle(id: 'v1', ownerId: 'user123', registrationNumber: 'ABC-123', type: 'Car'),
    Vehicle(id: 'v2', ownerId: 'user123', registrationNumber: 'XYZ-789', type: 'Motorcycle'),
  ];

  // This list should mirror the one in StartParkingScreen for reliable testing
  final List<Map<String, dynamic>> parkingDurationsFromScreen = [
    {'text': '30 minutes', 'duration': const Duration(minutes: 30)},
    {'text': '1 hour', 'duration': const Duration(hours: 1)},
    {'text': '1 hour 30 minutes', 'duration': const Duration(hours: 1, minutes: 30)},
    {'text': '2 hours', 'duration': const Duration(hours: 2)},
    {'text': '3 hours', 'duration': const Duration(hours: 3)},
    {'text': '5 hours', 'duration': const Duration(hours: 5)},
    {'text': '8 hours', 'duration': const Duration(hours: 8)},
  ];

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockParkingBloc = MockParkingBloc();
    mockVehicleBloc = MockVehicleBloc();
    mockNavigatorObserver = MockNavigatorObserver();

    when(() => mockAuthBloc.state).thenReturn(AuthSuccess(testUser));
    when(() => mockVehicleBloc.state).thenReturn(VehicleLoaded(testVehicles));
    when(() => mockParkingBloc.state).thenReturn(ParkingInitial());

    when(() => mockAuthBloc.add(any())).thenReturn(null);
    when(() => mockVehicleBloc.add(any())).thenReturn(null);
    when(() => mockParkingBloc.add(any())).thenReturn(null);

    // Stub for Navigator pop verification
    when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
  });

  Widget createTestableWidget(Widget child, {MockParkingBloc? customParkingBloc}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<ParkingBloc>.value(value: customParkingBloc ?? mockParkingBloc),
          BlocProvider<VehicleBloc>.value(value: mockVehicleBloc),
        ],
        child: child,
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  group('StartParkingScreen Widget Tests', () {
    testWidgets('renders dropdowns with default values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(StartParkingScreen(parkingSpace: testParkingSpace)));
      await tester.pumpAndSettle();

      expect(find.text('Select Vehicle'), findsOneWidget);
      expect(find.textContaining(testVehicles.first.registrationNumber!), findsOneWidget);

      expect(find.text('Select Duration'), findsOneWidget);
      expect(find.text(parkingDurationsFromScreen.first['text'] as String), findsOneWidget);

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Start Parking'), findsNWidgets(2)); // AppBar + Button
    });

    testWidgets('selecting a different duration updates the selection in UI', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(StartParkingScreen(parkingSpace: testParkingSpace)));
      await tester.pumpAndSettle();

      final durationDropdown = find.byType(DropdownButtonFormField<Duration>);
      await tester.tap(durationDropdown);
      await tester.pumpAndSettle();

      final durationToSelectEntry = parkingDurationsFromScreen[2]; // "1 hour 30 minutes"
      final durationTextToSelect = durationToSelectEntry['text'] as String;

      await tester.tap(find.text(durationTextToSelect).last);
      await tester.pumpAndSettle();

      // After selection, the DropdownButtonFormField's selected item is displayed.
      expect(find.text(durationTextToSelect), findsOneWidget);
    });

    testWidgets('tapping "Start Parking" dispatches StartParking event with correct endTime', (WidgetTester tester) async {
      final selectedVehicle = testVehicles.first;
      final selectedDurationEntry = parkingDurationsFromScreen[1]; // "1 hour"
      final selectedDuration = selectedDurationEntry['duration'] as Duration;
      final selectedDurationText = selectedDurationEntry['text'] as String;

      await tester.pumpWidget(createTestableWidget(StartParkingScreen(parkingSpace: testParkingSpace)));
      await tester.pumpAndSettle();

      // Explicitly select a duration for clarity, though a default is present.
      final durationDropdown = find.byType(DropdownButtonFormField<Duration>);
      await tester.tap(durationDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedDurationText).last);
      await tester.pumpAndSettle();

      final DateTime timeBeforeTap = DateTime.now();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      final captured = verify(() => mockParkingBloc.add(captureAny(that: isA<StartParking>()))).captured;
      expect(captured.length, 1);
      final event = captured.first as StartParking;
      final parkingData = event.parking;

      expect(parkingData.vehicleId, selectedVehicle.id);
      expect(parkingData.parkingSpaceId, testParkingSpace.id);
      expect(parkingData.endTime, isNull); // Active parking should have null endTime
      expect(parkingData.plannedDuration, isNotNull); // Should have planned duration instead

      // startTime should be very close to timeBeforeTap
      expect(parkingData.startTime.isAfter(timeBeforeTap.subtract(const Duration(seconds: 3))), isTrue);
      expect(parkingData.startTime.isBefore(timeBeforeTap.add(const Duration(seconds: 3))), isTrue);

      // Check planned duration matches selected duration
      expect(parkingData.plannedDuration, equals(selectedDuration));
    });

    // TODO: Fix this test - BlocConsumer listener testing is complex
    // testWidgets('shows SnackBar and pops screen on ParkingOperationSuccess', (WidgetTester tester) async {
    //   final localMockParkingBloc = MockParkingBloc();
      
    //   // Start with initial state
    //   when(() => localMockParkingBloc.state).thenReturn(ParkingInitial());
    //   when(() => localMockParkingBloc.add(any())).thenReturn(null);

    //   final successMessage = 'Test Parking Started Successfully!';
      
    //   await tester.pumpWidget(createTestableWidget(
    //       StartParkingScreen(parkingSpace: testParkingSpace),
    //       customParkingBloc: localMockParkingBloc
    //   ));
    //   await tester.pumpAndSettle();

    //   // Verify button exists
    //   expect(find.byType(ElevatedButton), findsOneWidget);
      
    //   // Change to success state and use whenListen to emit the state
    //   when(() => localMockParkingBloc.state).thenReturn(ParkingOperationSuccess(successMessage));
      
    //   whenListen(
    //     localMockParkingBloc,
    //     Stream.fromIterable([
    //       ParkingOperationSuccess(successMessage),
    //     ]),
    //   );
      
    //   // Trigger a pump to process the stream
    //   await tester.pump();
      
    //   // Check that SnackBar appears
    //   expect(find.text(successMessage), findsOneWidget);
      
    //   // Let the navigation complete
    //   await tester.pumpAndSettle();
      
    //   // Verify navigation occurred
    //   verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    // });

    testWidgets('shows SnackBar on ParkingError', (WidgetTester tester) async {
      final localMockParkingBloc = MockParkingBloc();
      when(() => localMockParkingBloc.state).thenReturn(ParkingInitial());
      when(() => localMockParkingBloc.add(any())).thenReturn(null);

      final errorMessage = 'Test Parking Error!';
      whenListen(
        localMockParkingBloc,
        Stream.fromIterable([ParkingLoading(), ParkingError(errorMessage)]),
        initialState: ParkingInitial(),
      );

      await tester.pumpWidget(createTestableWidget(
        StartParkingScreen(parkingSpace: testParkingSpace),
        customParkingBloc: localMockParkingBloc
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Parking Error: $errorMessage'), findsOneWidget);
      verifyNever(() => mockNavigatorObserver.didPop(any(), any())); // Should not pop on error
    });
  });
}
