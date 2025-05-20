import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart'; // Assuming path
import 'package:parking_app/blocs/auth/auth_state.dart'; // Assuming path
import 'package:parking_app/blocs/vehicle/vehicle_bloc.dart'; // Assuming path
import 'package:parking_app/blocs/vehicle/vehicle_event.dart'; // Assuming path
import 'package:parking_app/blocs/vehicle/vehicle_state.dart'; // Assuming path
import 'package:parking_app/models/vehicle.dart'; // Assuming path
import 'add_vehicle_screen.dart'; // Assuming path for the BLoC version

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenBlocState();
}

class _VehicleListScreenBlocState extends State<VehicleListScreen> {
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    // Get ownerId from AuthBloc state and dispatch LoadVehicles
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _ownerId = authState.user.personalNumber; // Assuming personalNumber is the ID
      if (_ownerId != null) {
        context.read<VehicleBloc>().add(LoadVehicles(_ownerId!));
      } else {
        // Handle case where user is authenticated but ID is missing (shouldn't happen ideally)
        print("Error: Authenticated user has no personal number.");
      }
    } else {
      // Handle case where user is not authenticated (should ideally be handled by AuthWrapper)
      print("Error: User not authenticated in VehicleListScreen.");
      // Optionally navigate back or show error
    }
  }

  // Helper to reload vehicles, ensuring ownerId is available
  void _reloadVehicles() {
    if (_ownerId != null) {
      context.read<VehicleBloc>().add(LoadVehicles(_ownerId!));
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Vehicle vehicle) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text('Are you sure you want to delete ${vehicle.registrationNumber ?? 'this vehicle'}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Dispatch DeleteVehicle event
                if (vehicle.registrationNumber != null) {
                   // Assuming BLoC uses registration number as ID for deletion
                  context.read<VehicleBloc>().add(DeleteVehicle(vehicle.registrationNumber!));
                } else {
                   print("Error: Cannot delete vehicle without registration number.");
                   // Optionally show a snackbar error
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
      ),
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
            );
          } else if (state is VehicleOperationSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Reload the list after a successful operation
            _reloadVehicles();
          }
        },
        builder: (context, state) {
          if (state is VehicleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VehicleLoaded) {
            if (state.vehicles.isEmpty) {
              return const Center(child: Text('No vehicles found. Add one using the + button.'));
            }
            return ListView.builder(
              itemCount: state.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = state.vehicles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      vehicle.type?.toLowerCase() == 'car'
                          ? Icons.directions_car
                          : Icons.two_wheeler,
                      size: 36,
                    ),
                    title: Text(vehicle.registrationNumber ?? 'Unknown Reg No'),
                    subtitle: Text('Type: ${vehicle.type ?? 'Unknown Type'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Vehicle',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                // Navigate to the BLoC version of AddVehicleScreen
                                builder: (_) => AddVehicleScreen(vehicle: vehicle),
                              ),
                            ).then((_) {
                              // Reload list when returning from edit screen
                              _reloadVehicles();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Vehicle',
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, vehicle);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is VehicleError) {
            // Error is handled by listener's SnackBar, but show a message here too
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load vehicles. Please try again later.\nError: ${state.error}', textAlign: TextAlign.center),
              )
            );
          } else {
            // Initial state or unexpected state
            return const Center(child: Text('Loading vehicles...'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              // Navigate to the BLoC version of AddVehicleScreen
              builder: (_) => const AddVehicleScreen(),
            ),
          ).then((_) {
             // Reload list when returning from add screen
            _reloadVehicles();
          });
        },
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add),
      ),
    );
  }
}