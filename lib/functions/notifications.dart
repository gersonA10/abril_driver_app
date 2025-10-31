// lib/functions/notifications.dart
import 'dart:io';
// import 'package:device_apps/device_apps.dart';
import 'package:abril_driver_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../pages/chatPage/chat_page.dart';
import 'functions.dart';

// create an instance
FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin fltNotification = FlutterLocalNotificationsPlugin();
FlutterLocalNotificationsPlugin rideNotification = FlutterLocalNotificationsPlugin();
bool isGeneral = false;
String latestNotification = '';
int id = 0;

void notificationTapBackground(NotificationResponse notificationResponse) {
  isGeneral = true;
  valueNotifierHome.incrementNotifier();
}

void onChatNotificationTapped(NotificationResponse notificationResponse) {
  debugPrint('Chat notification tapped');
  if (isInChatPage == false) {
    isInChatPage = true;
    // Navega a la página de chat usando la navigatorKey global
    navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (context) => const ChatPage()))
        .then((_) {
      isInChatPage = false;
    });
  }
}

var androidDetails = const AndroidNotificationDetails(
  '54321',
  'normal_notification',
  enableVibration: true,
  enableLights: true,
  importance: Importance.high,
  playSound: true,
  priority: Priority.high,
  visibility: NotificationVisibility.private,
);

const iosDetails = DarwinNotificationDetails(
    presentAlert: true, presentBadge: true, presentSound: true);

var generalNotificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

var androiInit =
    const AndroidInitializationSettings('@mipmap/launcher_icon'); //for logo
var iosInit = const DarwinInitializationSettings(
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);
var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);

Future<void> initMessaging() async {
  await fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: onChatNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: onChatNotificationTapped);

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      // 💡 MODIFICADO: Lógica de detección mejorada
      bool isChat = message.data['push_type'] == 'chat' ||
          (message.notification?.title != null &&
              message.notification!.title!.startsWith('Nuevo mensaje de:'));

      if (message.data['push_type'] == 'general') {
        latestNotification = message.data['message'];
        isGeneral = true;
        valueNotifierHome.incrementNotifier();
      } else if (isChat) {
        pendingChatNavigation = true;
      }
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('=========== ${message.notification}');
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      // 💡 MODIFICADO: Lógica de detección mejorada
      bool isChat = message.data['push_type'].toString() == 'chat' ||
          (notification.title != null &&
              notification.title!.startsWith('Nuevo mensaje de:'));

      if (message.data['push_type'].toString() == 'general') {
        latestNotification = message.data['message'];
        if (message.data['image'].isNotEmpty) {
          _showBigPictureNotificationURLGeneral(message.data);
        } else {
          _showGeneralNotification(message.data);
        }
      } else if (isChat) { // 💡 MODIFICADO
        if (isInChatPage == false) {
          _showChatNotification(notification); // Muestra la notificación de chat
        }
      } else {
        if (requestStreamStart == null) {
          getUserDetails();
        } else {}
        _showRideNotification(message.notification);
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // 💡 MODIFICADO: Lógica de detección mejorada
    bool isChat = message.data['push_type'].toString() == 'chat' ||
        (message.notification?.title != null &&
            message.notification!.title!.startsWith('Nuevo mensaje de:'));

    if (message.data['push_type'].toString() == 'general') {
      latestNotification = message.data['message'];
      isGeneral = true;
      valueNotifierHome.incrementNotifier();
    } else if (isChat) { // 💡 MODIFICADO
      // Simula un NotificationResponse para reusar el handler
      onChatNotificationTapped(NotificationResponse(
        payload: message.data['request_id'],
        notificationResponseType: NotificationResponseType.selectedNotification,
      ));
    }
  });
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<Uint8List> _getByteArrayFromUrl(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}

Future<void> _showBigPictureNotificationURLGeneral(message) async {
  latestNotification = message['message'];
  if (platform == TargetPlatform.android) {
    final ByteArrayAndroidBitmap bigPicture =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(message['image']));
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture);
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'notification_1',
      'general image notification',
      channelDescription: 'general notification with image',
      styleInformation: bigPictureStyleInformation,
      enableVibration: true,
      enableLights: true,
      importance: Importance.high,
      playSound: true,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    fltNotification.initialize(initSetting,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    await fltNotification.show(
        id++, message['title'], message['message'], notificationDetails);
  } else {
    final String bigPicturePath = await _downloadAndSaveFile(
        Uri.parse(message['image']).toString(), 'bigPicture.jpg');
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: <DarwinNotificationAttachment>[
          DarwinNotificationAttachment(
            bigPicturePath,
          )
        ]);

    final NotificationDetails notificationDetails =
        NotificationDetails(iOS: iosDetails);
    fltNotification.initialize(initSetting,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    await fltNotification.show(
        id++, message['title'], message['message'], notificationDetails);
  }
  id = id++;
}

Future<void> _showGeneralNotification(message) async {
  latestNotification = message['message'];
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_1',
    'general notification',
    channelDescription: 'general notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  await fltNotification.show(
      id++, message['title'], message['message'], notificationDetails);
  id = id++;
}

Future<void> _showChatNotification(RemoteNotification? notification) async {
  if (notification == null) return;
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_2', // ID de canal diferente
    'chat notification',
    channelDescription: 'chat notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);

  // Asegúrate de que el handler de tap esté configurado
  fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: onChatNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: onChatNotificationTapped);

  await fltNotification.show(id++, notification.title.toString(),
      notification.body.toString(), notificationDetails);
  id = id++;
}

Future<void> showOtpNotification(message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_1',
    'ride notification',
    channelDescription: 'ride notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  rideNotification.initialize(initSetting);
  await rideNotification.show(id++, message.title.toString(),
      message.body.toString(), notificationDetails);
  id = id++;
}

Future<void> _showRideNotification(message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_1',
    'ride notification',
    channelDescription: 'ride notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  rideNotification.initialize(initSetting);
  await rideNotification.show(id++, message.title.toString(),
      message.body.toString(), notificationDetails);
  id = id++;
}