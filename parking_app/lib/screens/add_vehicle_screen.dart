import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../services/auth_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();
  final _typeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _registrationNumberController.text = widget.vehicle!.registreringsnummer ?? '';
      _typeController.text = widget.vehicle!.type ?? '';
    }
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final registrationNumber = _registrationNumberController.text.trim();
      final type = _typeController.text.trim();
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final vehicleRepository = Provider.of<VehicleRepository>(context, listen: false);
      
      final currentUser = await authService.getCurrentUser();
      if (currentUser == null || currentUser.personalNumber == null) {
        setState(() {
          _errorMessage = 'User not found. Please log in again.';
        });
        return;
      }
      
      final ownerId = currentUser.personalNumber!;
      
      if (widget.vehicle == null) {
        // Create new vehicle
        final newVehicle = Vehicle(
          id: Uuid().v4(),
          registreringsnummer: registrationNumber,
          type: type,
          ownerId: ownerId,
        );
        await vehicleRepository.create(newVehicle);
      } else {
        // Update existing vehicle
        final updatedVehicle = Vehicle(
          id: widget.vehicle!.id,
          registreringsnummer: registrationNumber,
          type: type,
          ownerId: ownerId,
        );
        await vehicleRepository.update(widget.vehicle!.registreringsnummer!, updatedVehicle);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save vehicle: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Padding(
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
                readOnly: widget.vehicle != null, // Can't change registration number when editing
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
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVehicle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.vehicle == null ? 'Add Vehicle' : 'Update Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
