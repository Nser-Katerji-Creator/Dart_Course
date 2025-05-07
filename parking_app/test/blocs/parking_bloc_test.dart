import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_app/blocs/parking/parking_bloc.dart';
import 'package:parking_app/blocs/parking/parking_event.dart';
import 'package:parking_app/blocs/parking/parking_state.dart';
import 'package:parking_app/models/parking.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockParkingRepository mockParkingRepository;
  late List<Parking> testParkings;
  late Parking testParking;
  late Parking testActiveParking;
  late List<Parking> testActiveParkings;
  late List<Parking> testParkingHistory;

  setUp(() {
    mockParkingRepository = MockParkingRepository();
    
    testParking = Parking(
      id: '1',
      vehicleId: 'vehicle1',
      parkingSpaceId: 'space1',
      startTime: DateTime(2025, 3, 1, 10, 0),
      endTime: DateTime(2025, 3, 1, 12, 0),
    );
    
    testActiveParking = Parking(
      id: '2',
      vehicleId: 'vehicle1',
      parkingSpaceId: 'space2',
      startTime: DateTime(2025, 3, 2, 10, 0),
      endTime: null,
    );
    
    testParkings = [
      testParking,
      testActiveParking,
      Parking(
        id: '3',
        vehicleId: 'vehicle2',
        parkingSpaceId: 'space1',
        startTime: DateTime(2025, 3, 3, 10, 0),
        endTime: DateTime(2025, 3, 3, 11, 0),
      ),
    ];
    
    testActiveParkings = [testActiveParking];
    
    testParkingHistory = [
      testParking,
      Parking(
        id: '3',
        vehicleId: 'vehicle2',
        parkingSpaceId: 'space1',
        startTime: DateTime(2025, 3, 3, 10, 0),
        endTime: DateTime(2025, 3, 3, 11, 0),
      ),
    ];
  });

  group('ParkingBloc', () {
    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingLoaded] when LoadParkings is added and successful',
      build: () {
        when(() => mockParkingRepository.getAll())
            .thenAnswer((_) async => testParkings);
        return ParkingBloc(parkingRepository: mockParkingRepository);
      },
      act: (bloc) => bloc.add(const LoadParkings(
        userId: 'testUserId',
        activeOnly: false,
        sortAscending: true,
      )),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingLoaded>().having((state) => state.parkings, 'parkings', testParkings),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getAll()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingError] when LoadParkings is added and fails',
      build: () {
        when(() => mockParkingRepository.getAll())
            .thenThrow(Exception('Failed to load parkings'));
        return ParkingBloc(parkingRepository: mockParkingRepository);
      },
      act: (bloc) => bloc.add(const LoadParkings(
        userId: 'testUserId',
        activeOnly: false,
        sortAscending: true,
      )),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingError>().having(
          (state) => state.error,
          'error',
          contains('Failed to load parkings'),
        ),
      ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ActiveParkingsLoaded] when LoadActiveParkings is added and successful',
      build: () {
        when(() => mockParkingRepository.getActiveParking())
            .thenAnswer((_) async => testActiveParkings);
        return ParkingBloc(parkingRepository: mockParkingRepository);
      },
      act: (bloc) => bloc.add(const LoadActiveParkings()),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ActiveParkingsLoaded>().having(
          (state) => state.activeParkings,
          'activeParkings',
          testActiveParkings,
        ),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.getActiveParking()).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingOperationSuccess] when EndParking is added and successful',
      build: () {
        when(() => mockParkingRepository.endParking('2'))
            .thenAnswer((_) async {});
        return ParkingBloc(parkingRepository: mockParkingRepository);
      },
      act: (bloc) => bloc.add(const EndParking('2')),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingOperationSuccess>().having(
          (state) => state.message,
          'message',
          'Parking ended successfully',
        ),
      ],
      verify: (_) {
        verify(() => mockParkingRepository.endParking('2')).called(1);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingError] when EndParking is added and fails',
      build: () {
        when(() => mockParkingRepository.endParking('2'))
            .thenThrow(Exception('Failed to end parking'));
        return ParkingBloc(parkingRepository: mockParkingRepository);
      },
      act: (bloc) => bloc.add(const EndParking('2')),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingError>().having(
          (state) => state.error,
          'error',
          contains('Failed to end parking'),
        ),
      ],
    );
  });
}
