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
  FlutterBackgroundService().invoke('updateAppLifeState', {"AppLifeState": false});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', driverID);
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: false, autoStart: true),
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
          title: 'Radio Movil 15 Adonay',
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

// lib/utils/back_services.dart

Future<void> checkDriverRequests(
    String driverId, ServiceInstance service, SharedPreferences prefs) async {
  // 🔹 Usamos un Set para llevar un registro de las carreras ya procesadas o en proceso.
  Set<String> processedRequests =
      (prefs.getStringList('processedRequests') ?? []).toSet();

  final DatabaseReference requestRef =
      FirebaseDatabase.instance.ref('request-meta');

  // 🔸 Usamos onChildAdded para detectar solo NUEVAS carreras.
  final requestListener = requestRef.onChildAdded.listen((event) async {
    if (!event.snapshot.exists || event.snapshot.value == null) return;

    final carreraData = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final requestId =
        carreraData['request_id']?.toString() ?? event.snapshot.key!;

    // 🔸 Si ya estamos procesando o hemos procesado esta carrera, la ignoramos.
    if (processedRequests.contains(requestId)) {
      log('ℹ️ Solicitud $requestId ya está en proceso o fue procesada. Ignorando.');
      return;
    }

    log('🆕 Nueva carrera detectada: $requestId. Iniciando escucha de detalles...');
    processedRequests.add(requestId); // Marcamos como "en proceso" inmediatamente.

    StreamSubscription<DatabaseEvent>? valueListener;

    // 🔸 Creamos un listener temporal con onValue para ESTA carrera específica.
    valueListener =
        requestRef.child(event.snapshot.key!).onValue.listen((snapshot) async {
      if (!snapshot.snapshot.exists || snapshot.snapshot.value == null) {
        log('⚠️ El snapshot de la carrera $requestId ya no existe.');
        valueListener?.cancel(); // Limpiamos el listener si el nodo se borra.
        processedRequests.remove(requestId);
        prefs.setStringList('processedRequests', processedRequests.toList());
        return;
      }

      final carrera =
          Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);

      // ✅ Verificamos que todos los datos necesarios estén presentes.
      if (carrera['meta-drivers'] != null &&
          (carrera['meta-drivers'] as Map).containsKey(driverId) &&
          carrera['active'] == 1) {
        
        log('✅ Datos completos para la carrera $requestId. Abriendo la app...');

        // 🛑 Cancelamos el listener temporal INMEDIATAMENTE para no volver a reaccionar.
        valueListener?.cancel();

        // Lanzamos la app
        const intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          package: 'com.deabrilconductoresdriver.driver',
          flags: <int>[
            Flag.FLAG_ACTIVITY_NEW_TASK,
            Flag.FLAG_ACTIVITY_CLEAR_TOP,
          ],
        );

        try {
          await intent.launch();
          FlutterForegroundTask.launchApp(
              'com.deabrilconductoresdriver.driver');
          log('📲 Aplicación abierta desde segundo plano para $requestId.');
        } catch (e) {
          log('❌ Error al abrir la app: $e');
        }

        // Limpiamos la solicitud de la lista de "en proceso" después de un tiempo prudencial.
        // Esto es por si el usuario rechaza y la solicitud vuelve a aparecer.
        Future.delayed(const Duration(minutes: 2), () {
          processedRequests.remove(requestId);
          prefs.setStringList('processedRequests', processedRequests.toList());
        });
      } else {
        log('⏳ Esperando datos completos para la carrera $requestId...');
      }
    });

    // 🔹 Un temporizador de seguridad por si los datos nunca llegan completos.
    Future.delayed(const Duration(seconds: 20), () {
      valueListener?.cancel();
      processedRequests.remove(requestId);
      prefs.setStringList('processedRequests', processedRequests.toList());
      log('⌛️ Tiempo de espera agotado para la carrera $requestId. Listener cancelado.');
    });
  });

  // Limpieza al detener el servicio
  service.on('stop').listen((event) {
    requestListener.cancel();
  });
}

void startLocationUpdates(String? driverId) {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

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

        await firebase.child('historial/$driverId/$formattedDate/$formattedTime').update({
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
