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
import '../mocks/mock_firebase_parking_repository.dart';
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
    final DateTime fixedNow = DateTime.now(); // Use current time for predictable tests
    final Parking parkingValidPlannedDuration = Parking(id: 'pValid', vehicleId: 'v1', parkingSpaceId: 'ps1',
                                  startTime: fixedNow.subtract(const Duration(hours: 1)),
                                  endTime: null, // Active parking has null endTime
                                  plannedDuration: const Duration(minutes: 90)); // 90 minutes planned duration
    final Parking parkingNoPlannedDuration = Parking(id: 'pNoEnd', vehicleId: 'v2', parkingSpaceId: 'ps2', startTime: fixedNow);
    final Parking parkingPlannedDurationTooSoon = Parking(id: 'pEndSoon', vehicleId: 'v3', parkingSpaceId: 'ps3',
                                    startTime: fixedNow.subtract(const Duration(minutes: 5)),
                                    endTime: null,
                                    plannedDuration: const Duration(minutes: 10)); // Only 10 minutes, reminder would be in past
    final Parking parkingEmptyId = Parking(id: '', vehicleId: 'v5', parkingSpaceId: 'ps5',
                                   startTime: fixedNow.subtract(const Duration(hours: 1)),
                                   endTime: null,
                                   plannedDuration: const Duration(minutes: 90));

    blocTest<ParkingBloc, ParkingState>(
      'schedules notification for valid future plannedEndTime',
      build: () {
        when(() => mockParkingRepository.create(parkingValidPlannedDuration)).thenAnswer((_) async => parkingValidPlannedDuration.id);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingValidPlannedDuration)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingValidPlannedDuration)).called(1);
        final expectedReminderTime = parkingValidPlannedDuration.plannedEndTime!.subtract(const Duration(minutes: 15));
        verify(() => mockNotificationService.scheduleNotificationById(
                id: parkingValidPlannedDuration.id.hashCode, title: 'Parking Reminder',
                body: 'Parking session ending at ${DateFormat.Hm().format(parkingValidPlannedDuration.plannedEndTime!)}.',
                scheduledTime: expectedReminderTime, payload: parkingValidPlannedDuration.id)).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'NOT schedule if plannedDuration is null',
      build: () {
        when(() => mockParkingRepository.create(parkingNoPlannedDuration)).thenAnswer((_) async => parkingNoPlannedDuration.id);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingNoPlannedDuration)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingNoPlannedDuration)).called(1);
        verifyNever(() => mockNotificationService.scheduleNotificationById(
            id: any(named: 'id'), title: any(named: 'title'), body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'), payload: any(named: 'payload')));
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'NOT schedule if reminderTime is in the past (plannedDuration too soon)',
      build: () {
        when(() => mockParkingRepository.create(parkingPlannedDurationTooSoon)).thenAnswer((_) async => parkingPlannedDurationTooSoon.id);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(StartParking(parkingPlannedDurationTooSoon)),
      expect: () => [ParkingLoading(), const ParkingOperationSuccess('Parking started successfully')],
      verify: (_) {
        verify(() => mockParkingRepository.create(parkingPlannedDurationTooSoon)).called(1);
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
       when(() => mockParkingRepository.create(parkingValidPlannedDuration)).thenThrow(Exception('Repo.create failed'));
       return parkingBloc;
     },
     act: (bloc) => bloc.add(StartParking(parkingValidPlannedDuration)),
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
