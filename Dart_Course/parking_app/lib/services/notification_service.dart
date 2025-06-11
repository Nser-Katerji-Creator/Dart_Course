import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  
  // Static callback to handle notification actions 
  static Function(String action, String parkingId)? onNotificationAction;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : flutterLocalNotificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure you have this icon

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'parking_category',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              'extend_parking',
              'Extend Parking',
              options: const <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'end_parking', 
              'End Parking',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
        ),
      ],
    );

    // Linux initialization settings (optional, if you support Linux)
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      // linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        await _handleNotificationResponse(notificationResponse);
      },
    );
  }

  Future<bool> requestPermissions() async {
    bool? result;
    if (await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>() !=
        null) {
      result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() !=
        null) {
      // For Android 13+, specific permission is needed
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      result = await androidImplementation?.requestNotificationsPermission();
    }
    return result ?? false;
  }

  Future<void> scheduleNotificationById({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool includeActions = false,
  }) async {
    print('DEBUG NotificationService: scheduleNotificationById called');
    print('  ID: $id');
    print('  Title: $title');
    print('  Body: $body');
    print('  Scheduled Time: $scheduledTime');
    print('  Include Actions: $includeActions');
    
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id, // Use provided int ID
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails( // Made const
          android: AndroidNotificationDetails(
            'parking_channel_id', // Channel ID
            'Parking Reminders', // Channel name
            channelDescription: 'Notifications for parking expiration reminders.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher', // Ensure you have this icon
            actions: includeActions ? [
              const AndroidNotificationAction(
                'extend_parking',
                'Extend Parking',
                icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                showsUserInterface: true,
              ),
              const AndroidNotificationAction(
                'end_parking',
                'End Parking',
                icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                showsUserInterface: true,
              ),
            ] : null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: includeActions ? 'parking_category' : null,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      print('DEBUG NotificationService: Notification scheduled successfully');
    } catch (e) {
      print('ERROR NotificationService: Failed to schedule notification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Callback function to handle notification responses
  Future<void> _handleNotificationResponse(NotificationResponse response) async {
    print('DEBUG: Notification response received');
    print('  Action ID: ${response.actionId}');
    print('  Payload: ${response.payload}');
    
    if (response.payload != null) {
      final parkingId = response.payload!;
      
      // Use the static callback if available
      if (onNotificationAction != null) {
        final action = response.actionId ?? 'default';
        onNotificationAction!(action, parkingId);
        return;
      }
      
      switch (response.actionId) {
        case 'extend_parking':
          print('DEBUG: User requested to extend parking: $parkingId');
          break;
        case 'end_parking':
          print('DEBUG: User requested to end parking: $parkingId');
          break;
        default:
          print('DEBUG: Notification tapped for parking: $parkingId');
          break;
      }
    }
  }

  // Test method to schedule a notification in 10 seconds for debugging
  Future<void> scheduleTestNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    print('DEBUG: Scheduling test notification for $testTime');
    
    await scheduleNotificationById(
      id: 999999,
      title: 'Test Notification',
      body: 'This is a test notification to verify the system works',
      scheduledTime: testTime,
      payload: 'test_payload',
      includeActions: true,
    );
  }

  // Method to schedule an immediate notification for testing
  Future<void> scheduleImmediateTestNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 3));
    print('DEBUG: Scheduling immediate test notification for $testTime');
    
    await scheduleNotificationById(
      id: 888888,
      title: 'Immediate Test 🔔',
      body: 'This notification should appear in 3 seconds!',
      scheduledTime: testTime,
      payload: 'immediate_test',
      includeActions: true,
    );
  }

  // Method to get pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Method to print all pending notifications for debugging
  Future<void> debugPendingNotifications() async {
    final pending = await getPendingNotifications();
    print('DEBUG: Pending notifications count: ${pending.length}');
    for (final notification in pending) {
      print('  ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
  }
}
