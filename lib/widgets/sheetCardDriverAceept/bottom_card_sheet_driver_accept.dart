import 'dart:async';

import 'package:abril_driver_app/pages/loadingPage/loading.dart';
import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/pages/chatPage/chat_page.dart';
import 'package:abril_driver_app/pages/onTripPage/droplocation.dart';
import 'package:abril_driver_app/pages/onTripPage/map_page.dart';
import 'package:abril_driver_app/providers/handle_drop.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/translation/translation.dart';
import 'package:abril_driver_app/utils/location_manager.dart';
import 'package:abril_driver_app/widgets/my_text_widget_changes.dart';
import 'package:abril_driver_app/widgets/sheetCard/alert_deudas.dart';
import 'package:abril_driver_app/widgets/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart' as fmlt;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class BottomCardSheetDriverAccept extends StatefulWidget {
  final ValueNotifier<double> bottomSheetOffset;
  bool navigationtype;
  bool isLoading;
  bool errorOtp;
  bool getStartOtp;
  dynamic navigateLogout;
  String driverOtp;

  Function()? onTapCancelar;
  BottomCardSheetDriverAccept({
    super.key,
    required this.driverOtp,
    required this.errorOtp,
    required this.navigationtype,
    required this.isLoading,
    required this.getStartOtp,
    required this.navigateLogout,
    required this.onTapCancelar,
    required this.bottomSheetOffset,
  });

  @override
  State<BottomCardSheetDriverAccept> createState() =>
      _BottomCardSheetDriverAcceptState();
}

