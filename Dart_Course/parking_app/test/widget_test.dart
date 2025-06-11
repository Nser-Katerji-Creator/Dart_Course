import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/services/theme_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Wrap MyApp with ChangeNotifierProvider for ThemeService
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeService>(
        create: (_) => ThemeService(),
        child: const MyApp(),
      ),
    );

    // Verify that the app starts correctly
   // Verify that the AppBar title is "Login"
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Verify that the "Register" button exists
    expect(find.widgetWithText(TextButton, 'Don\'t have an account? Register'), findsOneWidget);

    // Tap the '+' icon and trigger a frame
    //await tester.tap(find.byIcon(Icons.add));
   //await tester.pump();

    // Verify that the counter increments
   // Verify that the AppBar title is "Login"
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Verify that the "Register" button exists
    expect(find.widgetWithText(TextButton, 'Don\'t have an account? Register'), findsOneWidget);
  });
}