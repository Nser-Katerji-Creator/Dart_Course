import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/parking/parking_bloc.dart';
import 'package:parking_app/blocs/parking/parking_event.dart';
import 'package:parking_app/blocs/parking/parking_state.dart';
import 'package:parking_app/models/parking.dart';
import 'package:parking_app/models/parking_space.dart';
import 'package:parking_app/models/vehicle.dart';

class ExtendParkingScreen extends StatefulWidget {
  final Parking parking;
  final ParkingSpace? parkingSpace;
  final Vehicle? vehicle;

  const ExtendParkingScreen({
    super.key,
    required this.parking,
    this.parkingSpace,
    this.vehicle,
  });

  @override
  State<ExtendParkingScreen> createState() => _ExtendParkingScreenState();
}

class _ExtendParkingScreenState extends State<ExtendParkingScreen> {
  // Extension duration slider configuration
  double _extensionMinutes = 30.0; // Default 30 minutes extension
  static const double _minExtensionMinutes = 15.0; // Minimum 15 minutes
  static const double _maxExtensionMinutes = 240.0; // Maximum 4 hours (240 minutes)

  // Helper method to format duration from minutes to human-readable text
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()} min';
    } else {
      final hours = minutes / 60;
      if (minutes % 60 == 0) {
        return '${hours.round()} h';
      } else {
        final h = hours.floor();
        final m = (minutes % 60).round();
        return '${h}h ${m}m';
      }
    }
  }

  // Helper method to build quick extension duration buttons
  Widget _buildQuickExtensionButton(String text, double minutes) {
    final isSelected = _extensionMinutes == minutes;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _extensionMinutes = minutes;
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

  // Helper method to format DateTime to readable string
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _extendParking() {
    final extensionDuration = Duration(minutes: _extensionMinutes.round());
    context.read<ParkingBloc>().add(ExtendParking(widget.parking.id, extensionDuration));
  }

  @override
  Widget build(BuildContext context) {
    final currentEndTime = widget.parking.plannedEndTime ?? widget.parking.startTime.add(const Duration(hours: 1));
    final newEndTime = currentEndTime.add(Duration(minutes: _extensionMinutes.round()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extend Parking'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ParkingBloc, ParkingState>(
        listener: (context, state) {
          if (state is ParkingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is ParkingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ParkingLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current parking info
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Parking',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.vehicle != null) ...[
                          Text('Vehicle: ${widget.vehicle!.registrationNumber} (${widget.vehicle!.type})'),
                          const SizedBox(height: 4),
                        ],
                        if (widget.parkingSpace != null) ...[
                          Text('Location: ${widget.parkingSpace!.address}'),
                          const SizedBox(height: 4),
                        ],
                        Text('Started: ${_formatDateTime(widget.parking.startTime)}'),
                        Text('Current end time: ${_formatDateTime(currentEndTime)}'),
                        if (widget.parking.plannedDuration != null)
                          Text('Current duration: ${_formatDuration(widget.parking.plannedDuration!.inMinutes.toDouble())}'),
                      ],
                    ),
                  ),
                ),

                // Extension duration selection
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Extend Duration',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Extension display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.orange.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add: ${_formatDuration(_extensionMinutes)}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.add_circle_outline, color: Colors.orange.shade700),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Extension slider
                        Column(
                          children: [
                            Slider(
                              value: _extensionMinutes,
                              min: _minExtensionMinutes,
                              max: _maxExtensionMinutes,
                              divisions: (((_maxExtensionMinutes - _minExtensionMinutes) / 15).round()), // 15-minute increments
                              label: _formatDuration(_extensionMinutes),
                              activeColor: Colors.orange.shade700,
                              onChanged: isLoading ? null : (double value) {
                                setState(() {
                                  _extensionMinutes = value;
                                });
                              },
                            ),
                            // Quick extension buttons
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildQuickExtensionButton('15m', 15),
                                _buildQuickExtensionButton('30m', 30),
                                _buildQuickExtensionButton('1h', 60),
                                _buildQuickExtensionButton('2h', 120),
                                _buildQuickExtensionButton('4h', 240),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // New end time preview
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Updated Parking',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('New end time: ${_formatDateTime(newEndTime)}'),
                        if (widget.parking.plannedDuration != null) ...[
                          Text(
                            'Total duration: ${_formatDuration((widget.parking.plannedDuration!.inMinutes + _extensionMinutes).toDouble())}',
                          ),
                        ],
                        if (widget.parkingSpace != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Additional cost: ${(_extensionMinutes / 60 * widget.parkingSpace!.pricePerHour).toStringAsFixed(2)} kr',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _extendParking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Extend Parking'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
