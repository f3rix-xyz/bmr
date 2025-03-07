import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _audioPlayer = AudioPlayer();
  static bool _isAppInForeground = true;

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings);

    await _setupNotificationChannels();
    await _requestPermissions();
  }

  static Future<void> _setupNotificationChannels() async {
    const androidChannel = AndroidNotificationChannel(
      'sse_alerts',
      'SSE Alerts',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'sse_alerts',
      'SSE Alerts',
      channelDescription: 'SSE event notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'alert.caf',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      details,
    );

    if (_isAppInForeground) {
      await _playForegroundSound();
    }
  }

  static Future<void> _playForegroundSound() async {
    await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
  }

  static void updateAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
  }
}
