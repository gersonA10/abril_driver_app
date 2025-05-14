
import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:map_launcher/map_launcher.dart';

class PickUpOpenMap extends StatelessWidget {
  const PickUpOpenMap({
    super.key,
    required this.acceptDriverBottomSheetOffset,
    required this.media,
  });

  final ValueNotifier<double> acceptDriverBottomSheetOffset;
  final Size media;

  @override
  Widget build(BuildContext context) {
    // driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0
    return (driverReq['is_driver_arrived'] == 0)  
    ? latitudeDestino != 0.0 ? Container()
    : ValueListenableBuilder(
       valueListenable:
           acceptDriverBottomSheetOffset,
       builder: (context,
           offset, child) {
              double bottomPadding = offset == 0.28 ? 1270 * (offset) : 1098 * (offset);
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
                     coords: Coords(latRecoger!, lonRecoger!),
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
       }) : Container();
  }
}