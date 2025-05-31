import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/auth/auth_bloc.dart'; // Assuming path
import 'package:parking_app/blocs/auth/auth_state.dart'; // Assuming path
import 'package:parking_app/blocs/vehicle/vehicle_bloc.dart'; // Assuming path
import 'package:parking_app/blocs/vehicle/vehicle_event.dart'; // Assuming path
import 'package:parking_app/blocs/vehicle/vehicle_state.dart'; // Assuming path
import 'package:parking_app/models/vehicle.dart'; // Assuming path
import 'package:uuid/uuid.dart'; // Keep for generating ID if needed by BLoC event

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle; // Vehicle to edit, if any

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenBlocState();
}

class _AddVehicleScreenBlocState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();
  final _typeController = TextEditingController();
  // Removed _isLoading and _errorMessage
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    // Get ownerId from AuthBloc state
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _ownerId = authState.user.personalNumber; // Assuming personalNumber is the ID
    } else {
      // Handle user not authenticated - ideally AuthWrapper prevents this screen access
      print("Error: User not authenticated in AddVehicleScreen.");
      // Optionally show error and pop screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please log in again.'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      });
    }

    // Pre-fill form if editing an existing vehicle
    if (widget.vehicle != null) {
      _registrationNumberController.text = widget.vehicle!.registrationNumber ?? '';
      _typeController.text = widget.vehicle!.type ?? '';
    }
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_ownerId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save vehicle: User ID not found.'), backgroundColor: Colors.red),
        );
       return;
    }
    
    if (_formKey.currentState!.validate()) {
      final registrationNumber = _registrationNumberController.text.trim();
      final type = _typeController.text.trim();

      if (widget.vehicle == null) {
        // Dispatch AddVehicle event
        final newVehicle = Vehicle(
          id: const Uuid().v4(), // Generate ID here or let BLoC/Repo handle it
          registrationNumber: registrationNumber,
          type: type,
          ownerId: _ownerId!, 
        );
        print("Dispatching AddVehicle event for: ${newVehicle.registrationNumber}");
        context.read<VehicleBloc>().add(AddVehicle(newVehicle));
      } else {
        // Dispatch UpdateVehicle event
        final updatedVehicle = Vehicle(
          id: widget.vehicle!.id, // Use existing ID
          registrationNumber: registrationNumber, // Reg number might be ID used in BLoC
          type: type,
          ownerId: _ownerId!, // Owner ID might not change, but include if needed
        );
         print("Dispatching UpdateVehicle event for: ${updatedVehicle.registrationNumber}");
        // Assuming BLoC's UpdateVehicle uses the original reg number to find the vehicle
        context.read<VehicleBloc>().add(UpdateVehicle(widget.vehicle!.registrationNumber!, updatedVehicle));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      // Use BlocListener for side effects (navigation, snackbars)
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(); // Go back after successful operation
          } else if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _registrationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter registration number';
                    }
                    return null;
                  },
                  // Prevent editing registration number if updating an existing vehicle
                  // Assuming registration number is the unique identifier
                  readOnly: widget.vehicle != null, 
                  style: widget.vehicle != null ? TextStyle(color: Colors.grey[600]) : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Car, Motorcycle',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vehicle type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Use BlocBuilder to handle the button's loading state
                BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (context, state) {
                    final isLoading = state is VehicleLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _saveVehicle,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(widget.vehicle == null ? 'Add Vehicle' : 'Update Vehicle'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}