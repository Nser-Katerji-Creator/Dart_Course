// From auth_widget_examples.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart';
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/screens/home_screen.dart';
import 'package:parking_app/screens/login_screen.dart';

// IMPORTANT: This widget is crucial for handling navigation based on auth state.
// It should wrap the part of your app where authentication matters (e.g., MaterialApp home).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to rebuild the UI based on AuthState
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          // User is logged in, SHOW the HomeScreen
          // Navigation happens because this widget rebuilds and returns HomeScreen.
          if (kDebugMode) {
            print("AuthWrapper: AuthSuccess state detected, showing HomeScreen.");
          }
          return HomeScreen();
        } else if (state is LoggedOut || state is AuthInitial || state is AuthFailure) {
          // User is logged out or initial state, SHOW the LoginScreen
          // Navigation happens because this widget rebuilds and returns LoginScreen.
          if (kDebugMode) {
            print("AuthWrapper: LoggedOut/AuthInitial/AuthFailure state detected, showing LoginScreen.");
          }
          return LoginScreen();
        } else {
          // AuthLoading state, show a loading indicator
          if (kDebugMode) {
            print("AuthWrapper: AuthLoading state detected, showing loading indicator.");
          }
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
