import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../models/parking.dart';
import '../models/parking_space.dart';
import '../models/vehicle.dart';
import '../repositories/firebase_parking_repository.dart';
import '../repositories/firebase_parking_space_repository.dart';
import '../repositories/firebase_vehicle_repository.dart';

class ParkingHistoryScreen extends StatefulWidget {
  final bool showActive;

  const ParkingHistoryScreen({super.key, this.showActive = false});

  @override
  State<ParkingHistoryScreen> createState() => _ParkingHistoryScreenState();
}

class _ParkingHistoryScreenState extends State<ParkingHistoryScreen> {
  List<Parking> _parkings = [];
  Map<String, ParkingSpace> _parkingSpaces = {};
  Map<String, Vehicle> _vehicles = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user from AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess || authState.user.personalNumber == null) {
        setState(() {
          _errorMessage = 'User not found. Please log in again.';
        });
        return;
      }
      
      final currentUser = authState.user;
      
      final parkingRepository = Provider.of<FirebaseParkingRepository>(context, listen: false);
      final parkingSpaceRepository = Provider.of<FirebaseParkingSpaceRepository>(context, listen: false);
      final vehicleRepository = Provider.of<FirebaseVehicleRepository>(context, listen: false);
      
      // Load all data
      final allParkings = widget.showActive 
          ? await parkingRepository.getActiveParking()
          : await parkingRepository.getParkingHistory();
      
      final allParkingSpaces = await parkingSpaceRepository.getAll();
      final allVehicles = await vehicleRepository.getAll();
      
      // Create lookup maps
      final parkingSpacesMap = {for (var space in allParkingSpaces) space.id: space};
      final vehiclesMap = {for (var vehicle in allVehicles) vehicle.id: vehicle}; // use vehicle.id as key
      // Filter parkings for current user's vehicles (by vehicle ID, not registration number)
      final userVehicles = allVehicles.where((v) => v.ownerId == currentUser.personalNumber).toList();
      final userVehicleIds = userVehicles.map((v) => v.id).toList();
      final userParkings = allParkings.where((p) => userVehicleIds.contains(p.vehicleId)).toList();
      // Sort parkings by start time
      await parkingRepository.sortByStartTime(userParkings, ascending: _sortAscending);
      setState(() {
        _parkings = userParkings;
        _parkingSpaces = parkingSpacesMap;
        _vehicles = vehiclesMap;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load parking data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _endParking(Parking parking) async {
    try {
      final parkingRepository = Provider.of<FirebaseParkingRepository>(context, listen: false);
      await parkingRepository.endParking(parking.id);
      
      // Refresh the list
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parking ended successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end parking: ${e.toString()}')),
        );
      }
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
    });
    _loadData();
  }

  String _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return 'Ongoing';
    
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return '$hours h $minutes min';
  }

  double _calculateCost(DateTime start, DateTime? end, double pricePerHour) {
    if (end == null) {
      final now = DateTime.now();
      final duration = now.difference(start);
      final hours = duration.inMinutes / 60.0;
      return hours * pricePerHour;
    } else {
      final duration = end.difference(start);
      final hours = duration.inMinutes / 60.0;
      return hours * pricePerHour;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showActive ? 'Active Parkings' : 'Parking History'),
        actions: [
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _toggleSortOrder,
            tooltip: 'Sort by ${_sortAscending ? 'oldest' : 'newest'} first',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _parkings.isEmpty
                  ? Center(
                      child: Text(
                        widget.showActive
                            ? 'No active parkings found.'
                            : 'No parking history found.'
                      ),
                    )
                  : ListView.builder(
                      itemCount: _parkings.length,
                      itemBuilder: (context, index) {
                        final parking = _parkings[index];
                        final parkingSpace = _parkingSpaces[parking.parkingSpaceId];
                        final vehicle = _vehicles[parking.vehicleId];
                        
                        if (parkingSpace == null || vehicle == null) {
                          return const SizedBox.shrink();
                        }
                        
                        final duration = _formatDuration(parking.startTime, parking.endTime);
                        final cost = _calculateCost(
                          parking.startTime, 
                          parking.endTime, 
                          parkingSpace.pricePerHour
                        );
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Vehicle: ${vehicle.registrationNumber}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    if (parking.endTime == null)
                                      ElevatedButton(
                                        onPressed: () => _endParking(parking),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('End Parking'),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Location: ${parkingSpace.address}'),
                                Text('Start: ${parking.startTime.toString().substring(0, 16)}'),
                                if (parking.endTime != null)
                                  Text('End: ${parking.endTime.toString().substring(0, 16)}'),
                                Text('Duration: $duration'),
                                Text('Cost: ${cost.toStringAsFixed(2)} kr'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
