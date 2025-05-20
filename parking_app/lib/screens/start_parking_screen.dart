import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart';
import 'package:parking_app/blocs/auth/auth_state.dart';
import 'package:parking_app/blocs/parking/parking_bloc.dart';
import 'package:parking_app/blocs/parking/parking_event.dart';
import 'package:parking_app/blocs/parking/parking_state.dart';
import 'package:parking_app/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app/blocs/vehicle/vehicle_state.dart';
import 'package:parking_app/models/parking.dart';
import 'package:parking_app/models/parking_space.dart';
import 'package:parking_app/models/vehicle.dart';
import 'package:uuid/uuid.dart';

class StartParkingScreen extends StatefulWidget {
  final ParkingSpace parkingSpace;

  const StartParkingScreen({super.key, required this.parkingSpace});

  @override
  State<StartParkingScreen> createState() => _StartParkingScreenState();
}

class _StartParkingScreenState extends State<StartParkingScreen> {
  Vehicle? _selectedVehicle;
  String? _userId;
  // Removed local loading/error states, handled by BLoCs

  @override
  void initState() {
    super.initState();
    // Get user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _userId = authState.user.personalNumber; // Assuming personalNumber is the ID
      if (_userId != null) {
        // Dispatch event to load user's vehicles
        context.read<VehicleBloc>().add(LoadVehicles(_userId!));
      } else {
        _handleAuthError("User ID not found.");
      }
    } else {
      _handleAuthError("User not authenticated.");
    }
  }

  void _handleAuthError(String message) {
    print("Error in StartParkingScreen: $message");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop(); // Go back if user info is missing
      }
    });
  }

  void _startParking(BuildContext context) {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedVehicle!.registrationNumber == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected vehicle has no registration number'), backgroundColor: Colors.red),
      );
      return;
    }

    // Create a new parking object
    final newParking = Parking(
      id: const Uuid().v4(), // ID generation might happen in BLoC/Repo
      vehicleId: _selectedVehicle!.id, // FIX: Use vehicle.id, not registrationNumber
      parkingSpaceId: widget.parkingSpace.id,
      startTime: DateTime.now(),
      // endTime and cost are null initially
    );

    // Dispatch StartParking event
    context.read<ParkingBloc>().add(StartParking(newParking));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Parking'),
      ),
      // Use BlocConsumer for ParkingBloc to handle parking actions and feedback
      body: BlocConsumer<ParkingBloc, ParkingState>(
        listener: (context, parkingState) {
          if (parkingState is ParkingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(parkingState.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(); // Go back on success
          } else if (parkingState is ParkingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Parking Error: ${parkingState.error}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, parkingState) {
          final isParkingActionLoading = parkingState is ParkingLoading; // Loading state for parking action

          // Use BlocBuilder for VehicleBloc to get the list of vehicles
          return BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, vehicleState) {
              // Handle vehicle loading state
              if (vehicleState is VehicleLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // Handle vehicle error state
              else if (vehicleState is VehicleError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load vehicles: ${vehicleState.error}', textAlign: TextAlign.center),
                  ),
                );
              }
              // Handle vehicle loaded state
              else if (vehicleState is VehicleLoaded) {
                final userVehicles = vehicleState.vehicles;

                // Set default selected vehicle if not already set and list is not empty
                if (_selectedVehicle == null && userVehicles.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                     if (mounted) {
                        setState(() {
                          _selectedVehicle = userVehicles.first;
                        });
                     }
                  });
                }

                if (userVehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('You don\'t have any vehicles. Add a vehicle first.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                // Main content when vehicles are loaded
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display Parking Space Info
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parking Space',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('Address: ${widget.parkingSpace.address}'),
                              Text('Price: ${widget.parkingSpace.pricePerHour.toStringAsFixed(2)} kr/h'),
                            ],
                          ),
                        ),
                      ),
                      // Select Vehicle Dropdown
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Vehicle',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<Vehicle>(
                                value: _selectedVehicle,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select your vehicle',
                                ),
                                items: userVehicles.map((vehicle) {
                                  return DropdownMenuItem<Vehicle>(
                                    value: vehicle,
                                    child: Text('${vehicle.registrationNumber ?? 'No Reg#'} (${vehicle.type ?? 'N/A'})'),
                                  );
                                }).toList(),
                                onChanged: isParkingActionLoading ? null : (Vehicle? value) {
                                  setState(() {
                                    _selectedVehicle = value;
                                  });
                                },
                                // Add validation if needed
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(), // Pushes button to the bottom
                      // Start Parking Button
                      ElevatedButton(
                        onPressed: isParkingActionLoading ? null : () => _startParking(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isParkingActionLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Start Parking'),
                      ),
                      const SizedBox(height: 16), // Spacing at the bottom
                    ],
                  ),
                );
              }
              // Fallback for initial or unexpected vehicle state
              else {
                return const Center(child: Text('Loading vehicle information...'));
              }
            },
          );
        },
      ),
    );
  }
}

