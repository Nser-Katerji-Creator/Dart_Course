import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'parking_spaces_screen.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  late NotificationService _notificationService;
  String _status = 'Ready to test notifications';

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      setState(() => _status = 'Initializing notification service...');
      await _notificationService.initialize();
      
      setState(() => _status = 'Requesting permissions...');
      final hasPermission = await _notificationService.requestPermissions();
      
      setState(() => _status = hasPermission 
        ? 'Permissions granted! Ready to test.' 
        : 'Permissions denied. Please enable notifications in settings.');
    } catch (e) {
      setState(() => _status = 'Error initializing: $e');
    }
  }

  Future<void> _scheduleTestNotification() async {
    try {
      setState(() => _status = 'Scheduling test notification for 10 seconds...');
      
      final testTime = DateTime.now().add(const Duration(seconds: 10));
      await _notificationService.scheduleNotificationById(
        id: 12345,
        title: 'Test Notification',
        body: 'This test notification was scheduled at ${DateTime.now().toString()}',
        scheduledTime: testTime,
        payload: 'test_payload',
        includeActions: true,
      );
      
      setState(() => _status = 'Test notification scheduled for $testTime');
    } catch (e) {
      setState(() => _status = 'Error scheduling notification: $e');
    }
  }

  Future<void> _scheduleParkingStyleNotification() async {
    try {
      setState(() => _status = 'Scheduling parking-style notification...');
      
      final testTime = DateTime.now().add(const Duration(seconds: 15));
      await _notificationService.scheduleNotificationById(
        id: 54321,
        title: 'Parking Reminder ⏰',
        body: 'Your parking expires at ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}. Don\'t forget to move your vehicle!',
        scheduledTime: testTime,
        payload: 'parking_test_id',
        includeActions: true,
      );
      
      setState(() => _status = 'Parking notification scheduled for $testTime');
    } catch (e) {
      setState(() => _status = 'Error scheduling parking notification: $e');
    }
  }

  Future<void> _scheduleImmediateTestNotification() async {
    try {
      setState(() => _status = 'Scheduling immediate test notification...');
      
      await _notificationService.scheduleImmediateTestNotification();
      
      setState(() => _status = 'Immediate test notification scheduled for 3 seconds from now');
    } catch (e) {
      setState(() => _status = 'Error scheduling immediate notification: $e');
    }
  }
  Future<void> _checkPendingNotifications() async {
    try {
      setState(() => _status = 'Checking pending notifications...');
      
      await _notificationService.debugPendingNotifications();
      final pending = await _notificationService.getPendingNotifications();
      
      setState(() => _status = 'Found ${pending.length} pending notifications (check terminal for details)');
    } catch (e) {
      setState(() => _status = 'Error checking pending notifications: $e');
    }
  }
  void _navigateToParkingSpaces() {
    setState(() => _status = 'Navigate to Parking Spaces to create a real parking session');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParkingSpacesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Status: $_status',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleImmediateTestNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('⚡ Immediate Test (3s)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scheduleTestNotification,
              child: const Text('Schedule Test Notification (10s)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scheduleParkingStyleNotification,
              child: const Text('Schedule Parking Notification (15s)'),
            ),
            const SizedBox(height: 10),            ElevatedButton(
              onPressed: _checkPendingNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Check Pending Notifications'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToParkingSpaces,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('🅿️ Create Real Parking Session'),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('1. Tap "⚡ Immediate Test (3s)" for quickest test'),
                    Text('2. Put the app in background immediately'),  
                    Text('3. Wait 3 seconds for notification'),
                    Text('4. Try tapping action buttons if they appear'),
                    Text('5. Use "🅿️ Create Real Parking Session" for full test'),
                    Text('6. Select a parking space and create 2-3 minute parking'),
                    Text('7. Wait ~1 minute for notification (reminder is set to 1 min)'),
                    Text('8. Check terminal for debug messages'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
