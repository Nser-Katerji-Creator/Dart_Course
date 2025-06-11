import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/blocs/auth/auth_event.dart';
import 'package:parking_app/blocs/parking_space/parking_space_event.dart';
import 'package:parking_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/api_service.dart';
import 'services/theme_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'blocs/auth/auth_bloc.dart';
import 'blocs/vehicle/vehicle_bloc.dart';
import 'blocs/parking/parking_bloc.dart';
import 'blocs/parking/parking_event.dart';
import 'blocs/parking_space/parking_space_bloc.dart';
import 'repositories/firebase_person_repository.dart';
import 'repositories/firebase_vehicle_repository.dart';
import 'repositories/firebase_parking_repository.dart';
import 'repositories/firebase_parking_space_repository.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_repository.dart';
import 'services/parking_timer_service.dart';

late NotificationService notificationService;
late ParkingTimerService parkingTimerService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize NotificationService
  notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions(); // Request permissions on startup

  runApp(
    MultiProvider(
      providers: [
        ...ApiService.createProviders(),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    // Remove direct repository instantiations, use providers from ApiService
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: themeService.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
      builder: (context, child) {
        // Initialize parking timer service when the app starts
        final parkingRepository = Provider.of<FirebaseParkingRepository>(context, listen: false);
        parkingTimerService = ParkingTimerService(parkingRepository: parkingRepository);
        parkingTimerService.startTimer();
        
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                personRepository: Provider.of<FirebasePersonRepository>(context, listen: false),
                authRepository: Provider.of<FirebaseAuthRepository>(context, listen: false),
              )..add(GetCurrentUser()),
            ),
            BlocProvider<VehicleBloc>(
              create: (context) => VehicleBloc(
                vehicleRepository: Provider.of<FirebaseVehicleRepository>(context, listen: false),
              ),
            ),
            BlocProvider<ParkingBloc>(
              create: (context) {
                final parkingBloc = ParkingBloc(
                  parkingRepository: Provider.of<FirebaseParkingRepository>(context, listen: false),
                  notificationService: notificationService, // Pass the global instance
                );
                
                // Set up notification action handler
                NotificationService.onNotificationAction = (action, parkingId) {
                  print('DEBUG: Handling notification action: $action for parking: $parkingId');
                  switch (action) {
                    case 'extend_parking':
                      print('DEBUG: Dispatching ExtendParking event');
                      parkingBloc.add(ExtendParking(parkingId, const Duration(minutes: 30)));
                      break;
                    case 'end_parking':
                      print('DEBUG: Dispatching EndParking event');
                      parkingBloc.add(EndParking(parkingId));
                      break;
                    default:
                      print('DEBUG: Default notification tap for parking: $parkingId');
                      break;
                  }
                };
                
                return parkingBloc;
              },
            ),
            BlocProvider<ParkingSpaceBloc>(
              create: (context) => ParkingSpaceBloc(
                parkingSpaceRepository: Provider.of<FirebaseParkingSpaceRepository>(context, listen: false),
              )..add(const LoadParkingSpaces()),
            ),
          ],
          child: child!,
        );
      },
    );
  }
}
