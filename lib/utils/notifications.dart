// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:abril_driver_app/functions/functions.dart';
// import 'package:abril_driver_app/pages/onTripPage/map_page.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

// class NotiProvider extends ChangeNotifier {}

// Future<void> initializeNotifications() async {
//   AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'high_importance_channel',
//         channelName: 'High Importance Notifications',
//         channelDescription: 'Notificaciones de alta prioridad',
//         importance: NotificationImportance.Max,
//         defaultColor: Colors.blue,
//         ledColor: Colors.white,
//         locked: true,
//         channelShowBadge: true,
//         enableVibration: true,
//         defaultRingtoneType: DefaultRingtoneType.Notification,
//       )
//     ],
//     debug: true,
//   );

//   AwesomeNotifications().setListeners(
//     onNotificationCreatedMethod:
//         (ReceivedNotification receivedNotification) async {
//       return;
//     },
//     onNotificationDisplayedMethod:
//         (ReceivedNotification receivedNotification) async {
//       return;
//     },
//     onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
//       return;
//     },
//     onActionReceivedMethod: handleNotificationAction,
//   );
// }

// Future<void> showFullScreenNotification(String titulo, String contenido,
//     String requestId, double latitudeRecogida, double longitudeRecogida) async {
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 0,
//       channelKey: 'high_importance_channel',
//       title: titulo,
//       body: contenido,
//       wakeUpScreen: true,
//       fullScreenIntent: true,
//       autoDismissible: false,
//       notificationLayout: NotificationLayout.Default,
//       payload: {
//         'requestId': requestId,
//         'latitudeRecogida': latitudeRecogida.toString(),
//         'longitudeRecogida': longitudeRecogida.toString(),
//       },
//       category: NotificationCategory.Service
//     ),
//     actionButtons: [
//       NotificationActionButton(
//           key: 'ACCEPT',
//           label: 'Aceptar',
//           autoDismissible: true,
//           actionType: ActionType.Default),
//     ],
//   );
// }

// Future<void> handleNotificationAction(ReceivedAction receivedAction) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   final actionKey = receivedAction.buttonKeyPressed;

//   if (actionKey == 'ACCEPT') {
//     final String? requestId = receivedAction.payload?['requestId'];
//     final String? latitudeRecogidaStr =
//         receivedAction.payload?['latitudeRecogida'];
//     final String? longitudeRecogidaStr =
//         receivedAction.payload?['longitudeRecogida'];

//     if (requestId != null &&
//         latitudeRecogidaStr != null &&
//         longitudeRecogidaStr != null) {
//       final double latitudeRecogida = double.parse(latitudeRecogidaStr);
//       final double longitudeRecogida = double.parse(longitudeRecogidaStr);

//       await prefs.setString('pendingRequestId', requestId);
//       await prefs.setDouble('pendingLatitude', latitudeRecogida);
//       await prefs.setDouble('pendingLongitude', longitudeRecogida);

//     } else {
//     }
//   }
// }

// Future<List<LatLng>> calculateRouteAndAcceptRequest(double currentLat,
//     double currentLng, double destLat, double destLng, String requestId) async {
//   List<LatLng> points = await getRouteFromGraphHopper(
//     currentLat,
//     currentLng,
//     destLat,
//     destLng,
//   );

//   routePoints = points;

//   await guardarPuntosRuta(routePoints);

//   await requestAccept(requestId);

//   return points;
// }

// Future<void> guardarPuntosRuta(List<LatLng> puntos) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   List<Map<String, double>> puntosMap = puntos
//       .map(
//           (punto) => {'latitude': punto.latitude, 'longitude': punto.longitude})
//       .toList();

//   String puntosJson = jsonEncode(puntosMap);

//   await prefs.setString('puntosRuta', puntosJson);
// }

