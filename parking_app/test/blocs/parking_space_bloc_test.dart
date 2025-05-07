import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_app/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_app/blocs/parking_space/parking_space_event.dart';
import 'package:parking_app/blocs/parking_space/parking_space_state.dart';
import 'package:parking_app/models/parking_space.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockParkingSpaceRepository mockParkingSpaceRepository;
  late List<ParkingSpace> testParkingSpaces;
  late ParkingSpace testParkingSpace;

  setUp(() {
    mockParkingSpaceRepository = MockParkingSpaceRepository();
    
    testParkingSpace = ParkingSpace(
      id: '1',
      address: 'Test Street 1',
      pricePerHour: 20.0,
    );
    
    testParkingSpaces = [
      testParkingSpace,
      ParkingSpace(
        id: '2',
        address: 'Test Avenue 2',
        pricePerHour: 25.0,
      ),
    ];
  });

  group('ParkingSpaceBloc', () {
    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpacesLoaded] when LoadParkingSpaces is added and successful',
      build: () {
        when(() => mockParkingSpaceRepository.getAll())
            .thenAnswer((_) async => testParkingSpaces);
        return ParkingSpaceBloc(parkingSpaceRepository: mockParkingSpaceRepository);
      },
      act: (bloc) => bloc.add(const LoadParkingSpaces()),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpacesLoaded>().having((state) => state.parkingSpaces, 'parkingSpaces', testParkingSpaces),
      ],
      verify: (_) {
        verify(() => mockParkingSpaceRepository.getAll()).called(1);
      },
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceError] when LoadParkingSpaces is added and fails',
      build: () {
        when(() => mockParkingSpaceRepository.getAll())
            .thenThrow(Exception('Failed to load parking spaces'));
        return ParkingSpaceBloc(parkingSpaceRepository: mockParkingSpaceRepository);
      },
      act: (bloc) => bloc.add(const LoadParkingSpaces()),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceError>().having(
          (state) => state.error,
          'error',
          contains('Failed to load parking spaces'),
        ),
      ],
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpacesLoaded] when SearchParkingSpaces is added and successful',
      build: () {
        when(() => mockParkingSpaceRepository.search('Test'))
            .thenAnswer((_) async => testParkingSpaces);
        return ParkingSpaceBloc(parkingSpaceRepository: mockParkingSpaceRepository);
      },
      act: (bloc) => bloc.add(const SearchParkingSpaces('Test')),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpacesLoaded>().having(
          (state) => state.parkingSpaces,
          'parkingSpaces',
          testParkingSpaces,
        ),
      ],
      verify: (_) {
        verify(() => mockParkingSpaceRepository.search('Test')).called(1);
      },
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceLoadedSingle] when GetParkingSpaceById is added and successful',
      build: () {
        when(() => mockParkingSpaceRepository.getById('1'))
            .thenAnswer((_) async => testParkingSpace);
        return ParkingSpaceBloc(parkingSpaceRepository: mockParkingSpaceRepository);
      },
      act: (bloc) => bloc.add(const GetParkingSpaceById('1')),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceLoadedSingle>().having(
          (state) => state.parkingSpace,
          'parkingSpace',
          testParkingSpace,
        ),
      ],
      verify: (_) {
        verify(() => mockParkingSpaceRepository.getById('1')).called(1);
      },
    );
  });
}
