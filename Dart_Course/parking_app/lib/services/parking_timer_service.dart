import 'dart:async';
import '../repositories/firebase_parking_repository.dart';
import '../models/parking.dart';

class ParkingTimerService {
  final FirebaseParkingRepository parkingRepository;
  Timer? _timer;
  static const Duration checkInterval = Duration(minutes: 1); // Check every minute

  ParkingTimerService({required this.parkingRepository});

  void startTimer() {
    print('DEBUG: Starting parking timer service');
    _timer = Timer.periodic(checkInterval, (timer) {
      _checkExpiredParkings();
    });
  }

  void stopTimer() {
    print('DEBUG: Stopping parking timer service');
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkExpiredParkings() async {
    try {
      print('DEBUG: Checking for expired parkings at ${DateTime.now()}');
      
      // Get all active parkings
      final activeParkings = await parkingRepository.getActiveParking();
      final now = DateTime.now();
      
      for (final parking in activeParkings) {
        if (parking.plannedEndTime != null && now.isAfter(parking.plannedEndTime!)) {
          print('DEBUG: Found expired parking: ${parking.id}, planned end: ${parking.plannedEndTime}');
          
          // Create updated parking with actual end time
          final expiredParking = parking.copyWith(
            endTime: parking.plannedEndTime, // Use planned end time as actual end time
          );
          
          // Update the parking in the repository
          await parkingRepository.update(parking.id, expiredParking);
          print('DEBUG: Automatically ended parking: ${parking.id}');
        }
      }
    } catch (e) {
      print('ERROR: Failed to check expired parkings: $e');
    }
  }

  // Manual method to check and end expired parkings immediately
  Future<void> checkExpiredParkingsNow() async {
    await _checkExpiredParkings();
  }
}
