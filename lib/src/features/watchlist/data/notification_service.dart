import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'arena_match_reminders';
  static const _channelName = 'Match Reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleMatchReminder(WatchlistEntry entry) async {
    final reminderEpochMs = entry.matchTimeMs - 15 * 60 * 1000;
    if (reminderEpochMs <= DateTime.now().millisecondsSinceEpoch) return;

    final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      reminderEpochMs,
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '15 minutes before a match starts',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      _notifId(entry.matchId),
      '${entry.homeName} vs ${entry.awayName}',
      'Starting in 15 minutes',
      scheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: entry.matchId,
    );
  }

  Future<void> cancelMatchReminder(String matchId) async {
    await _plugin.cancel(_notifId(matchId));
  }

  int _notifId(String matchId) => matchId.hashCode.abs() % 100000;
}
