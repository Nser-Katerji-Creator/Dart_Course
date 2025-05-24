import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart';
import 'package:parking_app/blocs/auth/auth_event.dart';
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/screens/home_screen.dart';
import 'package:parking_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Failed: \\${state.error}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthSuccess) {
            if (kDebugMode) {
              print("LoginScreen: AuthSuccess detected, navigating to HomeScreen.");
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state is AuthRequirePersonalNumber) {
            // Prompt for personal number and dispatch CompleteGitHubRegistration
            final personalNumber = await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                final controller = TextEditingController();
                return AlertDialog(
                  title: const Text('Complete Registration'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Personal Number',
                      hintText: 'YYYYMMDD-XXXX',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.of(context).pop(controller.text.trim());
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );
            if (personalNumber != null && personalNumber.isNotEmpty) {
              context.read<AuthBloc>().add(
                CompleteGitHubRegistration(
                  uid: state.uid,
                  name: state.name,
                  email: state.email,
                  personalNumber: personalNumber,
                ),
              );
            }
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
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@email.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              context.read<AuthBloc>().add(
                                    LoginRequested(email, password),
                                  );
                            }
                          },
                    child: isLoading
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
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(GitHubSignInRequested());
                          },
                    child: const Text('Sign in with GitHub'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (kDebugMode) {
                              print("LoginScreen: Navigating to RegisterScreen.");
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
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
