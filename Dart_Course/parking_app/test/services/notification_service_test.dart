import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parking_app/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../mocks/mock_flutter_local_notifications.dart';

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockIOSFlutterLocalNotificationsPlugin mockIOSPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Etc/UTC'));
  });

  setUp(() {
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOSPlugin = MockIOSFlutterLocalNotificationsPlugin();

    notificationService = NotificationService(plugin: mockFlutterLocalNotificationsPlugin);

    // Default stub for Android
    when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);
    // Default stub for iOS
    when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(mockIOSPlugin);
    // Default stub for MacOS (returning null as per service logic if not handled)
    when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>())
        .thenReturn(null);

    when(() => mockFlutterLocalNotificationsPlugin.initialize(
           any(),
           onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
         )).thenAnswer((_) async => true);

    when(() => mockAndroidPlugin.requestNotificationsPermission()).thenAnswer((_) async => true);
    when(() => mockIOSPlugin.requestPermissions(alert: any(named: 'alert'), badge: any(named: 'badge'), sound: any(named: 'sound')))
        .thenAnswer((_) async => true);

    when(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
      any(), any(), any(), any(), any(),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      payload: any(named: 'payload'),
    )).thenAnswer((_) async {});

    when(() => mockFlutterLocalNotificationsPlugin.cancel(any())).thenAnswer((_) async {});
  });

  test('constructor uses default plugin if none provided', () {
     final serviceDefault = NotificationService(); // No plugin passed
     expect(serviceDefault.flutterLocalNotificationsPlugin, isA<FlutterLocalNotificationsPlugin>());
  });

  test('constructor uses injected plugin when provided', () {
     // notificationService is already initialized with mockFlutterLocalNotificationsPlugin in setUp
     expect(notificationService.flutterLocalNotificationsPlugin, same(mockFlutterLocalNotificationsPlugin));
  });

  test('initialize calls plugin initialize with correct parameters', () async {
    await notificationService.initialize();
    verify(() => mockFlutterLocalNotificationsPlugin.initialize(
           any(that: isA<InitializationSettings>()), // Check type of settings
           onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse', that: isNotNull), // Check callback is not null
         )).called(1);
  });

 test('requestPermissions checks iOS first, then Android if iOS specific plugin is null', () async {
   // Scenario 1: iOS plugin is available
   when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>())
       .thenReturn(mockIOSPlugin); // iOS plugin is available
   // Android might be available too, but iOS is checked first by the NotificationService's logic
   when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
       .thenReturn(mockAndroidPlugin);

   await notificationService.requestPermissions();
   verify(() => mockIOSPlugin.requestPermissions(alert: true, badge: true, sound: true)).called(1);
   verifyNever(() => mockAndroidPlugin.requestNotificationsPermission());

   // Reset mocks for next scenario
   reset(mockIOSPlugin); // Resetting only iOS mock for this specific path test
   reset(mockAndroidPlugin); // Reset Android mock too
   // Re-stub general resolves as they are reset too
    when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);
    when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(mockIOSPlugin); // Keep this available for other tests unless specific test overrides
    when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>())
        .thenReturn(null);
    // Re-stub request calls for the mocks that will be called
    when(() => mockAndroidPlugin.requestNotificationsPermission()).thenAnswer((_) async => true);
    // No need to re-stub mockIOSPlugin.requestPermissions if it's not expected to be called

   // Scenario 2: iOS plugin resolve returns null, Android plugin is available
   when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>())
       .thenReturn(null); // Simulate iOS plugin not being available or resolved
   when(() => mockFlutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
       .thenReturn(mockAndroidPlugin); // Android plugin is available

   await notificationService.requestPermissions();
   verifyNever(() => mockIOSPlugin.requestPermissions(alert: any(named: 'alert'), badge: any(named: 'badge'), sound: any(named: 'sound')));
   verify(() => mockAndroidPlugin.requestNotificationsPermission()).called(1);
 });

  test('scheduleNotificationById calls plugin zonedSchedule with correct TZDateTime', () async {
    final testTime = DateTime.now().add(const Duration(minutes: 5));
    await notificationService.scheduleNotificationById(
      id: 1, title: 'Test', body: 'Test Body', scheduledTime: testTime, payload: 'test_payload');

    final captured = verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
           1, 'Test', 'Test Body', captureAny(),
           any(that: isA<NotificationDetails>()), // Check type of details
           androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
           payload: 'test_payload')).captured;

    final scheduledTzTime = captured.first as tz.TZDateTime;
    expect(scheduledTzTime.year, testTime.year);
    expect(scheduledTzTime.month, testTime.month);
    expect(scheduledTzTime.day, testTime.day);
    expect(scheduledTzTime.hour, testTime.hour);
    expect(scheduledTzTime.minute, testTime.minute);
    expect(scheduledTzTime.location.name, tz.local.name); // Compare by location name
  });

  test('cancelNotificationById calls plugin cancel', () async {
    await notificationService.cancelNotificationById(1);
    verify(() => mockFlutterLocalNotificationsPlugin.cancel(1)).called(1);
  });
}
