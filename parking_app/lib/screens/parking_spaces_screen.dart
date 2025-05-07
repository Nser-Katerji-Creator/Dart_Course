import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_app/blocs/parking_space/parking_space_event.dart';
import 'package:parking_app/blocs/parking_space/parking_space_state.dart';
import 'package:parking_app/models/parking_space.dart';
import 'start_parking_screen.dart'; // Needs BLoC update later

class ParkingSpacesScreen extends StatefulWidget {
  const ParkingSpacesScreen({super.key});

  @override
  State<ParkingSpacesScreen> createState() => _ParkingSpacesScreenState();
}

class _ParkingSpacesScreenState extends State<ParkingSpacesScreen> {
  // Keep local state for filtering
  List<ParkingSpace> _allParkingSpaces = [];
  List<ParkingSpace> _filteredParkingSpaces = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch event to load parking spaces
    context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());
    _searchController.addListener(_filterParkingSpaces);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterParkingSpaces);
    _searchController.dispose();
    super.dispose();
  }

  void _filterParkingSpaces() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredParkingSpaces = _allParkingSpaces;
      } else {
        _filteredParkingSpaces = _allParkingSpaces.where((space) =>
          space.address.toLowerCase().contains(query) ||
          space.id.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Spaces'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search parking spaces (by address or ID)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // onChanged is handled by the listener
            ),
          ),
          Expanded(
            // Use BlocBuilder to react to ParkingSpaceState
            child: BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
              builder: (context, state) {
                if (state is ParkingSpaceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ParkingSpacesLoaded) {
                  // Update local lists when data is loaded
                  // This should only happen once unless data reloads
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _allParkingSpaces != state.parkingSpaces) {
                       setState(() {
                         _allParkingSpaces = state.parkingSpaces;
                         // Apply current filter
                         _filterParkingSpaces();
                       });
                    }
                  });

                  if (_filteredParkingSpaces.isEmpty) {
                    return Center(child: Text(_searchController.text.isEmpty ? 'No parking spaces available.' : 'No parking spaces match your search.'));
                  }

                  return ListView.builder(
                    itemCount: _filteredParkingSpaces.length,
                    itemBuilder: (context, index) {
                      final parkingSpace = _filteredParkingSpaces[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.local_parking, size: 36),
                          title: Text(parkingSpace.address),
                          subtitle: Text('Price: ${parkingSpace.pricePerHour.toStringAsFixed(2)} kr/h'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  // Pass the selected parking space to the next screen
                                  builder: (context) => StartParkingScreen(parkingSpace: parkingSpace),
                                ),
                              );
                            },
                            child: const Text('Park Here'),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ParkingSpaceError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Failed to load parking spaces. \nError: ${state.error}', textAlign: TextAlign.center),
                    ),
                  );
                } else {
                  // Initial state
                  return const Center(child: Text('Loading parking spaces...'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
