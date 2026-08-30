import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notice.dart';

class NotificationService {
  static NotificationService? _instance;
  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _channelId = 'tuna_family_channel';
  static const String _channelName = '참치패밀리 공지 알림';
  static const String _channelDesc = '참치패밀리 새 공지 및 긴급 소식 실시간 푸시 알림';

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Android Initialization Settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 2. iOS / macOS Settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 3. Linux Settings
      const linuxSettings =
          LinuxInitializationSettings(defaultActionName: 'Open');

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (kDebugMode) {
            print('Notification clicked with payload: ${response.payload}');
          }
        },
      );

      // 4. Request Android 13+ Notification Permission
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService init error: $e');
      }
    }
  }

  /// Show a real-time system push notification on the device
  Future<void> showNoticePushNotification(Notice notice) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          notice.content,
          contentTitle: '📢 [${notice.category.label}] ${notice.title}',
          summaryText: '${notice.authorEmoji} ${notice.authorName}님의 새 공지',
        ),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _notificationsPlugin.show(
        id: id,
        title: '📢 [${notice.category.label}] ${notice.title}',
        body: '${notice.authorEmoji} ${notice.authorName}: ${notice.content}',
        notificationDetails: details,
        payload: notice.id,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing push notification: $e');
      }
    }
  }

  /// Send custom family push test
  Future<void> showCustomPush({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const details = NotificationDetails(android: androidDetails);

      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing custom push: $e');
      }
    }
  }
}
