import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late final FlutterLocalNotificationsPlugin notificationsPlugin;

class NotificationService {

  // Initializes notification settings and plugin
  Future<void> initNotification() async {
    tz.initializeTimeZones();
    notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android and iOS platform-specific settings for notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: iosSettings);

    // Initialize the notification plugin with the settings
    try {
      await notificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      // Handle any exceptions during initialization
      //print('Error initializing notifications: $e');
    }
  }

  // Returns notification details for Android and iOS
  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            channelDescription: 'channel description',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  // Schedule a notification at a specific time
  Future<void> scheduledNotification(
      int id, String title, String body, DateTime time) async {
    time = time.subtract(const Duration(days: 1));

    // Check if the scheduled time is in the past or less than a day away
    if (time.isBefore(DateTime.now())) {
      //print("No notification scheduled since it's less than a day away");
    } else {
      try {
        //print("Notification scheduled");
        // Schedule the notification
        await notificationsPlugin.zonedSchedule(id, title, body,
            tz.TZDateTime.from(time, tz.local), await notificationDetails(),
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (e) {
        // Handle any exceptions during notification scheduling
        //print('Error scheduling notification: $e');
      }
    }
  }

  // Cancel a scheduled notification by its ID
  Future<void> cancelNotification(int id) async {
    try {
      await notificationsPlugin.cancel(id);
      ////print('Notification of id "$id" is canceled');
    } catch (e) {
      // Handle any exceptions during notification cancellation
      //print('Error canceling notification: $e');
    }
  }

  // Show an immediate notification
  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    try {
      return notificationsPlugin.show(
          id, title, body, await notificationDetails());
    } catch (e) {
      // Handle any exceptions during showing immediate notification
      //print('Error showing notification: $e');
    }
  }

  // Retrieve pending notification requests
  dynamic Upcoming() async {
    try {
      return await notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      // Handle any exceptions during retrieving pending notifications
      //print('Error retrieving pending notifications: $e');
      return null;
    }
  }
}