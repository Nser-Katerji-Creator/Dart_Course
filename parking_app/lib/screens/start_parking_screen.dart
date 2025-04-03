import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/parking.dart';
import '../models/parking_space.dart';
import '../models/vehicle.dart';
import '../repositories/parking_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../services/auth_service.dart';

class StartParkingScreen extends StatefulWidget {
  final ParkingSpace parkingSpace;

  const StartParkingScreen({super.key, required this.parkingSpace});

  @override
  State<StartParkingScreen> createState() => _StartParkingScreenState();
}

class _StartParkingScreenState extends State<StartParkingScreen> {
  List<Vehicle> _userVehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = true;
  bool _isStartingParking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
  }

  Future<void> _loadUserVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vehicleRepository = Provider.of<VehicleRepository>(context, listen: false);
      
      final currentUser = await authService.getCurrentUser();
      if (currentUser == null || currentUser.personalNumber == null) {
        setState(() {
          _errorMessage = 'User not found. Please log in again.';
        });
        return;
      }
      
      // Get vehicles for the current user
      final vehicles = await vehicleRepository.getAll();
      final userVehicles = vehicles.where((v) => 
        v.ownerId.toString() == currentUser.personalNumber).toList();
      
      setState(() {
        _userVehicles = userVehicles;
        if (userVehicles.isNotEmpty) {
          _selectedVehicle = userVehicles.first;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load vehicles: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startParking() async {
    if (_selectedVehicle == null) {
      setState(() {
        _errorMessage = 'Please select a vehicle';
      });
      return;
    }

    setState(() {
      _isStartingParking = true;
      _errorMessage = null;
    });

    try {
      final parkingRepository = Provider.of<ParkingRepository>(context, listen: false);
      
      // Create a new parking
      final parking = Parking(
        id: Uuid().v4(),
        vehicleId: _selectedVehicle!.registreringsnummer!,
        parkingSpaceId: widget.parkingSpace.id,
        startTime: DateTime.now(),
      );
      
      await parkingRepository.create(parking);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parking started successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start parking: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isStartingParking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Parking'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _userVehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('You don\'t have any vehicles. Add a vehicle first.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                  Text('Price: ${widget.parkingSpace.pricePerHour} kr/h'),
                                ],
                              ),
                            ),
                          ),
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
                                    ),
                                    items: _userVehicles.map((vehicle) {
                                      return DropdownMenuItem<Vehicle>(
                                        value: vehicle,
                                        child: Text('${vehicle.registreringsnummer} (${vehicle.type})'),
                                      );
                                    }).toList(),
                                    onChanged: (Vehicle? value) {
                                      setState(() {
                                        _selectedVehicle = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                            onPressed: _isStartingParking ? null : _startParking,
                            child: _isStartingParking
                                ? const CircularProgressIndicator()
                                : const Text('Start Parking'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
