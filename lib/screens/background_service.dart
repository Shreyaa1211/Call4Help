import 'package:call4help/config/secrets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

const String accessKey = Secrets.picovoiceAccessKey;
const String keywordPath = 'assets/help.ppn';
const double sensitivity = 0.5;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'call4help_channel',
    'Call4Help Service',
    description: 'Foreground service for Call4Help listening',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'call4help_channel',
      initialNotificationTitle: 'Call4Help',
      initialNotificationContent: 'Listening for "help"...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'Call4Help',
      content: 'Listening for "help"...',
    );
  }

  await Permission.microphone.request();

  try {
    final porcupineManager = await PorcupineManager.fromKeywordPaths(
      accessKey,
      [keywordPath],
      (int keywordIndex) {
        print('🎤 Wake word detected in background!');

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Call4Help',
            content: 'Help detected!',
          );
        }
      },
      sensitivities: [sensitivity],
    );

    await porcupineManager.start();
    print("✅ Background wake word listening started");

  } catch (e) {
    print("🔥 Background service error: $e");
  }
}