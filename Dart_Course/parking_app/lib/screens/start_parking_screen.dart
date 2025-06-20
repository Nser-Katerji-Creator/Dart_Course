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
  Duration? _selectedDuration;
  
  // Slider-based duration configuration
  double _durationMinutes = 60.0; // Default 1 hour in minutes
  static const double _minDurationMinutes = 15.0; // Minimum 15 minutes
  static const double _maxDurationMinutes = 480.0; // Maximum 8 hours (480 minutes)
  // Removed local loading/error states, handled by BLoCs

  @override
  void initState() {
    super.initState();
    _selectedDuration = Duration(minutes: _durationMinutes.round()); // Set default duration from slider

    // Get user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _userId = authState.user.personalNumber;
      if (_userId != null) {
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

  // Helper method to format duration from minutes to human-readable text
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()} min';
    } else {
      final hours = minutes / 60;
      if (minutes % 60 == 0) {
        final h = hours.round();
        return h == 1 ? '1 hour' : '${h} hours';
      } else {
        final h = hours.floor();
        final m = (minutes % 60).round();
        return '${h}h ${m}m';
      }
    }
  }

  // Helper method to build quick duration selection buttons
  Widget _buildQuickDurationButton(String text, double minutes) {
    final isSelected = _durationMinutes == minutes;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _durationMinutes = minutes;
          _selectedDuration = Duration(minutes: minutes.round());
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        foregroundColor: isSelected ? Theme.of(context).primaryColor : null,
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
        ),
      ),
      child: Text(text),
    );
  }

  void _startParking(BuildContext context) {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle'), backgroundColor: Colors.orange),
      );
      return;
    }
    // Add this check:
    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a parking duration'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedVehicle!.registrationNumber == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected vehicle has no registration number'), backgroundColor: Colors.red),
      );
      return;
    }

    final DateTime startTime = DateTime.now();
    // Note: endTime should be null for active parkings, only set when parking actually ends
    // Store the planned duration for notifications and other purposes

    final newParking = Parking(
      id: const Uuid().v4(),
      vehicleId: _selectedVehicle!.id,
      parkingSpaceId: widget.parkingSpace.id,
      startTime: startTime,
      endTime: null, // Keep null for active parkings
      plannedDuration: _selectedDuration, // Store planned duration separately
    );

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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display Parking Space Info
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parking Space',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text('Address: ${widget.parkingSpace.address}'),
                              Text('Price: ${widget.parkingSpace.pricePerHour.toStringAsFixed(2)} kr/h'),
                            ],
                          ),
                        ),
                      ),
                      // Select Vehicle Dropdown
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Vehicle',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
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
                      // Select Duration Slider
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Duration',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              // Duration display
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Duration: ${_formatDuration(_durationMinutes)}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Icon(Icons.access_time, color: Colors.grey.shade600),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Duration slider
                              Column(
                                children: [
                                  Slider(
                                    value: _durationMinutes,
                                    min: _minDurationMinutes,
                                    max: _maxDurationMinutes,
                                    divisions: (((_maxDurationMinutes - _minDurationMinutes) / 15).round()), // 15-minute increments
                                    label: _formatDuration(_durationMinutes),
                                    onChanged: isParkingActionLoading ? null : (double value) {
                                      setState(() {
                                        _durationMinutes = value;
                                        _selectedDuration = Duration(minutes: value.round());
                                      });
                                    },
                                  ),
                                  // Quick duration buttons
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _buildQuickDurationButton('30m', 30),
                                      _buildQuickDurationButton('1h', 60),
                                      _buildQuickDurationButton('2h', 120),
                                      _buildQuickDurationButton('4h', 240),
                                      _buildQuickDurationButton('8h', 480),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Add some spacing before the button
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 8), // Reduced spacing at the bottom
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

