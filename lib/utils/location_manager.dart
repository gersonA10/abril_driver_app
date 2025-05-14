// import 'package:flutter/material.dart';
// import 'package:abril_driver_app/functions/functions.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart' as fm;
// import 'package:latlong2/latlong.dart' as fmlt;

// // fmlt.LatLng? currentPos;
// // fm.MapController? _mapController;

// class LocationManager {
//   static final LocationManager singleton = LocationManager._internal();
//   LocationManager._internal();
//   static LocationManager get shared => singleton;

//   Function(fmlt.LatLng)? onLocationUpdate;

//   void setMapController(fm.MapController controller) {
//     _mapController = controller;
//   }

//   void setOnLocationUpdateCallback(Function(fmlt.LatLng) callback) {
//     onLocationUpdate = callback;
//   }

//   Future<void> initLocation() async {
//     try {

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation,
//       );
//       _updateLocation(fmlt.LatLng(position.latitude, position.longitude));

//       _getLocationUpdates();
//     } catch (e) {
//       debugPrint("Error obteniendo la localización: $e");
//     }
//   }

//   void _getLocationUpdates() {
//     const LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.bestForNavigation,
//       distanceFilter: 0,
//     );

//     Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
//       if (userDetails['active'] == false) return;
//       _updateLocation(fmlt.LatLng(position.latitude, position.longitude));
//     });
//   }

//   void _updateLocation(fmlt.LatLng newPosition) {
//     currentPos = newPosition;
//     debugPrint("Posición actualizada: $currentPos");

//     if (onLocationUpdate != null) {
//       onLocationUpdate!(newPosition);
//     }

//     if (_mapController != null) {
//       _moveMapToPosition(newPosition);
//     }
//   }

//   void _moveMapToPosition(fmlt.LatLng position) {
//     if (_mapController != null) {
//       _mapController!.move(position, 18.0);
//     }
//   }
// }
