import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../services/auth_service.dart';
import 'add_vehicle_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
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
        _vehicles = userVehicles;
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

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    try {
      final vehicleRepository = Provider.of<VehicleRepository>(context, listen: false);
      await vehicleRepository.delete(vehicle.registreringsnummer!);
      
      // Refresh the list
      await _loadVehicles();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete vehicle: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _vehicles.isEmpty
                  ? const Center(child: Text('No vehicles found. Add a vehicle to get started.'))
                  : ListView.builder(
                      itemCount: _vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              vehicle.type?.toLowerCase() == 'car' 
                                ? Icons.directions_car 
                                : Icons.two_wheeler,
                              size: 36,
                            ),
                            title: Text(vehicle.registreringsnummer ?? 'Unknown'),
                            subtitle: Text('Type: ${vehicle.type ?? 'Unknown'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddVehicleScreen(vehicle: vehicle),
                                      ),
                                    ).then((_) => _loadVehicles());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Vehicle'),
                                        content: const Text('Are you sure you want to delete this vehicle?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _deleteVehicle(vehicle);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddVehicleScreen(),
            ),
          ).then((_) => _loadVehicles());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
