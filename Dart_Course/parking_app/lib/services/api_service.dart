import 'package:http/http.dart' as http;
import 'package:parking_app/services/firebase_auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../repositories/firebase_person_repository.dart';
import '../repositories/firebase_vehicle_repository.dart';
import '../repositories/firebase_parking_repository.dart';
import '../repositories/firebase_parking_space_repository.dart';
import '../services/auth_service.dart';

class ApiService {
 // static const String baseUrl = 'http://10.0.2.2:8080'; // For Android emulator
   static const String baseUrl = 'http://localhost:8080'; // For iOS simulator
  
  final http.Client client = http.Client();
  late final FirebasePersonRepository personRepository;
  late final FirebaseVehicleRepository vehicleRepository;
  late final FirebaseParkingRepository parkingRepository;
  late final FirebaseParkingSpaceRepository parkingSpaceRepository;
  late final AuthService authService;
  
  ApiService() {
    personRepository = FirebasePersonRepository();
    vehicleRepository = FirebaseVehicleRepository();
    parkingRepository = FirebaseParkingRepository();
    parkingSpaceRepository = FirebaseParkingSpaceRepository();
    authService = AuthService();
  }
  
  // Helper method to create providers
  static List<SingleChildWidget> createProviders() {
    final apiService = ApiService();
    
    return [
      Provider<ApiService>.value(value: apiService),
      Provider<FirebasePersonRepository>.value(value: apiService.personRepository),
      Provider<FirebaseVehicleRepository>.value(value: apiService.vehicleRepository),
      Provider<FirebaseParkingRepository>.value(value: apiService.parkingRepository),
      Provider<FirebaseParkingSpaceRepository>.value(value: apiService.parkingSpaceRepository),
      Provider<AuthService>.value(value: apiService.authService),
      Provider<FirebaseAuthRepository>.value(value: FirebaseAuthRepository()),
    ];
  }
}
