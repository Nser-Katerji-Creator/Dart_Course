import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/blocs/parking/parking_bloc.dart';
import 'package:parking_app/blocs/parking/parking_event.dart';
import 'package:parking_app/blocs/parking/parking_state.dart';

class QuickExtendParkingDialog extends StatefulWidget {
  final String parkingId;

  const QuickExtendParkingDialog({
    super.key,
    required this.parkingId,
  });

  @override
  State<QuickExtendParkingDialog> createState() => _QuickExtendParkingDialogState();
}

class _QuickExtendParkingDialogState extends State<QuickExtendParkingDialog> {
  double _extensionMinutes = 30.0; // Default 30 minutes extension
  static const double _minExtensionMinutes = 15.0; // Minimum 15 minutes
  static const double _maxExtensionMinutes = 120.0; // Maximum 2 hours for quick extension

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  void _extendParking() {
    final extensionDuration = Duration(minutes: _extensionMinutes.round());
    context.read<ParkingBloc>().add(ExtendParking(widget.parkingId, extensionDuration));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParkingBloc, ParkingState>(
      listener: (context, state) {
        if (state is ParkingOperationSuccess) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ParkingError) {
          Navigator.of(context).pop(false); // Return false to indicate failure
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

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text('Extend Parking'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How much time would you like to add?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                // Extension display
                Container(
                  width: double.infinity,
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
                      Icon(Icons.schedule, color: Colors.orange.shade700, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Extension slider
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
                Text(
                  'Quick options:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildQuickExtensionButton('15m', 15),
                    _buildQuickExtensionButton('30m', 30),
                    _buildQuickExtensionButton('1h', 60),
                    _buildQuickExtensionButton('2h', 120),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _extendParking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Extend'),
            ),
          ],
        );
      },
    );
  }

  /// Static method to show the dialog
  static Future<bool?> show(BuildContext context, String parkingId) {
    return showDialog<bool>(
      context: context,
      builder: (context) => QuickExtendParkingDialog(parkingId: parkingId),
    );
  }
}
