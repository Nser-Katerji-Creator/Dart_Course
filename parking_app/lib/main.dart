import 'package:flutter/material.dart';
import 'package:parking_app/blocs/auth/auth_event.dart';
import 'package:parking_app/blocs/parking_space/parking_space_event.dart';
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
import 'blocs/parking_space/parking_space_bloc.dart';
import 'repositories/person_repository.dart';
import 'repositories/vehicle_repository.dart';
import 'repositories/parking_repository.dart';
import 'repositories/parking_space_repository.dart';

void main() {
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
        final client = http.Client();
    final baseUrl = 'http://localhost:8080';
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            personRepository: PersonRepository(
              baseUrl: baseUrl,
              client: client,
            ),
          )..add(GetCurrentUser()),
        ),
        BlocProvider<VehicleBloc>(
          create: (context) => VehicleBloc(
            vehicleRepository: VehicleRepository(
              baseUrl: baseUrl,
              client: client,
            ),
          ),
        ),
        BlocProvider<ParkingBloc>(
          create: (context) => ParkingBloc(
            parkingRepository: ParkingRepository(
              baseUrl: baseUrl,
              client: client,
            ),
          ),
        ),
        BlocProvider<ParkingSpaceBloc>(
          create: (context) => ParkingSpaceBloc(
            parkingSpaceRepository: ParkingSpaceRepository(
              baseUrl: baseUrl,
              client: client,
            ),
          )..add(const LoadParkingSpaces()),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
