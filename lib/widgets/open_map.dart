
import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:map_launcher/map_launcher.dart';

class OpenMapApp extends StatelessWidget {
  const OpenMapApp({
    super.key,
    required this.acceptDriverBottomSheetOffset,
    required this.media,
  });

  final ValueNotifier<double> acceptDriverBottomSheetOffset;
  final Size media;

  @override
  Widget build(BuildContext context) {
    return Container(
           decoration: BoxDecoration(
               boxShadow: [
                 BoxShadow(
                     blurRadius:
                         2,
                     color: Colors.black.withOpacity(
                         0.2),
                     spreadRadius:
                         2)
               ],
               color: page,
               borderRadius:
                   BorderRadius.circular(media.width *
                       0.02)),
           child: Material(
             color: Colors
                 .transparent,
             child:
                 InkWell(
               onTap:
                   () async {
             
                   final availableMaps = await MapLauncher.installedMaps;
                   await MapLauncher.showMarker(
                     mapType: MapType.osmand,
                     coords: Coords(latitudeDestino!, longitudeDestino!),
                     description: '', 
                     title: ''
             
                   );
             
             
               },
               child:
                   SizedBox(
                 height:
                     media.width *
                         0.1,
                 width: media
                         .width *
                     0.1,
             
                 // alignment:
                 //     Alignment.center,
                 child: Icon(
                     Icons.navigation_rounded,
                     color:const Color.fromARGB(255, 243, 159, 14),
                     size: media.width *
                         0.068),
               ),
             ),
           ),
         );
  }
}