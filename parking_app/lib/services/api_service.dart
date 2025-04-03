import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../repositories/person_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../repositories/parking_repository.dart';
import '../repositories/parking_space_repository.dart';
import '../services/auth_service.dart';

class ApiService {
 // static const String baseUrl = 'http://10.0.2.2:8080'; // For Android emulator
   static const String baseUrl = 'http://localhost:8080'; // For iOS simulator
  
  final http.Client client = http.Client();
  late final PersonRepository personRepository;
  late final VehicleRepository vehicleRepository;
  late final ParkingRepository parkingRepository;
  late final ParkingSpaceRepository parkingSpaceRepository;
  late final AuthService authService;
  
  ApiService() {
    personRepository = PersonRepository(baseUrl: baseUrl, client: client);
    vehicleRepository = VehicleRepository(baseUrl: baseUrl, client: client);
    parkingRepository = ParkingRepository(baseUrl: baseUrl, client: client);
    parkingSpaceRepository = ParkingSpaceRepository(baseUrl: baseUrl, client: client);
    authService = AuthService();
  }
  
  // Helper method to create providers
  static List<SingleChildWidget> createProviders() {
    final apiService = ApiService();
    
    return [
      Provider<ApiService>.value(value: apiService),
      Provider<PersonRepository>.value(value: apiService.personRepository),
      Provider<VehicleRepository>.value(value: apiService.vehicleRepository),
      Provider<ParkingRepository>.value(value: apiService.parkingRepository),
      Provider<ParkingSpaceRepository>.value(value: apiService.parkingSpaceRepository),
      Provider<AuthService>.value(value: apiService.authService),
    ];
  }
}
