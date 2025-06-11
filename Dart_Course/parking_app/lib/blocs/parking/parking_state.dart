import 'package:equatable/equatable.dart';
import '../../../models/parking.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();
  
  @override
  List<Object?> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<Parking> parkings;
  
  const ParkingLoaded(this.parkings);
  
  @override
  List<Object?> get props => [parkings];

  get parkingSpaces => null;

  get vehicles => null;
}

class ParkingLoadedSingle extends ParkingState {
  final Parking? parking;
  
  const ParkingLoadedSingle(this.parking);
  
  @override
  List<Object?> get props => [parking];
}

class ActiveParkingsLoaded extends ParkingState {
  final List<Parking> activeParkings;
  
  const ActiveParkingsLoaded(this.activeParkings);
  
  @override
  List<Object?> get props => [activeParkings];
}

class ParkingHistoryLoaded extends ParkingState {
  final List<Parking> parkingHistory;
  
  const ParkingHistoryLoaded(this.parkingHistory);
  
  @override
  List<Object?> get props => [parkingHistory];
}

class ParkingOperationSuccess extends ParkingState {
  final String message;
  
  const ParkingOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ParkingError extends ParkingState {
  final String error;
  
  const ParkingError(this.error);
  
  @override
  List<Object?> get props => [error];
}