class _BottomCardSheetDriverAcceptState
    extends State<BottomCardSheetDriverAccept> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  String? lugarRecogida;
  String? lugarDestino;
  double? latRec;
  double? lonRec;
  bool _isLoading = false;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getDouble('latRecoger') != null) {
        latRec = prefs.getDouble('latRecoger');
      } else {
        latRec = 0.0;
      }
      if (prefs.getDouble('lonRecoger') != null) {
        lonRec = prefs.getDouble('lonRecoger');
      } else {
        lonRec = 0.0;
      }
      if (prefs.getString('recogida') != null) {
        lugarRecogida = prefs.getString('recogida');
      } else {
        lugarRecogida = '';
      }
      if (prefs.getString('destino') != null) {
        lugarDestino = prefs.getString('destino');
      } else {
        lugarDestino = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dropProvider = Provider.of<DropProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    return Builder(
      builder: (context) {
        return Stack(
          children: [
            // Container(
            //   color: Colors.black,
            //   height: 200,
            //   width: 200,
            // ),
            SizedBox(
              height: size.height * 1,
              width: size.width * 1,
              child: DraggableScrollableSheet(
                initialChildSize: 0.28,
                minChildSize: 0.28,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      widget.bottomSheetOffset.value = notification.extent;
                      return true;
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 82, 82, 82),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                          )
                        ],
                        color: themeProvider.isDarkTheme
                            ? Color.fromRGBO(71, 71, 71, 1)
                            : page,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.01,
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withOpacity(0.3),
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  height: 4,
                                  width: 40,
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            SliverList.list(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    children: [
                                      (driverReq['is_driver_arrived'] == 0)
                                          ? Text(
                                              '¡En camino!',
                                              style: GoogleFonts.montserrat(
                                                  color: themeProvider.isDarkTheme
                                                      ? page
                                                      : newRedColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: size.width * 0.04),
                                            )
                                          : (driverReq['is_driver_arrived'] == 1 &&
                                                  driverReq['is_trip_start'] == 0)
                                              ? Text(
                                                  'Esperando un pasajero',
                                                  style: GoogleFonts.montserrat(
                                                      color:
                                                          themeProvider.isDarkTheme
                                                              ? page
                                                              : newRedColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: size.width * 0.04),
                                                )
                                              : Text(
                                                  'LLegando al destino',
                                                  style: GoogleFonts.montserrat(
                                                      color:
                                                          themeProvider.isDarkTheme
                                                              ? page
                                                              : newRedColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: size.width * 0.04),
                                                ),
                                      const Spacer(),
                                      (driverReq['is_driver_arrived'] == 0)
                                          ? Image.asset(
                                              'assets/images/icono1.png',
                                              width: size.width * 0.14,
                                            )
                                          : (driverReq['is_driver_arrived'] == 1 &&
                                                  driverReq['is_trip_start'] == 0)
                                              ? Image.asset(
                                                  'assets/images/icono2.png',
                                                  width: size.width * 0.14,
                                                )
                                              : Image.asset(
                                                  'assets/images/icono3.png',
                                                  width: size.width * 0.14,
                                                )
                                    ],
                                  ),
                                ),
                                //*ACA EMPIEZA LA CABECERA
                                SizedBox(
                                  width: size.width * 1,
                                  height: size.height * 0.12,
                                  child: Container(
                                    // height: size.height * 0.4,
                                    decoration: BoxDecoration(
                                      // color: Colors.amber,
            
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: userDetails[
                                                            'profile_picture'] ==
                                                        null
                                                    ? const DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/disablecar.png'),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : DecorationImage(
                                                        image: NetworkImage(
                                                          userDetails[
                                                              'profile_picture'],
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                border: Border.all(
                                                    color: newRedColor, width: 2.5),
                                              ),
                                            ),
                                            SizedBox(width: size.width * 0.05),
                                            Row(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.5,
                                                      child: Text(
                                                        driverReq['userDetail'] == null 
                                                        ? '' 
                                                        :  driverReq['userDetail']['data']['name'] ?? '',
                                                        maxLines: 2,
                                                        style:
                                                            GoogleFonts.montserrat(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                   driverReq['userDetail'] == null ? Container() : Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: starsColor,
                                                        ),
                                                        Text(
                                                            (driverReq['userDetail']
                                                                            ['data']
                                                                        [
                                                                        'rating'] ==
                                                                    0)
                                                                ? '0.0'
                                                                : driverReq['userDetail']
                                                                            ['data']
                                                                        ['rating']
                                                                    .toString(),
                                                            style: GoogleFonts
                                                                .montserrat()),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: size.width * 0.03),
                                                // if (driverReq['is_trip_start'] != 1)
                                                 GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ChatPage(),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                              blurRadius: 2,
                                                              color: Colors.black
                                                                  .withOpacity(0.2),
                                                              spreadRadius: 2)
                                                        ],
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                          size.width * 0.02,
                                                        ),
                                                      ),
                                                      child: Material(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                            size.width * 0.02,
                                                          ),
                                                        ),
                                                        color: Colors.black,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const ChatPage()));
                                                          },
                                                          child: Shimmer.fromColors(
                                                            baseColor: Colors.white,
                                                            highlightColor: theme,
                                                            child: SizedBox(
                                                              height:
                                                                  size.width * 0.12,
                                                              width:
                                                                  size.width * 0.12,
                                                              child: Icon(
                                                                  Icons.chat,
                                                                  color: theme,
                                                                  size: size.width *
                                                                      0.068),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //*ACA TERMINA LA CABECERA
                                (driverReq['transport_type'] == 'taxi')
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.2,
                                            vertical: 10),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: newRedColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: 
                                          driverReq['is_trip_end'] == 1 
                                          || (driverReq['is_driver_arrived'] == 0 
                                          && (isPressed == true ||currentPositionNew ==null ||
                                                          calcularDistancia(
                                                                  currentPositionNew!,
                                                                  fmlt.LatLng(
                                                                      latRecoger!,
                                                                      lonRecoger!),
                                                                  'RECOGIDA') > 100)) 
                                                                  || ((latitudeDestino != null &&
                                                          longitudeDestino !=
                                                              null &&
                                                          latitudeDestino != 0.0 &&
                                                          longitudeDestino !=
                                                              0.0) &&
                                                      driverReq['is_trip_start'] ==
                                                          1 &&
                                                      calcularDistancia(
                                                              currentPositionNew!,
                                                              fmlt.LatLng(
                                                                  latitudeDestino!,
                                                                  longitudeDestino!),
                                                              'DESTINO') >
                                                          100)
                                              ? null
                                              : () async {
                                                  final FlutterTts flutterTts =
                                                      FlutterTts();
                                                  flutterTts.setLanguage("es-ES");
                                                  setState(() {
                                                    isPressed = true;
                                                  });
            
                                                  if (driverReq['is_driver_arrived'] == 0) {
                                                    _isLoading = true;
                                                    await driverArrived();
                                                    _isLoading = false;
                                                    flutterTts.speak( 'Ahora te encuentras en el lugar de recogida');
                                                    setState(() {
                                                      isPressed = false;
                                                    });
                                                  } else if (driverReq[ 'is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0) {
                                                    _isLoading = true;
                                                    await tripStartDispatcher();
                                                      _isLoading = false;
                                                    flutterTts.speak('Iniciaste el viaje');
                                                    setState(() {
                                                      isPressed = false;
                                                    });
                                                  } else {
                                                     _isLoading = true;
                                                    await endTrip();
                                                     _isLoading = false;
                                                    // var res = await userRating('');
                                                    flutterTts.speak('Finalizaste el viaje');
                                                    setState(() {
                                                      isPressed = false;
                                                    });
            
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    setState(() {
                                                      dropProvider
                                                              .mostrardDibujadoDestino =
                                                          false;
                                                      prefs.remove(
                                                          'mostrardDibujadoDestino');
                                                      prefs.remove(
                                                          'puntosRutaDestino');
                                                      prefs.remove(
                                                          'longitudeDestino');
                                                      prefs.remove(
                                                          'latitudeDestino');
                                                    });
            
                                                    // if (res == true) {
                                                      pref.remove('requestId');
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const Maps()),
                                                          (route) => false);
                                                    // }
                                                  }
                                                },
                                          child: MyTextWidget(
                                            driverReq: driverReq,
                                            languages: languages,
                                            choosenLanguage: choosenLanguage,
                                          ),
                                          // child: driverReq['is_trip_end'] == 1 ||
                                          //         (driverReq['is_driver_arrived'] == 0 &&
                                          //             (isPressed == true || currentPos == null)) ||
                                          //         ((latitudeDestino != null &&
                                          //                 longitudeDestino != null &&
                                          //                 latitudeDestino != 0.0 &&
                                          //                 longitudeDestino != 0.0) &&
                                          //             driverReq['is_trip_start'] == 1)
                                          //     ? Padding(
                                          //         padding: const EdgeInsets.all(4.0),
                                          //         child: CircularProgressIndicator(
                                          //           color: Colors.white,
                                          //         ),
                                          //       )
                                          //     : MyTextWidget(
                                          //         driverReq: driverReq,
                                          //         languages: languages,
                                          //         choosenLanguage: choosenLanguage,
                                          //       ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: newRedColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () async {
                                          // navigationtype = false;
                                          // setState(() {
                                          //   _isLoading = true;
                                          // });
                                          // if ((driverReq[
                                          //         'is_driver_arrived'] ==
                                          //     0)) {
                                          //   var val = await driverArrived();
                                          //   if (val == 'logout') {
                                          //     navigateLogout();
                                          //   }
                                          // } else if (driverReq[
                                          //             'is_driver_arrived'] ==
                                          //         1 &&
                                          //     driverReq['is_trip_start'] ==
                                          //         0) {
                                          //   if (driverReq[
                                          //               'show_otp_feature'] ==
                                          //           false &&
                                          //       driverReq['enable_shipment_load_feature']
                                          //               .toString() ==
                                          //           '0') {
                                          //     var val =
                                          //         await tripStartDispatcher();
                                          //     if (val == 'logout') {
                                          //       navigateLogout();
                                          //     }
                                          //   } else {
                                          //     setState(() {
                                          //       shipLoadImage = null;
                                          //       _errorOtp = false;
                                          //       getStartOtp = true;
                                          //     });
                                          //   }
                                          // } else {
                                          //   if (driverReq[
                                          //               'enable_shipment_unload_feature']
                                          //           .toString() ==
                                          //       '1') {
                                          //     setState(() {
                                          //       unloadImage = true;
                                          //     });
                                          //   } else if (driverReq[
                                          //                   'enable_shipment_unload_feature']
                                          //               .toString() ==
                                          //           '0' &&
                                          //       driverReq['enable_digital_signature']
                                          //               .toString() ==
                                          //           '1') {
                                          //     Navigator.push(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //             builder: (context) =>
                                          //                 const DigitalSignature()));
                                          //   } else {
                                          //     var val = await endTrip();
                                          //     if (val == 'logout') {
                                          //       navigateLogout();
                                          //     }
                                          //   }
                                          // }
            
                                          // _isLoading = false;
                                        },
                                        child: const Text('Espere un momento...', style: TextStyle(color: Colors.white),),
                                        // child: MyTextWidget(driverReq: driverReq, languages: languages, choosenLanguage: choosenLanguage),
                                        // child: (driverReq['is_driver_arrived'] == 0)
                                        //     ? Text(languages[choosenLanguage]
                                        //         ['text_arrived'], )
                                        //     : (driverReq['is_driver_arrived'] == 1 &&
                                        //             driverReq['is_trip_start'] == 0)
                                        //         ? Text(languages[choosenLanguage]
                                        //             ['text_shipment_load'], )
                                        //         : Text(languages[choosenLanguage]
                                        //             ['text_shipment_unload'], ),
                                      ),
            
                                //*DONDE INDICA DONDE SE RECOGERA
                                // Column(
                                //   children: [
                                //     if (driverReq['transport_type'] == 'delivery')
                                //       Column(
                                //         children: [
                                //           SizedBox(
                                //             height: size.width * 0.02,
                                //           ),
                                //           SizedBox(
                                //             width: size.width * 0.9,
                                //             child: Text(
                                //               '${driverReq['goods_type']} - ${driverReq['goods_type_quantity']}',
                                //               style: GoogleFonts.notoSans(
                                //                   fontSize: size.width * fourteen,
                                //                   fontWeight: FontWeight.w600,
                                //                   color: buttonColor),
                                //               textAlign: TextAlign.center,
                                //               maxLines: 2,
                                //               overflow: TextOverflow.ellipsis,
                                //             ),
                                //           ),
                                //           SizedBox(
                                //             height: size.width * 0.02,
                                //           ),
                                //         ],
                                //       ),
                                //     Column(
                                //       children: addressList
                                //           .asMap()
                                //           .map((k, value) => MapEntry(
                                //               k,
                                //               (addressList[k].type == 'pickup')
                                //                   ? Column(
                                //                       crossAxisAlignment:
                                //                           CrossAxisAlignment.start,
                                //                       children: [
                                //                         Container(
                                //                           width: size.width * 0.9,
                                //                           padding: EdgeInsets.all(
                                //                               size.width * 0.03),
                                //                           margin: EdgeInsets.only(
                                //                               bottom: size.width *
                                //                                   0.02),
                                //                           decoration: BoxDecoration(
                                //                             // border: Border.all(color: Colors.grey),
                                //                             boxShadow: [
                                //                               BoxShadow(
                                //                                   color: themeProvider
                                //                                           .isDarkTheme
                                //                                       ? Colors.black
                                //                                       : Color
                                //                                           .fromARGB(
                                //                                               255,
                                //                                               204,
                                //                                               203,
                                //                                               203),
                                //                                   blurRadius: 3.0,
                                //                                   // spreadRadius: 1.1,
                                //                                   offset: Offset(
                                //                                       0.0, 2.0))
                                //                             ],
                                //                             color: themeProvider
                                //                                     .isDarkTheme
                                //                                 ? Color.fromRGBO(
                                //                                     71, 71, 71, 1)
                                //                                 : page,
                                //                             borderRadius:
                                //                                 BorderRadius
                                //                                     .circular(
                                //                               size.width * 0.02,
                                //                             ),
                                //                           ),
                                //                           child: Column(
                                //                             crossAxisAlignment:
                                //                                 CrossAxisAlignment
                                //                                     .start,
                                //                             mainAxisAlignment:
                                //                                 MainAxisAlignment
                                //                                     .start,
                                //                             children: [
                                //                               Row(
                                //                                 crossAxisAlignment:
                                //                                     CrossAxisAlignment
                                //                                         .start,
                                //                                 children: [
                                //                                   Padding(
                                //                                     padding:
                                //                                         const EdgeInsets
                                //                                             .all(
                                //                                             4.0),
                                //                                     child:
                                //                                         Container(
                                //                                       width:
                                //                                           size.width *
                                //                                               0.05,
                                //                                       height:
                                //                                           size.width *
                                //                                               0.05,
                                //                                       decoration: BoxDecoration(
                                //                                           shape: BoxShape
                                //                                               .circle,
                                //                                           color: Colors
                                //                                               .green
                                //                                               .withOpacity(
                                //                                                   0.4)),
                                //                                       alignment:
                                //                                           Alignment
                                //                                               .center,
                                //                                       child:
                                //                                           Container(
                                //                                         width: size
                                //                                                 .width *
                                //                                             0.025,
                                //                                         height: size
                                //                                                 .width *
                                //                                             0.025,
                                //                                         decoration:
                                //                                             const BoxDecoration(
                                //                                           shape: BoxShape
                                //                                               .circle,
                                //                                           color: Colors
                                //                                               .green,
                                //                                         ),
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //                                   SizedBox(
                                //                                     width:
                                //                                         size.width *
                                //                                             0.02,
                                //                                   ),
                                //                                   Expanded(
                                //                                     child: Column(
                                //                                       crossAxisAlignment:
                                //                                           CrossAxisAlignment
                                //                                               .start,
                                //                                       children: [
                                //                                         Row(
                                //                                           mainAxisAlignment:
                                //                                               MainAxisAlignment
                                //                                                   .start,
                                //                                           children: [
                                //                                             MyText(
                                //                                                 text:
                                //                                                     'Lugar de recogida',
                                //                                                 size: size.width *
                                //                                                     fourteen,
                                //                                                 fontweight: FontWeight
                                //                                                     .w600,
                                //                                                 color: const Color.fromARGB(
                                //                                                     255,
                                //                                                     114,
                                //                                                     114,
                                //                                                     114)),
                                //                                           ],
                                //                                         ),
                                //                                         MyText(
                                //                                             text:
                                //                                                 lugarRecogida,
                                //                                             size: size.width *
                                //                                                 fourteen,
                                //                                             fontweight:
                                //                                                 FontWeight
                                //                                                     .w600,
                                //                                             color: Colors
                                //                                                 .grey),
                                //                                       ],
                                //                                     ),
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     )
                                //                   : Container()))
                                //           .values
                                //           .toList(),
                                //     ),
                                //     //*ACA ES EL PUINTO DE ABANDONO
                                //     Column(
                                //         children: addressList
                                //             .asMap()
                                //             .map((k, value) => MapEntry(
                                //                 k,
                                //                 (addressList[k].type == 'drop')
                                //                     ? Column(
                                //                         children: [
                                //                           (k ==
                                //                                   addressList
                                //                                           .length -
                                //                                       1)
                                //                               ? Container(
                                //                                   width:
                                //                                       size.width *
                                //                                           0.9,
                                //                                   padding:
                                //                                       EdgeInsets.all(
                                //                                           size.width *
                                //                                               0.03),
                                //                                   margin: EdgeInsets.only(
                                //                                       bottom:
                                //                                           size.width *
                                //                                               0.02),
                                //                                   decoration: BoxDecoration(
                                //                                       boxShadow: const [
                                //                                         BoxShadow(
                                //                                             color: Color.fromARGB(
                                //                                                 255,
                                //                                                 204,
                                //                                                 203,
                                //                                                 203),
                                //                                             blurRadius:
                                //                                                 3.0,
                                //                                             // spreadRadius: 1.1,
                                //                                             offset: Offset(
                                //                                                 0.0,
                                //                                                 2.0))
                                //                                       ],
                                //                                       color: page,
                                //                                       borderRadius:
                                //                                           BorderRadius.circular(
                                //                                               size.width *
                                //                                                   0.02)),
                                //                                   child: Column(
                                //                                     children: [
                                //                                       Row(
                                //                                         crossAxisAlignment:
                                //                                             CrossAxisAlignment
                                //                                                 .start,
                                //                                         children: [
                                //                                           Padding(
                                //                                             padding: const EdgeInsets
                                //                                                 .all(
                                //                                                 4.0),
                                //                                             child:
                                //                                                 Icon(
                                //                                               Icons
                                //                                                   .location_on,
                                //                                               size: size.width *
                                //                                                   0.05,
                                //                                               color:
                                //                                                   const Color(0xffF52D56),
                                //                                             ),
                                //                                           ),
                                //                                           SizedBox(
                                //                                             width: size.width *
                                //                                                 0.02,
                                //                                           ),
                                //                                           Expanded(
                                //                                             child:
                                //                                                 Column(
                                //                                               crossAxisAlignment:
                                //                                                   CrossAxisAlignment.start,
                                //                                               children: [
                                //                                                 Row(
                                //                                                   mainAxisAlignment: MainAxisAlignment.start,
                                //                                                   children: [
                                //                                                     MyText(
                                //                                                       text: 'Lugar de destino',
                                //                                                       size: size.width * fourteen,
                                //                                                       fontweight: FontWeight.w600,
                                //                                                       color: const Color.fromARGB(255, 114, 114, 114),
                                //                                                     ),
                                //                                                   ],
                                //                                                 ),
                                //                                                 MyText(
                                //                                                   text: lugarDestino,
                                //                                                   size: size.width * fourteen,
                                //                                                   fontweight: FontWeight.w600,
                                //                                                   color: Colors.grey,
                                //                                                 ),
                                //                                               ],
                                //                                             ),
                                //                                           ),
                                //                                           if (driverReq['transport_type'] ==
                                //                                                   'delivery' &&
                                //                                               driverReq['is_trip_start'] ==
                                //                                                   1)
                                //                                             IconButton(
                                //                                                 onPressed:
                                //                                                     () {
                                //                                                   makingPhoneCall(addressList[k].number);
                                //                                                 },
                                //                                                 icon:
                                //                                                     const Icon(Icons.call))
                                //                                         ],
                                //                                       ),
                                //                                       if (driverReq[
                                //                                                   'transport_type'] ==
                                //                                               'delivery' &&
                                //                                           driverReq[
                                //                                                   'is_trip_start'] ==
                                //                                               0)
                                //                                         SizedBox(
                                //                                           height: size
                                //                                                   .width *
                                //                                               0.025,
                                //                                         ),
                                //                                       if (addressList[
                                //                                                   k]
                                //                                               .instructions !=
                                //                                           null)
                                //                                         Column(
                                //                                           children: [
                                //                                             Row(
                                //                                               children: [
                                //                                                 for (var i = 0;
                                //                                                     i < 50;
                                //                                                     i++)
                                //                                                   Container(
                                //                                                     margin: EdgeInsets.only(right: (i < 49) ? 2 : 0),
                                //                                                     width: (size.width * 0.8 - 98) / 50,
                                //                                                     height: 1,
                                //                                                     color: borderColor,
                                //                                                   )
                                //                                               ],
                                //                                             ),
                                //                                             SizedBox(
                                //                                               height:
                                //                                                   size.width * 0.015,
                                //                                             ),
                                //                                             Row(
                                //                                               children: [
                                //                                                 MyText(
                                //                                                   color: Colors.red,
                                //                                                   text: languages[choosenLanguage]['text_instructions'] + ' :- ',
                                //                                                   size: size.width * twelve,
                                //                                                   fontweight: FontWeight.w600,
                                //                                                   maxLines: 1,
                                //                                                 ),
                                //                                               ],
                                //                                             ),
                                //                                             SizedBox(
                                //                                               height:
                                //                                                   size.width * 0.015,
                                //                                             ),
                                //                                             Row(
                                //                                               children: [
                                //                                                 SizedBox(
                                //                                                   width: size.width * 0.1,
                                //                                                 ),
                                //                                                 Expanded(
                                //                                                   child: MyText(
                                //                                                     color: greyText,
                                //                                                     text: (addressList[k].type == 'drop') ? addressList[k].instructions : 'nil',
                                //                                                     size: size.width * twelve,
                                //                                                     fontweight: FontWeight.normal,
                                //                                                     maxLines: 5,
                                //                                                   ),
                                //                                                 ),
                                //                                               ],
                                //                                             )
                                //                                           ],
                                //                                         ),
                                //                                     ],
                                //                                   ),
                                //                                 )
                                //                               : Container(
                                //                                   width:
                                //                                       size.width *
                                //                                           0.9,
                                //                                   padding:
                                //                                       EdgeInsets.all(
                                //                                           size.width *
                                //                                               0.03),
                                //                                   margin: EdgeInsets.only(
                                //                                       bottom:
                                //                                           size.width *
                                //                                               0.02),
                                //                                   decoration: BoxDecoration(
                                //                                       color: Colors
                                //                                           .grey
                                //                                           .withOpacity(
                                //                                               0.1),
                                //                                       borderRadius:
                                //                                           BorderRadius.circular(
                                //                                               size.width *
                                //                                                   0.02)),
                                //                                   child: Column(
                                //                                     children: [
                                //                                       Row(
                                //                                         crossAxisAlignment:
                                //                                             CrossAxisAlignment
                                //                                                 .start,
                                //                                         children: [
                                //                                           Container(
                                //                                             height: size.width *
                                //                                                 0.05,
                                //                                             width: size.width *
                                //                                                 0.05,
                                //                                             alignment:
                                //                                                 Alignment.center,
                                //                                             child:
                                //                                                 MyText(
                                //                                               text:
                                //                                                   (k).toString(),
                                //                                               size: size.width *
                                //                                                   fourteen,
                                //                                               color:
                                //                                                   verifyDeclined,
                                //                                               fontweight:
                                //                                                   FontWeight.w600,
                                //                                             ),
                                //                                           ),
                                //                                           SizedBox(
                                //                                             width: size.width *
                                //                                                 0.02,
                                //                                           ),
                                //                                           Expanded(
                                //                                             child:
                                //                                                 Column(
                                //                                               crossAxisAlignment:
                                //                                                   CrossAxisAlignment.start,
                                //                                               children: [
                                //                                                 MyText(
                                //                                                   color: greyText,
                                //                                                   text: (addressList[k].type == 'drop') ? addressList[k].address : 'nil',
                                //                                                   size: size.width * twelve,
                                //                                                   fontweight: FontWeight.normal,
                                //                                                   maxLines: 5,
                                //                                                 ),
                                //                                               ],
                                //                                             ),
                                //                                           ),
                                //                                           if (driverReq['transport_type'] ==
                                //                                                   'delivery' &&
                                //                                               driverReq['is_trip_start'] ==
                                //                                                   1)
                                //                                             IconButton(
                                //                                                 onPressed:
                                //                                                     () {
                                //                                                   makingPhoneCall(addressList[k].number);
                                //                                                 },
                                //                                                 icon:
                                //                                                     const Icon(Icons.call))
                                //                                         ],
                                //                                       ),
                                //                                       if (addressList[
                                //                                                   k]
                                //                                               .instructions !=
                                //                                           null)
                                //                                         Column(
                                //                                           children: [
                                //                                             Row(
                                //                                               children: [
                                //                                                 for (var i = 0;
                                //                                                     i < 50;
                                //                                                     i++)
                                //                                                   Container(
                                //                                                     margin: EdgeInsets.only(right: (i < 49) ? 2 : 0),
                                //                                                     width: (size.width * 0.8 - 98) / 50,
                                //                                                     height: 1,
                                //                                                     color: borderColor,
                                //                                                   )
                                //                                               ],
                                //                                             ),
                                //                                             SizedBox(
                                //                                               height:
                                //                                                   size.width * 0.015,
                                //                                             ),
                                //                                             Row(
                                //                                               children: [
                                //                                                 MyText(
                                //                                                   color: Colors.red,
                                //                                                   text: languages[choosenLanguage]['text_instructions'] + ' :- ',
                                //                                                   size: size.width * twelve,
                                //                                                   fontweight: FontWeight.w600,
                                //                                                   maxLines: 1,
                                //                                                 ),
                                //                                               ],
                                //                                             ),
                                //                                             SizedBox(
                                //                                               height:
                                //                                                   size.width * 0.015,
                                //                                             ),
                                //                                             Row(
                                //                                               children: [
                                //                                                 SizedBox(
                                //                                                   width: size.width * 0.1,
                                //                                                 ),
                                //                                                 Expanded(
                                //                                                   child: MyText(
                                //                                                     color: greyText,
                                //                                                     text: (addressList[k].type == 'drop') ? addressList[k].instructions : 'nil',
                                //                                                     size: size.width * twelve,
                                //                                                     fontweight: FontWeight.normal,
                                //                                                     maxLines: 5,
                                //                                                   ),
                                //                                                 ),
                                //                                               ],
                                //                                             )
                                //                                           ],
                                //                                         ),
                                //                                     ],
                                //                                   ),
                                //                                 ),
                                //                         ],
                                //                       )
                                //                     : Container()))
                                //             .values
                                //             .toList()),
                                //     SizedBox(
                                //       height: size.width * 0.025,
                                //     ),
                                //     (driverReq['is_luggage_available'] == 1 ||
                                //             driverReq['is_pet_available'] == 1)
                                //         ? Column(
                                //             children: [
                                //               Row(
                                //                 children: [
                                //                   MyText(
                                //                     text: languages[choosenLanguage]
                                //                             [
                                //                             'text_ride_preference'] +
                                //                         ' :- ',
                                //                     size: size.width * fourteen,
                                //                     fontweight: FontWeight.w600,
                                //                   ),
                                //                   SizedBox(
                                //                     width: size.width * 0.025,
                                //                   ),
                                //                   if (driverReq[
                                //                           'is_pet_available'] ==
                                //                       1)
                                //                     Row(
                                //                       children: [
                                //                         Icon(Icons.pets,
                                //                             size: size.width * 0.05,
                                //                             color: theme),
                                //                         SizedBox(
                                //                           width: size.width * 0.01,
                                //                         ),
                                //                         MyText(
                                //                           text: languages[
                                //                                   choosenLanguage]
                                //                               ['text_pets'],
                                //                           size:
                                //                               size.width * fourteen,
                                //                           fontweight:
                                //                               FontWeight.w600,
                                //                           color: theme,
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   if (driverReq[
                                //                               'is_luggage_available'] ==
                                //                           1 &&
                                //                       driverReq[
                                //                               'is_pet_available'] ==
                                //                           1)
                                //                     MyText(
                                //                       text: ', ',
                                //                       size: size.width * fourteen,
                                //                       fontweight: FontWeight.w600,
                                //                       color: theme,
                                //                     ),
                                //                   if (driverReq[
                                //                           'is_luggage_available'] ==
                                //                       1)
                                //                     Row(
                                //                       children: [
                                //                         // Icon(Icons.luggage, size: size.width * 0.05, color: theme),
                                //                         SizedBox(
                                //                           height: size.width * 0.05,
                                //                           width: size.width * 0.075,
                                //                           child: Image.asset(
                                //                             'assets/images/luggages.png',
                                //                             color: theme,
                                //                           ),
                                //                         ),
                                //                         SizedBox(
                                //                           width: size.width * 0.01,
                                //                         ),
                                //                         MyText(
                                //                           text: languages[
                                //                                   choosenLanguage]
                                //                               ['text_luggages'],
                                //                           size:
                                //                               size.width * fourteen,
                                //                           fontweight:
                                //                               FontWeight.w600,
                                //                           color: theme,
                                //                         ),
                                //                       ],
                                //                     ),
                                //                 ],
                                //               ),
                                //               SizedBox(
                                //                 height: size.width * 0.025,
                                //               ),
                                //             ],
                                //           )
                                //         : Container(),
                                //     (driverReq['is_rental'] == false &&
                                //             driverReq['drop_address'] == null)
                                //         ? Container()
                                //         : SizedBox(
                                //             width: size.width * 0.6,
                                //             // color: Colors.amber,
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 // MyText(
                                //                 //   text: languages[choosenLanguage]
                                //                 //       ['text_payingvia'],
                                //                 //   size: size.width * sixteen,
                                //                 //   fontweight: FontWeight.w600,
                                //                 //   color: textColor,
                                //                 // ),
                                //                 SizedBox(
                                //                   height: size.width * 0.025,
                                //                 ),
                                //                 Row(
                                //                   mainAxisAlignment:
                                //                       MainAxisAlignment
                                //                           .spaceBetween,
                                //                   children: [
                                //                     Expanded(
                                //                       child: Row(
                                //                         children: [
                                //                           Image.asset(
                                //                             (driverReq['payment_opt']
                                //                                         .toString() ==
                                //                                     '1')
                                //                                 ? 'assets/images/cash.png'
                                //                                 : (driverReq['payment_opt']
                                //                                             .toString() ==
                                //                                         '2')
                                //                                     ? 'assets/images/Wallet.png'
                                //                                     : 'assets/images/card.png',
                                //                             width:
                                //                                 size.width * 0.06,
                                //                           ),
                                //                           SizedBox(
                                //                             width:
                                //                                 size.width * 0.02,
                                //                           ),
                                //                           MyText(
                                //                               text: (driverReq['payment_opt']
                                //                                           .toString() ==
                                //                                       '1')
                                //                                   ? languages[
                                //                                           choosenLanguage]
                                //                                       ['text_cash']
                                //                                   : (driverReq['payment_opt']
                                //                                               .toString() ==
                                //                                           '2')
                                //                                       ? languages[
                                //                                               choosenLanguage]
                                //                                           [
                                //                                           'text_wallet']
                                //                                       : languages[
                                //                                               choosenLanguage]
                                //                                           [
                                //                                           'text_card'],
                                //                               size: size.width *
                                //                                   fourteen,
                                //                               fontweight:
                                //                                   FontWeight.w500)
                                //                         ],
                                //                       ),
                                //                     ),
                                //                     SizedBox(
                                //                       width: size.width * 0.02,
                                //                     ),
                                //                     Row(
                                //                       mainAxisAlignment:
                                //                           MainAxisAlignment.end,
                                //                       children: [
                                //                         SizedBox(
                                //                           width: size.width * 0.02,
                                //                         ),
                                //                         MyText(
                                //                           text: ((driverReq[
                                //                                       'is_bid_ride'] ==
                                //                                   1))
                                //                               ? '${driverReq['requested_currency_symbol']}${driverReq['accepted_ride_fare'].toStringAsFixed(0)}'
                                //                               : '${driverReq['requested_currency_symbol']}${driverReq['request_eta_amount'].toStringAsFixed(0)}',
                                //                           size:
                                //                               size.width * sixteen,
                                //                           fontweight:
                                //                               FontWeight.w600,
                                //                           color: textColor,
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ],
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //   ],
                                // ),
            
                                //*Aca termina donde se recojera
                                SizedBox(
                                  height: size.height * 0.02,
                                ),
                                //*BOTON CANCELAR
                                BotonCancel(
                                  driverReq: driverReq,
                                  languages: languages,
                                  choosenLanguage: choosenLanguage,
                                  onTapCancelar: widget.onTapCancelar,
                                )
                                // (driverReq['is_trip_start'] == 1)
                                //     ? Container() // Si el viaje ya comenzó, no se muestra nada
                                //     : driverReq['is_driver_arrived'] == 0
                                //         ? Container() // Si el conductor no ha llegado, no se muestra nada
                                //         : BotonCancel(
                                //             driverReq: driverReq,
                                //             languages: languages,
                                //             choosenLanguage: choosenLanguage,
                                //             onTapCancelar: widget.onTapCancelar,
                                //           )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
             if (_isLoading == true) const Positioned(child: Loading())
          ],
        );
      },
    );
  }
}

