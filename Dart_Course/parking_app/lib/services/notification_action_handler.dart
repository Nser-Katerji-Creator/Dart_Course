import '../blocs/parking/parking_bloc.dart';
import '../blocs/parking/parking_event.dart';

class NotificationActionHandler {
  static void handleNotificationAction(String action, String parkingId, ParkingBloc parkingBloc) {
    switch (action) {
      case 'extend_parking':
        // Extend parking by 30 minutes (default extension)
        parkingBloc.add(
          ExtendParking(parkingId, const Duration(minutes: 30))
        );
        break;
      case 'end_parking':
        // End the parking session
        parkingBloc.add(
          EndParking(parkingId)
        );
        break;
      default:
        // Handle default notification tap
        print('Notification tapped for parking: $parkingId');
        break;
    }
  }
}
