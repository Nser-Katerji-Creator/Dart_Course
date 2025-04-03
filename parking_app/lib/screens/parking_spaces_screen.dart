import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking_space.dart';
import '../repositories/parking_space_repository.dart';
import 'start_parking_screen.dart';

class ParkingSpacesScreen extends StatefulWidget {
  const ParkingSpacesScreen({super.key});

  @override
  State<ParkingSpacesScreen> createState() => _ParkingSpacesScreenState();
}

class _ParkingSpacesScreenState extends State<ParkingSpacesScreen> {
  List<ParkingSpace> _parkingSpaces = [];
  List<ParkingSpace> _filteredParkingSpaces = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParkingSpaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parkingSpaceRepository = Provider.of<ParkingSpaceRepository>(context, listen: false);
      final parkingSpaces = await parkingSpaceRepository.getAll();
      
      setState(() {
        _parkingSpaces = parkingSpaces;
        _filteredParkingSpaces = parkingSpaces;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load parking spaces: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterParkingSpaces(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredParkingSpaces = _parkingSpaces;
      } else {
        _filteredParkingSpaces = _parkingSpaces.where((space) => 
          space.address.toLowerCase().contains(query.toLowerCase()) ||
          space.id.toLowerCase().contains(query.toLowerCase())
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
                labelText: 'Search parking spaces',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterParkingSpaces,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredParkingSpaces.isEmpty
                        ? const Center(child: Text('No parking spaces found.'))
                        : ListView.builder(
                            itemCount: _filteredParkingSpaces.length,
                            itemBuilder: (context, index) {
                              final parkingSpace = _filteredParkingSpaces[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.local_parking, size: 36),
                                  title: Text(parkingSpace.address),
                                  subtitle: Text('Price: ${parkingSpace.pricePerHour} kr/h'),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => StartParkingScreen(parkingSpace: parkingSpace),
                                        ),
                                      );
                                    },
                                    child: const Text('Park Here'),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
