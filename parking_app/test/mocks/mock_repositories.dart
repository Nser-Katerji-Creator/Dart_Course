import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:parking_app/repositories/vehicle_repository.dart';
import 'package:parking_app/repositories/parking_repository.dart';
import 'package:parking_app/repositories/parking_space_repository.dart';
import 'package:parking_app/repositories/person_repository.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/screens/login_screen.dart';
import 'package:parking_app/screens/register_screen.dart';
import 'package:parking_app/services/theme_service.dart';
import 'package:provider/provider.dart';


// Mock HTTP Client
class MockHttpClient extends Mock implements http.Client {}

// Mock Repositories
class MockVehicleRepository extends Mock implements VehicleRepository {}
class MockParkingRepository extends Mock implements ParkingRepository {}
class MockParkingSpaceRepository extends Mock implements ParkingSpaceRepository {}
class MockPersonRepository extends Mock implements PersonRepository {}
void main() {
  testWidgets('Login screen loads correctly', (WidgetTester tester) async {
    final mockHttpClient = MockHttpClient();

    // Mock the HTTP response
    when(() => mockHttpClient.get(any())).thenAnswer(
      (_) async => http.Response('{"success": true}', 200),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeService>(
            create: (_) => ThemeService(),
          ),
          Provider<http.Client>(
            create: (_) => mockHttpClient,
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the login screen is displayed
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Don\'t have an account? Register'), findsOneWidget);
    
  });
}