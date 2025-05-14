
import 'package:flutter/material.dart';
import 'package:abril_driver_app/styles/styles.dart';

class CenterDestination extends StatelessWidget {
  const CenterDestination({
    super.key,
    required this.acceptDriverBottomSheetOffset,
    required this.media, required this.onTap,
  });

  final ValueNotifier<double> acceptDriverBottomSheetOffset;
  final Size media;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
       valueListenable: acceptDriverBottomSheetOffset,
       builder: (context, offset, child) {
         double bottomPadding = offset == 0.28 ? 1090 * (offset) : 1018 * (offset);
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
               color: newRedColor,
               borderRadius:
                   BorderRadius.circular(media.width *
                       0.02)),
           child: Material(
             color: Colors
                 .transparent,
             child:
                 InkWell(
               onTap: onTap,
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
                     Icons.person_rounded,
                     color:
                         page,
                     size: media.width *
                         0.068),
               ),
             ),
           ),
         );
       });
  }
}