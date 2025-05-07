import 'package:equatable/equatable.dart';
import '../../../models/vehicle.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();
  
  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  
  const VehicleLoaded(this.vehicles);
  
  @override
  List<Object?> get props => [vehicles];
}

class VehicleLoadedSingle extends VehicleState {
  final Vehicle? vehicle;
  
  const VehicleLoadedSingle(this.vehicle);
  
  @override
  List<Object?> get props => [vehicle];
}

class VehicleOperationSuccess extends VehicleState {
  final String message;
  
  const VehicleOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class VehicleError extends VehicleState {
  final String error;
  
  const VehicleError(this.error);
  
  @override
  List<Object?> get props => [error];
}
