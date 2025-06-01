import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_app/services/notification_service.dart';
import '../../../repositories/firebase_parking_repository.dart';
import '../../../models/parking.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final FirebaseParkingRepository parkingRepository;
  final NotificationService notificationService;

  ParkingBloc({required this.parkingRepository, required this.notificationService}) : super(ParkingInitial()) {
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
      if (event.parkingId.isNotEmpty) {
        final int numericNotificationId = event.parkingId.hashCode;
        await notificationService.cancelNotificationById(numericNotificationId);
      }

      await parkingRepository.endParking(event.parkingId);
      emit(const ParkingOperationSuccess('Parking ended successfully'));
    } catch (e) {
      emit(ParkingError('Failed to end parking: ${e.toString()}'));
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
    emit(ParkingLoading());
    try {
      await parkingRepository.create(event.parking); // Assumes event.parking.id is the definitive ID

      if (event.parking.id.isNotEmpty && event.parking.endTime != null) {
        final reminderTime = event.parking.endTime!.subtract(const Duration(minutes: 15));
        if (reminderTime.isAfter(DateTime.now())) {
          final int numericNotificationId = event.parking.id.hashCode;
          await notificationService.scheduleNotificationById(
            id: numericNotificationId,
            title: 'Parking Reminder',
            body: 'Parking session ending at ${DateFormat.Hm().format(event.parking.endTime!)}.',
            scheduledTime: reminderTime,
            payload: event.parking.id,
          );
        }
      }
      emit(const ParkingOperationSuccess('Parking started successfully'));
    } catch (e) {
      emit(ParkingError('Failed to start parking: ${e.toString()}'));
    }
  }

  
}
