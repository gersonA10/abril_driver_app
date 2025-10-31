// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abril_driver_app/firebase_options.dart';

Timer? locationTimer;

const String _driverIdKey = 'driver_id';
const String _handledRequestsKey = 'handled_requests';
const String _lastLaunchKey = 'last_launch';

Future<void> initializeService(String driverId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_driverIdKey, driverId);

  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: true,
      autoStartOnBoot: true,
      initialNotificationTitle: 'Radio Movil 15 Adonay',
      initialNotificationContent: 'Servicio activo',
    ),
  );

  final isRunning = await service.isRunning();
  if (!isRunning) {
    await service.startService();
    log('✅ Servicio background iniciado.');
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  final prefs = await SharedPreferences.getInstance();
  final driverId = prefs.getString(_driverIdKey);

  if (driverId == null) {
    log('⚠️ Sin driverId en prefs, deteniendo servicio.');
    service.stopSelf();
    return;
  }

  _listenDriverRequests(driverId, prefs);
  _listenAppOpenFlag(driverId, prefs);
  _startLocationUpdates(driverId);

  log('🚀 Servicio background listo (driver: $driverId)');
}

void _listenDriverRequests(String driverId, SharedPreferences prefs) {
  final handled = prefs.getStringList(_handledRequestsKey) ?? [];

  final ref = FirebaseDatabase.instance.ref('request-meta');
  ref.onValue.listen((event) async {
    if (!event.snapshot.exists) return;

    final allRequests = event.snapshot.value as Map?;
    if (allRequests == null) return;

    for (final entry in allRequests.entries) {
      final requestId = entry.key.toString();
      final data = Map<String, dynamic>.from(entry.value);

      final active = data['active'];
      final metaDrivers = data['meta-drivers'];

      final driverInMeta =
          metaDrivers is Map && metaDrivers.containsKey(driverId);

      if (driverInMeta && active == 1) {
        if (!handled.contains(requestId)) {
          log('📲 Nueva solicitud válida: $requestId');
          handled.add(requestId);
          await prefs.setStringList(_handledRequestsKey, handled);
          await _launchAppIfNeeded(prefs);
        } else {
          log('⏳ Request $requestId ya procesada, ignorando.');
        }
      }
    }
  });
}

void _listenAppOpenFlag(String driverId, SharedPreferences prefs) {
  final ref =
      FirebaseDatabase.instance.ref('drivers/driver_$driverId/app_abierta');

  ref.onValue.listen((event) async {
    final val = event.snapshot.value;
    if (val is bool && val == false) {
      log('⚠️ app_abierta = false, relanzando app...');
      await _launchAppIfNeeded(prefs);
    }
  });
}

Future<void> _launchAppIfNeeded(SharedPreferences prefs) async {
  const pkg = 'com.deabrilconductoresdriver.driver';
  const debounce = Duration(seconds: 5);

  final lastLaunch = prefs.getInt(_lastLaunchKey) ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;

  if (now - lastLaunch < debounce.inMilliseconds) {
    log('⏸️ Lanzamiento reciente, evitando duplicado.');
    return;
  }

  try {
    await AndroidIntent(
      action: 'android.intent.action.VIEW',
      package: pkg,
      flags: <int>[
        Flag.FLAG_ACTIVITY_NEW_TASK,
        Flag.FLAG_ACTIVITY_CLEAR_TOP,
      ],
    ).launch();

    FlutterForegroundTask.launchApp(pkg);
    await prefs.setInt(_lastLaunchKey, now);
    log('✅ App abierta correctamente.');
  } catch (e) {
    log('❌ Error lanzando app: $e');
  }
}

void _startLocationUpdates(String driverId) {
  const interval = Duration(seconds: 10);
  locationTimer?.cancel();

  locationTimer = Timer.periodic(interval, (timer) async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final time = DateFormat('HH:mm:ss').format(DateTime.now());

      final db = FirebaseDatabase.instance.ref();
      await db.child('drivers/driver_$driverId').update({
        'l': {'0': pos.latitude, '1': pos.longitude},
        'updated_at': ServerValue.timestamp,
      });
      await db.child('historial/$driverId/$date/$time').set({'lat': pos.latitude, 'lng': pos.longitude});
   
  });
}
