import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart';
import 'package:parking_app/blocs/auth/auth_event.dart';
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/models/person.dart'; // Needed for creating Person object
import 'package:uuid/uuid.dart'; // Keep if ID generation is needed here
import 'home_screen.dart'; // For navigation on success

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _personalNumberController = TextEditingController();
  // Removed _isLoading and _errorMessage, handled by BLoC state

  @override
  void dispose() {
    _nameController.dispose();
    _personalNumberController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final personalNumber = _personalNumberController.text.trim();

    // Create a Person object - ID generation might happen in BLoC/Repo
    final newUser = Person(
      id: const Uuid().v4(), // Or let BLoC/Repo handle ID
      name: name,
      personalNumber: personalNumber,
    );

    // Dispatch RegisterRequested event
    context.read<AuthBloc>().add(RegisterRequested(newUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      // Use BlocConsumer to listen for state changes and build UI
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to HomeScreen on successful registration
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          } else if (state is AuthFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration Failed: ${state.error}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                      // Add more specific validation if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    // Disable button when loading
                    onPressed: isLoading ? null : () => _register(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Register'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading ? null : () {
                      // Navigate back to Login screen
                      Navigator.of(context).pop();
                    },
                    child: const Text('Already have an account? Login'),
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
