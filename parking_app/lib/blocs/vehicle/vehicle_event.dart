import 'package:equatable/equatable.dart';
import '../../../models/vehicle.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {
  final String ownerId;
  
  const LoadVehicles(this.ownerId);
  
  @override
  List<Object?> get props => [ownerId];
}

class AddVehicle extends VehicleEvent {
  final Vehicle vehicle;
  
  const AddVehicle(this.vehicle);
  
  @override
  List<Object?> get props => [vehicle];
}

class UpdateVehicle extends VehicleEvent {
  final String registrationNumber;
  final Vehicle vehicle;
  
  const UpdateVehicle(this.registrationNumber, this.vehicle);
  
  @override
  List<Object?> get props => [registrationNumber, vehicle];
}

class DeleteVehicle extends VehicleEvent {
  final String registrationNumber;
  
  const DeleteVehicle(this.registrationNumber);
  
  @override
  List<Object?> get props => [registrationNumber];
}

class GetVehicleByRegistrationNumber extends VehicleEvent {
  final String registrationNumber;
  
  const GetVehicleByRegistrationNumber(this.registrationNumber);
  
  @override
  List<Object?> get props => [registrationNumber];
}
