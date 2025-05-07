import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart'; // Assuming path
import 'package:parking_app/blocs/auth/auth_event.dart'; // Assuming path
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/repositories/person_repository.dart';
import 'package:parking_app/screens/home_screen.dart';
import 'package:parking_app/screens/register_screen.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:provider/provider.dart'; // Assuming path
// Import your RegisterScreen and potentially HomeScreen if AuthWrapper isn't used
// import 'register_screen.dart';
// import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personalNumberController = TextEditingController();

  @override
  void dispose() {
    _personalNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          // --- Direct Navigation Implementation ---
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Failed: ${state.error}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthSuccess) {
            // Navigate to HomeScreen directly from the listener on success
            if (kDebugMode) {
              print(
                "LoginScreen: AuthSuccess detected, navigating to HomeScreen.",
              );
            }
            try {
              final personalNumber = _personalNumberController.text.trim();
              final personRepository = Provider.of<PersonRepository>(
                context,
                listen: false,
              );
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );

              final person = await personRepository.getByPersonalNumber(
                personalNumber,
              );

              if (person != null) {
                await authService.saveUser(person);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              } else {
                setState(() {
                });
              }
            } catch (e) {
              setState(() {
              });
            } finally {
              setState(() {
              });
            }
          }
          // --- End Direct Navigation ---
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _personalNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Personal Number',
                      hintText: 'YYYYMMDD-XXXX',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your personal number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                final personalNumber =
                                    _personalNumberController.text.trim();
                                context.read<AuthBloc>().add(
                                  LoginRequested(personalNumber),
                                );
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              // --- Direct Navigation to Register Screen ---
                              print(
                                "LoginScreen: Navigating to RegisterScreen.",
                              );
                              // Replace MockRegisterScreen with your actual RegisterScreen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                              // --- End Direct Navigation ---
                            },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
