import 'package:equatable/equatable.dart';
import '../../../models/parking_space.dart';

abstract class ParkingSpaceState extends Equatable {
  const ParkingSpaceState();
  
  @override
  List<Object?> get props => [];
}

class ParkingSpaceInitial extends ParkingSpaceState {}

class ParkingSpaceLoading extends ParkingSpaceState {}

class ParkingSpacesLoaded extends ParkingSpaceState {
  final List<ParkingSpace> parkingSpaces;
  
  const ParkingSpacesLoaded(this.parkingSpaces);
  
  @override
  List<Object?> get props => [parkingSpaces];
}

class ParkingSpaceLoadedSingle extends ParkingSpaceState {
  final ParkingSpace? parkingSpace;
  
  const ParkingSpaceLoadedSingle(this.parkingSpace);
  
  @override
  List<Object?> get props => [parkingSpace];
}

class ParkingSpaceError extends ParkingSpaceState {
  final String error;
  
  const ParkingSpaceError(this.error);
  
  @override
  List<Object?> get props => [error];
}

class ParkingSpaceAdded extends ParkingSpaceState {}
