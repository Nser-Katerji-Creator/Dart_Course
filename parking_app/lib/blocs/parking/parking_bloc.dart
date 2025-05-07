import 'package:bloc/bloc.dart';
import '../../../repositories/parking_repository.dart';
import '../../../models/parking.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<LoadParkings>(_onLoadParkings);
    on<LoadParkingsByVehicleId>(_onLoadParkingsByVehicleId);
    on<LoadActiveParkings>(_onLoadActiveParkings);
    on<LoadParkingHistory>(_onLoadParkingHistory);
    on<AddParking>(_onAddParking);
    on<EndParking>(_onEndParking);
    on<GetParkingById>(_onGetParkingById);
    on<StartParking>(_onStartParking);
  }

  Future<void> _onLoadParkings(LoadParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getAll();
      emit(ParkingLoaded(parkings));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onLoadParkingsByVehicleId(LoadParkingsByVehicleId event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getByVehicleId(event.vehicleId);
      emit(ParkingLoaded(parkings));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onLoadActiveParkings(LoadActiveParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final activeParkings = await parkingRepository.getActiveParking();
      emit(ActiveParkingsLoaded(activeParkings));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onLoadParkingHistory(LoadParkingHistory event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkingHistory = await parkingRepository.getParkingHistory();
      final sortedHistory = await parkingRepository.sortByStartTime(parkingHistory, ascending: false);
      emit(ParkingHistoryLoaded(sortedHistory));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onAddParking(AddParking event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      await parkingRepository.create(event.parking);
      emit(const ParkingOperationSuccess('Parking created successfully'));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onEndParking(EndParking event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      await parkingRepository.endParking(event.parkingId);
      emit(const ParkingOperationSuccess('Parking ended successfully'));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onGetParkingById(GetParkingById event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parking = await parkingRepository.getById(event.id);
      emit(ParkingLoadedSingle(parking));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }
  Future<void> _onStartParking(StartParking event, Emitter<ParkingState> emit) async {
    // Consider emitting a specific loading state like ParkingStarting
    emit(ParkingLoading()); // Or a more specific state
    try {
      await parkingRepository.create(event.parking);
      emit(const ParkingOperationSuccess('Parking started successfully'));
      // Optionally reload relevant parking list (e.g., active parkings)
      // add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingError('Failed to start parking: ${e.toString()}'));
    }
  }

  
}
