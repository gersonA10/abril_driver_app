import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService(String driverID) async {
  FlutterBackgroundService()
      .invoke('updateAppLifeState', {"AppLifeState": false});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', driverID);
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
        onStart: onStart, isForegroundMode: false, autoStart: true),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    log('Error al inicializar Firebase: $e');
    return;
  }
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('id')) {
    log('⚠️ SharedPreferences corrupto, limpiando datos...');
    await prefs.clear(); // Borra todos los datos corruptos
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('updateAppLifeState').listen((event) async {
    if (event!['AppLifeState'] != null) {
      bool appLifeState = event['AppLifeState'];
      log('Estado de la app actualizado: $appLifeState');
      await prefs.setBool('AppLifeState', appLifeState);
    }
  });

  try {
    String? id = prefs.getString('id');
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'Radio Movil 15 de Abril',
          content: 'Aplicación en ejecución',
        );
      }
    }

    startLocationUpdates(id);
    await checkDriverRequests(id!, service, prefs);

    log('Servicio en segundo plano en ejecución');
    service.invoke('update');
  } catch (e) {
    log('Error en el servicio en segundo plano: $e');
  }
}

Future<void> checkDriverRequests(
    String driverId, ServiceInstance service, SharedPreferences prefs) async {
  String? lastRequestId; // Guarda la última solicitud procesada
  bool isAppAlreadyOpened =
      false; // Evita múltiples aperturas en una sola ejecución

  final DatabaseReference requestRef =
      FirebaseDatabase.instance.ref('request-meta');
  final DatabaseReference appStateRef =
      FirebaseDatabase.instance.ref('drivers/driver_$driverId/app_abierta');

  late StreamSubscription<DatabaseEvent> requestListener;
  late StreamSubscription<DatabaseEvent> appStateListener;

  // Listener para detectar nuevas solicitudes
  requestListener = requestRef.onValue.listen((event) async {
    if (event.snapshot.exists) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      for (var key in data.keys) {
        final carrera = data[key] as Map<dynamic, dynamic>;

        if (carrera['meta-drivers'] != null) {
          final metaDrivers = carrera['meta-drivers'] as Map<dynamic, dynamic>;

          // Verifica que el ID del driver esté en la solicitud
          if (metaDrivers.containsKey(driverId)) {
            String requestId = carrera['request_id'];

            // Evita abrir la app si esta solicitud ya fue manejada
            if (lastRequestId == requestId) {
              log('🛑 Solicitud ya procesada, evitando reapertura...');
              continue; // Salta esta iteración
            }

            // Evita abrir la app múltiples veces en rápida sucesión
            if (isAppAlreadyOpened) {
              log('🛑 La app ya está en proceso de apertura, evitando múltiples aperturas...');
              continue;
            }

            isAppAlreadyOpened = true; // Bloquea más aperturas simultáneas

            final intent = AndroidIntent(
              action: 'android.intent.action.VIEW',
              package: 'com.deabrilconductoresdriver.driver',
              flags: <int>[
                Flag.FLAG_ACTIVITY_NEW_TASK,
                Flag.FLAG_ACTIVITY_CLEAR_TOP
              ],
            );

            try {
              await intent.launch();
              log('🚀 Aplicación abierta por nueva solicitud');
            } catch (e) {
              log('❌ Error al abrir la app: $e');
            }

            FlutterForegroundTask.launchApp(
                'com.deabrilconductoresdriver.driver');
            log('📲 Aplicación lanzada desde segundo plano...');

            lastRequestId =
                requestId; // Guarda el requestId actual como última solicitud procesada
            await Future.delayed(Duration(
                seconds:
                    5)); // Pequeño delay para evitar múltiples eventos seguidos
            isAppAlreadyOpened =
                false; // Permite futuras aperturas después del delay
          }
        }
      }
    }
  });

  // Listener para detectar si la app se cerró inesperadamente
  appStateListener = appStateRef.onValue.listen((event) async {
    if (event.snapshot.exists) {
      bool isAppOpen = event.snapshot.value as bool;

      if (!isAppOpen) {
        log('⚠️ La app se ha cerrado inesperadamente, intentando reabrir...');

        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          package: 'com.deabrilconductoresdriver.driver',
          flags: <int>[
            Flag.FLAG_ACTIVITY_NEW_TASK,
            Flag.FLAG_ACTIVITY_CLEAR_TOP
          ],
        );

        try {
          await intent.launch();
          log('🚀 Aplicación reabierta debido a cierre inesperado');
        } catch (e) {
          log('❌ Error al intentar abrir la app: $e');
        }

        FlutterForegroundTask.launchApp('com.deabrilconductoresdriver.driver');
        log('📲 Aplicación relanzada desde segundo plano...');
      }
    }
  });

  service.on('stop').listen((event) {
    requestListener.cancel();
    appStateListener.cancel();
  });
}



void startLocationUpdates(String? driverId) {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

 locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('currentLatitude', position.latitude);
    prefs.setDouble('currentLongitude', position.longitude);

    bool estaActivo = prefs.getBool('estaActivo') ?? false;
    if (!estaActivo) return;

    if (driverId != null) {
      final firebase = FirebaseDatabase.instance.ref();
      String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());

      try {
        await firebase.child('drivers/driver_$driverId').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updated_at': ServerValue.timestamp,
        });

        await firebase
            .child('historial/$driverId/$formattedDate/$formattedTime')
            .update({
          'lat': position.latitude,
          'lng': position.longitude,
        });

        log('Ubicación actualizada: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        log('Error actualizando ubicación en Firebase: $e');
      }
    }
  });
}