class BotonCancel extends StatefulWidget {
  final Map<String, dynamic> driverReq;
  final Map<String, dynamic> languages;
  final String choosenLanguage;
  final Function()? onTapCancelar;

  BotonCancel({
    required this.driverReq,
    required this.languages,
    required this.choosenLanguage,
    required this.onTapCancelar,
  });

  @override
  _BotonCancelState createState() => _BotonCancelState();
}

class _BotonCancelState extends State<BotonCancel>
    with AutomaticKeepAliveClientMixin {
  // bool activarCancelarBoton = false;
  bool yaEntro = false;
  int tiempoRestante = 5 * 60; // 5 minutos en segundos
  // late Timer _timer;

  @override
  void initState() {
    super.initState();
    // if (widget.driverReq['is_driver_arrived'] == 1 && !yaEntro) {
    //   yaEntro = true;
    //   iniciarTemporizador();
    // }
  }

  // void iniciarTemporizador() {
  //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (tiempoRestante > 0) {
  //       setState(() {
  //         tiempoRestante--;
  //       });
  //     } else {
  //       setState(() {
  //         activarCancelarBoton = true;
  //       });
  //       _timer.cancel();
  //     }
  //   });
  // }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  String _formatTiempo(int segundos) {
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final segundosRestantes = (segundos % 60).toString().padLeft(2, '0');
    return '$minutos:$segundosRestantes';
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    final languages = widget.languages;
    final choosenLanguage = widget.choosenLanguage;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
      ),
      child: Container(
        height: size.height * 0.05,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: widget.onTapCancelar,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/cancelride.png',
                        height: size.width * 0.064,
                        width: size.width * 0.064,
                        fit: BoxFit.contain,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        languages[choosenLanguage]['text_cancel_booking'],
                        style: GoogleFonts.montserrat(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                // if (!activarCancelarBoton)
                //   Row(
                //     children: [
                //       Icon(
                //         Icons.timer,
                //         color: Colors.red,
                //         size: size.width * 0.06,
                //       ),
                //       SizedBox(width: 5),
                //       Text(
                //         _formatTiempo(tiempoRestante),
                //         style: GoogleFonts.montserrat(
                //           color: Colors.red,
                //           fontWeight: FontWeight.bold,
                //           fontSize: size.width * 0.035,
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.12,
              ),
              child: const Divider(),
            ),
          ],
        ),
      ),
    );
  }
}

class CancelarButton extends StatelessWidget {
  const CancelarButton({
    super.key,
    required this.size,
    required this.widget,
  });

  final Size size;
  final BottomCardSheetDriverAccept widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
      ),
      child: Container(
        height: size.height * 0.05,
        decoration: BoxDecoration(
            // color: newRedColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: widget.onTapCancelar,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/cancelride.png',
                        height: size.width * 0.064,
                        width: size.width * 0.064,
                        fit: BoxFit.contain,
                        color: Colors.grey,
                      ),
                      Text(
                        languages[choosenLanguage]['text_cancel_booking'],
                        style: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * twelve,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
              child: const Divider(),
            )
          ],
        ),
      ),
    );
  }
}
