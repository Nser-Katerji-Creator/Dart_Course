import 'package:equatable/equatable.dart';
import '../../../models/parking.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkings extends ParkingEvent {
  const LoadParkings({required String userId, required bool activeOnly, required bool sortAscending});
}

class LoadParkingsByVehicleId extends ParkingEvent {
  final String vehicleId;
  
  const LoadParkingsByVehicleId(this.vehicleId);
  
  @override
  List<Object?> get props => [vehicleId];
}

class LoadActiveParkings extends ParkingEvent {
  const LoadActiveParkings();
}

class LoadParkingHistory extends ParkingEvent {
  const LoadParkingHistory();
}

class AddParking extends ParkingEvent {
  final Parking parking;
  
  const AddParking(this.parking);
  
  @override
  List<Object?> get props => [parking];
}

class EndParking extends ParkingEvent {
  final String parkingId;
  
  const EndParking(this.parkingId);
  
  @override
  List<Object?> get props => [parkingId];
}

class GetParkingById extends ParkingEvent {
  final String id;
  
  const GetParkingById(this.id);
  
  @override
  List<Object?> get props => [id];
}

class StartParking extends ParkingEvent {
  final Parking parking;

  const StartParking(this.parking);

  @override
  List<Object?> get props => [parking];
}
