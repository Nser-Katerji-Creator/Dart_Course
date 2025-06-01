import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_app/blocs/parking/parking_bloc.dart';
import 'package:parking_app/blocs/parking/parking_event.dart';
import 'package:parking_app/blocs/parking/parking_state.dart';
import 'package:parking_app/models/parking.dart';
// Repositories and Services
import 'package:parking_app/repositories/firebase_parking_repository.dart'; // Ensure this is the correct interface your mock implements
// Mocks - adjust paths if your mocks are structured differently
import '../mocks/mock_firebase_repositories.dart';
import '../mocks/mock_notification_service.dart';
// Utils
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late ParkingBloc parkingBloc;
  late MockFirebaseParkingRepository mockParkingRepository;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
     tz.initializeTimeZones();
     tz.setLocalLocation(tz.getLocation('Etc/UTC')); // Use a consistent timezone for all tests
  });

  setUp(() {
    mockParkingRepository = MockFirebaseParkingRepository();
    mockNotificationService = MockNotificationService();
    parkingBloc = ParkingBloc(
      parkingRepository: mockParkingRepository,
      notificationService: mockNotificationService,
    );

    // Default stubs for mockNotificationService methods
    when(() => mockNotificationService.scheduleNotificationById(
        id: any(named: 'id'), title: any(named: 'title'), body: any(named: 'body'),
        scheduledTime: any(named: 'scheduledTime'), payload: any(named: 'payload')))
        .thenAnswer((_) async {}); // Default behavior: do nothing, return Future<void>
    when(() => mockNotificationService.cancelNotificationById(any()))
        .thenAnswer((_) async {}); // Default behavior: do nothing, return Future<void>
  });

  tearDown(() => parkingBloc.close());

  test('initial state is ParkingInitial', () => expect(parkingBloc.state, ParkingInitial()));

  group('StartParking Event', () {
    // It's good practice to define test data clearly
    final DateTime fixedNow = DateTime(2023, 1, 1, 12, 0, 0); // A fixed point in time for predictable tests
    final Parking parkingValidEnd = Parking(id: 'pValid', vehicleId: 'v1', parkingSpaceId: 'ps1',
                                  startTime: fixedNow.subtract(const Duration(hours: 1)),
                                  endTime: fixedNow.add(const Duration(minutes: 30))); // Reminder in 15m from fixedNow
    final Parking parkingNoEnd = Parking(id: 'pNoEnd', vehicleId: 'v2', parkingSpaceId: 'ps2', startTime: fixedNow);
    final Parking parkingEndTooSoon = Parking(id: 'pEndSoon', vehicleId: 'v3', parkingSpaceId: 'ps3',
                                    startTime: fixedNow.subtract(const Duration(hours: 1)),
                                    endTime: fixedNow.add(const Duration(minutes: 10))); // Reminder in -5m (past from fixedNow)
    final Parking parkingPastEnd = Parking(id: 'pPastEnd', vehicleId: 'v4', parkingSpaceId: 'ps4',
                                   startTime: fixedNow.subtract(const Duration(hours: 1)),
                                   endTime: fixedNow.subtract(const Duration(minutes: 5))); // Reminder in -20m (past from fixedNow)
    final Parking parkingEmptyId = Parking(id: '', vehicleId: 'v5', parkingSpaceId: 'ps5',
                                   startTime: fixedNow.subtract(const Duration(hours: 1)),
                                   endTime: fixedNow.add(const Duration(minutes: 30)));

    blocTest<ParkingBloc, ParkingState>(
      'schedules notification for valid future endTime',
      build: () {
        when(() => mockParkingRepository.create(parkingValidEnd)).thenAnswer((_) async => parkingValidEnd.id);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingValidEnd)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingValidEnd)).called(1);
        final expectedReminderTime = parkingValidEnd.endTime!.subtract(const Duration(minutes: 15));
        verify(() => mockNotificationService.scheduleNotificationById(
                id: parkingValidEnd.id.hashCode, title: 'Parking Reminder',
                body: 'Parking session ending at ${DateFormat.Hm().format(parkingValidEnd.endTime!)}.',
                scheduledTime: expectedReminderTime, payload: parkingValidEnd.id)).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'NOT schedule if endTime is null',
      build: () {
        when(() => mockParkingRepository.create(parkingNoEnd)).thenAnswer((_) async => parkingNoEnd.id);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingNoEnd)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingNoEnd)).called(1);
        verifyNever(() => mockNotificationService.scheduleNotificationById(
            id: any(named: 'id'), title: any(named: 'title'), body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'), payload: any(named: 'payload')));
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'NOT schedule if reminderTime is in the past (endTime too soon)',
      build: () {
        when(() => mockParkingRepository.create(parkingEndTooSoon)).thenAnswer((_) async => parkingEndTooSoon.id);
        // Simulate DateTime.now() being 'fixedNow' for consistent test results if ParkingBloc uses DateTime.now()
        // This is tricky with blocTest if DateTime.now() is called inside the BLoC.
        // For this test, we assume the check `reminderTime.isAfter(DateTime.now())` inside BLoC
        // will correctly evaluate against the `parkingEndTooSoon.endTime`.
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingEndTooSoon)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingEndTooSoon)).called(1);
        verifyNever(() => mockNotificationService.scheduleNotificationById(
            id: any(named: 'id'), title: any(named: 'title'), body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'), payload: any(named: 'payload')));
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'NOT schedule if parking.id is empty',
      build: () {
        when(() => mockParkingRepository.create(parkingEmptyId)).thenAnswer((_) async => parkingEmptyId.id);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingEmptyId)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingEmptyId)).called(1);
        verifyNever(() => mockNotificationService.scheduleNotificationById(
            id: any(named: 'id'), title: any(named: 'title'), body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'), payload: any(named: 'payload')));
      },
    );

    blocTest<ParkingBloc, ParkingState>(
     'emits ParkingError on repository.create failure; NOT schedule',
     build: () {
       when(() => mockParkingRepository.create(parkingValidEnd)).thenThrow(Exception('Repo.create failed'));
       return parkingBloc;
     },
     act: (bloc) => bloc.add(StartParking(parkingValidEnd)),
     expect: () => [ParkingLoading(), ParkingError('Failed to start parking: Exception: Repo.create failed')],
     verify: (_) {
       verifyNever(() => mockNotificationService.scheduleNotificationById(
           id: any(named: 'id'), title: any(named: 'title'), body: any(named: 'body'),
           scheduledTime: any(named: 'scheduledTime'), payload: any(named: 'payload')));
     },
   );
  }); // End of StartParking Group

  group('EndParking Event', () {
    const String parkingId = 'pToEnd123';
    blocTest<ParkingBloc, ParkingState>(
      'cancels notification and emits success for valid parkingId',
      build: () {
        when(() => mockParkingRepository.endParking(parkingId)).thenAnswer((_) async {});
        return parkingBloc;
      },
      act: (bloc) => bloc.add(const EndParking(parkingId)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking ended successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.endParking(parkingId)).called(1);
        verify(() => mockNotificationService.cancelNotificationById(parkingId.hashCode)).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'NOT cancel notification if parkingId is empty',
      build: () {
        when(() => mockParkingRepository.endParking('')).thenAnswer((_) async {}); // repo might still be called with empty
        return parkingBloc;
      },
      act: (bloc) => bloc.add(const EndParking('')),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking ended successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.endParking('')).called(1);
        verifyNever(() => mockNotificationService.cancelNotificationById(any()));
      },
    );

    blocTest<ParkingBloc, ParkingState>(
     'emits ParkingError on repository.endParking failure; still attempts cancel before repo call',
     build: () {
       // Ensure cancelNotificationById itself doesn't throw for this test
       when(() => mockNotificationService.cancelNotificationById(parkingId.hashCode)).thenAnswer((_) async {});
       when(() => mockParkingRepository.endParking(parkingId)).thenThrow(Exception('Repo.end failed'));
       return parkingBloc;
     },
     act: (bloc) => bloc.add(const EndParking(parkingId)),
     expect: () => [ParkingLoading(), ParkingError('Failed to end parking: Exception: Repo.end failed')],
     verify: (_) {
        verify(() => mockNotificationService.cancelNotificationById(parkingId.hashCode)).called(1);
     },
   );
  }); // End of EndParking Group
}
