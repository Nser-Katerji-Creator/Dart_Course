import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_app/services/notification_service.dart';
import '../../../repositories/firebase_parking_repository.dart';
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
    on<ExtendParking>(_onExtendParking);
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
    print('DEBUG: _onEndParking called for parking ID: ${event.parkingId}');
    emit(ParkingLoading());
    try {
      // First, let's verify the parking exists
      print('DEBUG: Checking if parking exists with ID: ${event.parkingId}');
      final parking = await parkingRepository.getById(event.parkingId);
      print('DEBUG: Retrieved parking: ${parking?.toString() ?? 'null'}');
      
      if (parking == null) {
        print('ERROR: Parking with ID ${event.parkingId} not found in database');
        emit(const ParkingError('Parking not found'));
        return;
      }
      
      if (event.parkingId.isNotEmpty) {
        final int numericNotificationId = event.parkingId.hashCode;
        print('DEBUG: Cancelling notification with ID: $numericNotificationId');
        await notificationService.cancelNotificationById(numericNotificationId);
      }

      print('DEBUG: Calling parkingRepository.endParking for ID: ${event.parkingId}');
      await parkingRepository.endParking(event.parkingId);
      print('DEBUG: Parking ended successfully in repository');
      emit(const ParkingOperationSuccess('Parking ended successfully'));
    } catch (e) {
      print('ERROR: Failed to end parking: ${e.toString()}');
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

      // Schedule notification based on planned duration instead of endTime
      if (event.parking.id.isNotEmpty && event.parking.plannedEndTime != null) {
        final reminderTime = event.parking.plannedEndTime!.subtract(const Duration(minutes: 15)); // Restored to 15 minutes for production
        print('DEBUG: Parking created at ${DateTime.now()}');
        print('DEBUG: Planned end time: ${event.parking.plannedEndTime}');
        print('DEBUG: Reminder time: $reminderTime');
        print('DEBUG: Is reminder time in future? ${reminderTime.isAfter(DateTime.now())}');
        
        if (reminderTime.isAfter(DateTime.now())) {
          try {
            final int numericNotificationId = event.parking.id.hashCode;
            print('DEBUG: Scheduling notification with ID: $numericNotificationId');
            await notificationService.scheduleNotificationById(
              id: numericNotificationId,
              title: 'Parking Reminder ⏰',
              body: 'Your parking expires at ${DateFormat.Hm().format(event.parking.plannedEndTime!)}. Don\'t forget to move your vehicle!',
              scheduledTime: reminderTime,
              payload: event.parking.id,
              includeActions: true, // Enable interactive notifications
            );
            print('DEBUG: Notification scheduled successfully');
          } catch (notificationError) {
            // Log notification error but don't fail parking creation
            print('ERROR: Failed to schedule parking reminder: $notificationError');
          }
        } else {
          print('DEBUG: Reminder time is in the past, not scheduling notification');
        }
      } else {
        print('DEBUG: Not scheduling notification - ID empty: ${event.parking.id.isEmpty}, plannedEndTime null: ${event.parking.plannedEndTime == null}');
      }
      emit(const ParkingOperationSuccess('Parking started successfully'));
    } catch (e) {
      emit(ParkingError('Failed to start parking: ${e.toString()}'));
    }
  }
  Future<void> _onExtendParking(ExtendParking event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      // Get the current parking
      final parking = await parkingRepository.getById(event.parkingId);
      
      if (parking != null && parking.plannedDuration != null) {
        // Create updated parking with extended planned duration
        final updatedParking = parking.copyWith(
          plannedDuration: parking.plannedDuration! + event.extensionDuration,
        );
        
        // Update the parking in repository
        await parkingRepository.update(updatedParking.id, updatedParking);
        
        // Cancel the old notification
        final oldNotificationId = event.parkingId.hashCode;
        await notificationService.cancelNotificationById(oldNotificationId);
        
        // Schedule a new notification with the extended time
        if (updatedParking.plannedEndTime != null) {
          final newReminderTime = updatedParking.plannedEndTime!.subtract(const Duration(minutes: 15)); // Restored to 15 minutes for production
          if (newReminderTime.isAfter(DateTime.now())) {
            try {
              await notificationService.scheduleNotificationById(
                id: oldNotificationId,
                title: 'Parking Reminder ⏰',
                body: 'Your parking expires at ${DateFormat.Hm().format(updatedParking.plannedEndTime!)}. Don\'t forget to move your vehicle!',
                scheduledTime: newReminderTime,
                payload: event.parkingId,
                includeActions: true,
              );
            } catch (notificationError) {
              print('Warning: Failed to reschedule parking reminder: $notificationError');
            }
          }
        }
        
        emit(const ParkingOperationSuccess('Parking extended successfully'));
      } else {
        emit(const ParkingError('Parking not found or has no planned duration'));
      }
    } catch (e) {
      emit(ParkingError('Failed to extend parking: ${e.toString()}'));
    }
  }
  
}
