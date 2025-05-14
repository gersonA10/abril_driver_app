import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:abril_driver_app/models/request_meta.dart';
import 'package:abril_driver_app/models/requests_mode.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:rxdart/rxdart.dart';

const MethodChannel _channel = MethodChannel('flutter.app/awake');

class RequestMetaService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('request-meta');
  final String driverId;
  RequestMetaService(this.driverId);

  Stream<List<RequestMeta>> getRequestMetaStream() {
    return _ref.onValue.map((event) async {
      List<RequestMeta> requests = [];
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        bool hasRequestsForDriver = data.values.any((value) {
          if (value['meta-drivers'] != null) {
            Map<dynamic, dynamic> metaDrivers =
                value['meta-drivers'] as Map<dynamic, dynamic>;
            return metaDrivers.containsKey(driverId);
          }
          return false;
        });

        if (hasRequestsForDriver) {
          data.forEach((key, value) {
            requests.add(RequestMeta.fromMap(value));
          });
          // log('TODO: FM openAppIfNewRequest Disabled');
          _openAppIfNewRequest();
        }
      }
      return requests;
    }).asyncMap((event) => event);
  }

  Future<void> _openAppIfNewRequest() async {
    final bool isAppInForeground =
        await FlutterForegroundTask.isAppOnForeground;
    if (!isAppInForeground) {
      print('**************************************************');
      log('TODO: FM awakeapp');
      // log('TODO: FM awakeapp AppLifeState App #${prefs.getBool('AppLifeState')}');
      print('**************************************************');
      try {
        await _channel.invokeMethod('awakeapp', {"isActive": true});
      } on PlatformException catch (e) {
        log("Error al intentar abrir la app: ${e.message}");
      }
    }
  }
}

class RequestService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('requests');

  Map<String, Request?> previousRequests = {};

  Stream<Request> getRequestStream(String requestId) {
    return _ref.child(requestId).onValue.map((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        Request newRequest = Request.fromMap(data);

        return newRequest;
      } else {
        throw Exception('Request not found');
      }
    }).distinct((previous, current) {
      return previous.isEqualExcludingLatLng(current);
    });
  }

  void markMessagesAsRead(requestId) {
    final DatabaseReference messagesRef = FirebaseDatabase.instance.ref();
    messagesRef
        .child('requests/$requestId/array_mensajes')
        .once()
        .then((event) {
      if (event.snapshot.value != null && event.snapshot.value is List) {
        List<dynamic> data = event.snapshot.value as List<dynamic>;

        for (int i = 0; i < data.length; i++) {
          if (data[i] != null) {
            Map<String, dynamic> msg = Map<String, dynamic>.from(data[i]);

            if (msg["estado"] == "enviado" && msg["origen"] == "cliente") {
              messagesRef
                  .child('requests/$requestId/array_mensajes/$i')
                  .update({"estado": "visto"});
            }
          }
        }
      }
    });
  }

  Stream<int> listenDriverMessageCount(String requestId) {
    return _ref
        .child(requestId)
        .child('nro_mensajes_cliente')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      return (data != null) ? int.tryParse(data.toString()) ?? 0 : 0;
    });
  }

  Stream<String?> getDriverIdStream(String requestId) {
    return _ref.child(requestId).child('driver_id').onValue.map((event) {
      return event.snapshot.value.toString();
    });
  }

  Stream<String?> getConfirmacion(String requestId) {
    return _ref
        .child(requestId)
        .child('confirmado_cliente')
        .onValue
        .map((event) {
      return event.snapshot.value.toString();
    });
  }

  Stream<int?> getMessageCountStream(String requestId, String driverId) {
    return getDriverIdStream(requestId).switchMap((assignedDriverId) {
      if (assignedDriverId == driverId) {
        return _ref
            .child(requestId)
            .child('nro_mensajes_cliente')
            .onValue
            .map((event) {
          return event.snapshot.value as int?;
        });
      } else {
        return Stream<int?>.empty();
      }
    });
  }
}


// class DriverStatus {
//   final DatabaseReference _ref = FirebaseDatabase.instance.ref('drivers');

//   Stream<bool> getDriverAvailabilityStream(String driverId) {
//     return _ref.child('driver_$driverId/is_avaliable').onValue.map((event) {
//       final data = event.snapshot.value;
//       return data == true; // Retorna true si is_avaliable es true, false en cualquier otro caso
//     });
//   }
// }
