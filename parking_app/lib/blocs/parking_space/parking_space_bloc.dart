import 'package:bloc/bloc.dart';
import '../../../repositories/parking_space_repository.dart';
import '../../../models/parking_space.dart';
import 'parking_space_event.dart';
import 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final ParkingSpaceRepository parkingSpaceRepository;

  ParkingSpaceBloc({required this.parkingSpaceRepository}) : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<SearchParkingSpaces>(_onSearchParkingSpaces);
    on<GetParkingSpaceById>(_onGetParkingSpaceById);
  }

  Future<void> _onLoadParkingSpaces(LoadParkingSpaces event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await parkingSpaceRepository.getAll();
      emit(ParkingSpacesLoaded(parkingSpaces));
    } catch (e) {
      emit(ParkingSpaceError(e.toString()));
    }
  }

  Future<void> _onSearchParkingSpaces(SearchParkingSpaces event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await parkingSpaceRepository.search(event.query);
      emit(ParkingSpacesLoaded(parkingSpaces));
    } catch (e) {
      emit(ParkingSpaceError(e.toString()));
    }
  }

  Future<void> _onGetParkingSpaceById(GetParkingSpaceById event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpace = await parkingSpaceRepository.getById(event.id);
      emit(ParkingSpaceLoadedSingle(parkingSpace));
    } catch (e) {
      emit(ParkingSpaceError(e.toString()));
    }
  }
}
