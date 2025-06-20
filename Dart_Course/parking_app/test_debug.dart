import 'package:flutter/material.dart';

void main() {
  // Test the _formatDuration method
  String formatDuration(double minutes) {
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

  print('formatDuration(60.0) = "${formatDuration(60.0)}"');
  print('formatDuration(120.0) = "${formatDuration(120.0)}"');
  print('formatDuration(90.0) = "${formatDuration(90.0)}"');
}
