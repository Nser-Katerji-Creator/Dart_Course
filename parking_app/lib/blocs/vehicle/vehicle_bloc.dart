import 'package:bloc/bloc.dart';
import '../../../repositories/firebase_vehicle_repository.dart';
import '../../../models/vehicle.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final FirebaseVehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<GetVehicleByRegistrationNumber>(_onGetVehicleByRegistrationNumber);
  }

  Future<void> _onLoadVehicles(LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getByOwnerId(event.ownerId);
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.create(event.vehicle);
      emit(const VehicleOperationSuccess('Vehicle added successfully'));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.update(event.registrationNumber, event.vehicle);
      emit(const VehicleOperationSuccess('Vehicle updated successfully'));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.delete(event.registrationNumber);
      emit(const VehicleOperationSuccess('Vehicle deleted successfully'));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onGetVehicleByRegistrationNumber(
      GetVehicleByRegistrationNumber event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicle = await vehicleRepository.getByRegistrationNumber(event.registrationNumber);
      emit(VehicleLoadedSingle(vehicle));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}
