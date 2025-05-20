import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_app/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app/blocs/vehicle/vehicle_state.dart';
import 'package:parking_app/models/vehicle.dart';
import '../mocks/mock_firebase_vehicle_repository.dart';

void main() {
  late MockFirebaseVehicleRepository mockVehicleRepository;
  late List<Vehicle> testVehicles;
  late Vehicle testVehicle;

  setUp(() {
    mockVehicleRepository = MockFirebaseVehicleRepository();
    
    testVehicle = Vehicle(
      id: '1',
      registrationNumber: 'ABC123',
      type: 'Car',
      ownerId: 'owner1',
    );
    
    testVehicles = [
      testVehicle,
      Vehicle(
        id: '2',
        registrationNumber: 'DEF456',
        type: 'Truck',
        ownerId: 'owner1',
      ),
    ];
  });

  group('VehicleBloc', () {
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleLoaded] when LoadVehicles is added and successful',
      build: () {
        when(() => mockVehicleRepository.getByOwnerId('owner1'))
            .thenAnswer((_) async => testVehicles);
        return VehicleBloc(vehicleRepository: mockVehicleRepository);
      },
      act: (bloc) => bloc.add(const LoadVehicles('owner1')),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleLoaded>().having((state) => state.vehicles, 'vehicles', testVehicles),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.getByOwnerId('owner1')).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleError] when LoadVehicles is added and fails',
      build: () {
        when(() => mockVehicleRepository.getByOwnerId('owner1'))
            .thenThrow(Exception('Failed to load vehicles'));
        return VehicleBloc(vehicleRepository: mockVehicleRepository);
      },
      act: (bloc) => bloc.add(const LoadVehicles('owner1')),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleError>().having(
          (state) => state.error,
          'error',
          contains('Failed to load vehicles'),
        ),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleOperationSuccess] when AddVehicle is added and successful',
      build: () {
        when(() => mockVehicleRepository.create(testVehicle))
            .thenAnswer((_) async {});
        return VehicleBloc(vehicleRepository: mockVehicleRepository);
      },
      act: (bloc) => bloc.add(AddVehicle(testVehicle)),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleOperationSuccess>().having(
          (state) => state.message,
          'message',
          'Vehicle added successfully',
        ),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.create(testVehicle)).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleError] when AddVehicle is added and fails',
      build: () {
        when(() => mockVehicleRepository.create(testVehicle))
            .thenThrow(Exception('Failed to create vehicle'));
        return VehicleBloc(vehicleRepository: mockVehicleRepository);
      },
      act: (bloc) => bloc.add(AddVehicle(testVehicle)),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleError>().having(
          (state) => state.error,
          'error',
          contains('Failed to create vehicle'),
        ),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleLoadedSingle] when GetVehicleByRegistrationNumber is added and successful',
      build: () {
        when(() => mockVehicleRepository.getByRegistrationNumber('ABC123'))
            .thenAnswer((_) async => testVehicle);
        return VehicleBloc(vehicleRepository: mockVehicleRepository);
      },
      act: (bloc) => bloc.add(const GetVehicleByRegistrationNumber('ABC123')),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleLoadedSingle>().having(
          (state) => state.vehicle,
          'vehicle',
          testVehicle,
        ),
      ],
      verify: (_) {
        verify(() => mockVehicleRepository.getByRegistrationNumber('ABC123')).called(1);
      },
    );
  });
}
