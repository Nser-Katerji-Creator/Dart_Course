import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:provider/provider.dart'; // Keep for ThemeService if needed
import '../blocs/auth/auth_bloc.dart'; // Import AuthBloc
import '../blocs/auth/auth_event.dart'; // Import AuthEvent
import '../blocs/auth/auth_state.dart'; // Import AuthState
import '../services/theme_service.dart'; // Keep for ThemeService
// Import screens for navigation
import 'login_screen.dart'; // Needed for logout navigation fallback
import 'vehicle_list_screen.dart';
import 'parking_spaces_screen.dart';
import 'parking_history_screen.dart';
import 'notification_debug_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeService can still be accessed via Provider if needed
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
          // Use BlocListener or AuthWrapper to handle logout navigation
          // Button dispatches event
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Dispatch Logout event
              context.read<AuthBloc>().add(LogoutRequested());
              // Navigation might be handled by AuthWrapper or a listener elsewhere
              // As a fallback, navigate here, but ideally handled globally
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(builder: (context) => const LoginScreen()),
              //   (Route<dynamic> route) => false,
              // );
            },
          ),
        ],
      ),
      // Use BlocBuilder to react to AuthState changes
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Show loading indicator while checking auth state initially
          // Note: AuthWrapper might handle initial loading/redirect
          if (state is AuthInitial || state is AuthLoading) {
             return const Center(child: CircularProgressIndicator());
          }
          // If authenticated, show the home screen content
          else if (state is AuthSuccess) {
            final user = state.user;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}!', // Display user name from AuthSuccess state
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          'My Vehicles',
                          Icons.directions_car,
                          Colors.blue,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const VehicleListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          context,
                          'Parking Spaces',
                          Icons.local_parking,
                          Colors.green,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ParkingSpacesScreen(), // Needs BLoC update later
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          context,
                          'Parking History',
                          Icons.history,
                          Colors.orange,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ParkingHistoryScreen(), // Needs BLoC update later
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          context,
                          'Active Parkings',
                          Icons.timer,
                          Colors.purple,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                // Pass flag to ParkingHistoryScreen BLoC version
                                builder: (context) => const ParkingHistoryScreen(showActive: true), // Needs BLoC update later
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          context,
                          'Debug Notifications',
                          Icons.notifications_active,
                          Colors.red,
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NotificationDebugScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          // If not authenticated (AuthFailure or other state), show error or redirect
          // Note: AuthWrapper should ideally handle redirection before reaching HomeScreen
          else {
             // This part might not be reached if AuthWrapper handles redirection
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text('Authentication failed or user logged out.'),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () {
                       // Navigate back to Login
                       Navigator.of(context).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (context) => const LoginScreen()),
                         (Route<dynamic> route) => false,
                       );
                     },
                     child: const Text('Go to Login'),
                   ),
                 ],
               ),
             );
          }
        },
      ),
    );
  }

  // _buildMenuCard remains the same
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

