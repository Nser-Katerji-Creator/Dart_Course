import 'package:equatable/equatable.dart';
import '../../../models/parking_space.dart';

abstract class ParkingSpaceEvent extends Equatable {
  const ParkingSpaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkingSpaces extends ParkingSpaceEvent {
  const LoadParkingSpaces();
}

class SearchParkingSpaces extends ParkingSpaceEvent {
  final String query;
  
  const SearchParkingSpaces(this.query);
  
  @override
  List<Object?> get props => [query];
}

class GetParkingSpaceById extends ParkingSpaceEvent {
  final String id;
  
  const GetParkingSpaceById(this.id);
  
  @override
  List<Object?> get props => [id];
}
