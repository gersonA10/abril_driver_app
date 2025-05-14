import 'package:abril_driver_app/providers/speech_provider.dart';
import 'package:flutter/material.dart';
import 'package:abril_driver_app/pages/NavigatorPages/outstation.dart';
import 'package:abril_driver_app/pages/NavigatorPages/selectlanguage.dart';
import 'package:abril_driver_app/pages/NavigatorPages/settings.dart';
import 'package:abril_driver_app/pages/NavigatorPages/support.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/bankdetails.dart';
import '../NavigatorPages/driverdetails.dart';
import '../NavigatorPages/driverearnings.dart';
import '../NavigatorPages/editprofile.dart';
import '../NavigatorPages/history.dart';
import '../NavigatorPages/makecomplaint.dart';
import '../NavigatorPages/managevehicles.dart';
import '../NavigatorPages/myroutebookings.dart';
import '../NavigatorPages/notification.dart';
import '../NavigatorPages/referral.dart';
import '../NavigatorPages/sos.dart';
import '../NavigatorPages/walletpage.dart';
import '../login/landingpage.dart';
import '../login/login.dart';
import '../onTripPage/map_page.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  double _speechRate = 0.5; // Velocidad inicial por defecto
  dynamic isCompleted;
  bool showFilter = false;
  // ignore: unused_field
  final bool _isLoading = false;
  // ignore: unused_field
  final String _error = '';
  List myHistory = [];
  navigateLogout() {
    if (ownermodule == '1') {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false);
      });
    } else {
      ischeckownerordriver = 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      });
    }
  }

  @override
  void initState() {
    _loadSpeechRate();
    historyFiltter = '';
    if (userDetails['chat_id'] != null && chatStream == null) {
      streamAdminchat();
    }
    super.initState();
  }

  Future<void> _loadSpeechRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble('speechRate') ?? 0.5;
    });
  }

  // Guardar la velocidad en SharedPreferences
  Future<void> _saveSpeechRate(double rate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speechRate', rate);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    var media = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: valueNotifierHome.value,
        builder: (context, value, child) {
          return SizedBox(
            height: media.height,
            width: media.width * 0.8,
            child: Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Container(
                color: Colors.white,
                child: Container(
                  height: media.height,
                  width: media.width * 0.8,
                  decoration:
                      BoxDecoration(color: page, boxShadow: [boxshadow]),
                  child: Column(
                    children: [
                      SizedBox(
                        height: media.width * 0.06 +
                            MediaQuery.of(context).padding.top,
                      ),

                      SizedBox(
                        width: media.width * 0.7,
                        child: Row(
                          children: [
                            Image.asset('assets/images/logo_conductor.png'),
                            SizedBox(
                              width: media.width * 0.05,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                    width: media.width * 0.4,
                                    child: Text(
                                      userDetails['name'],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: media.width * 0.037,
                                          color: Colors.black),
                                    )),
                                Text(
                                  userDetails['mobile'],
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: media.width * 0.037,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.height * 0.028,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: media.width * 0.05),
                        child: Divider(
                          color: newRedColor,
                        ),
                      ),
                    Align(
  alignment: Alignment.center,
  child: SizedBox(
    width: media.width * 0.7,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.speaker),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Consumer<SpeechProvider>(
              builder: (context, speechProvider, child) {
                return Slider(
                  activeColor: theme,
                  value: speechProvider.speechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 10,
                  label: speechProvider.speechRate.toStringAsFixed(1),
                  onChanged: (double value) {
                    speechProvider.setSpeechRate(value);
                  },
                );
              },
            ),
            Text(
              'Velocidad de la voz',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  ),
),

                      // InkWell(
                      //   onTap: () async {
                      //     var val = await Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => const EditProfile()));
                      //     if (val) {
                      //       setState(() {});
                      //     }
                      //   },
                      //   child: Container(
                      //     padding: EdgeInsets.all(media.width * 0.025),
                      //     width: media.width * 0.7,
                      //     decoration: BoxDecoration(
                      //       color: theme.withOpacity(0.5),
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Container(
                      //           width: media.width * 0.15,
                      //           height: media.width * 0.15,
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(8),
                      //               image: DecorationImage(
                      //                   image: NetworkImage(
                      //                       userDetails['profile_picture']),
                      //                   fit: BoxFit.cover)),
                      //         ),
                      //         SizedBox(
                      //           width: media.width * 0.025,
                      //         ),
                      //         Expanded(
                      //             child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             MyText(
                      //               text: userDetails['name'],
                      //               size: media.width * fourteen,
                      //               fontweight: FontWeight.w600,
                      //               maxLines: 1,
                      //             ),
                      //             MyText(
                      //               text: userDetails['mobile'],
                      //               size: media.width * fourteen,
                      //               fontweight: FontWeight.w500,
                      //               maxLines: 1,
                      //             ),
                      //           ],
                      //         )),
                      //         SizedBox(
                      //           width: media.width * 0.025,
                      //         ),
                      //         Icon(
                      //           Icons.arrow_forward_ios,
                      //           size: media.width * 0.04,
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // SizedBox(height: media.width*0.05,),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                width: media.width * 0.7,
                                child: NavMenu(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const History()));
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_enable_history'],
                                  icon: Icons.history,
                                ),
                              ),

                              (userDetails['role'] != 'owner')
                                  ? ValueListenableBuilder(
                                      valueListenable:
                                          valueNotifierNotification.value,
                                      builder: (context, value, child) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const NotificationPage()));
                                            setState(() {
                                              userDetails[
                                                  'notifications_count'] = 0;
                                            });
                                          },
                                          child: Container(
                                            width: media.width * 0.7,
                                            padding: EdgeInsets.only(
                                                top: media.width * 0.07),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.notifications_none,
                                                  size: media.width * 0.055,
                                                  color: textColor,
                                                ),
                                                SizedBox(
                                                  width: media.width * 0.025,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: (userDetails[
                                                                  'notifications_count'] ==
                                                              0)
                                                          ? media.width * 0.55
                                                          : media.width * 0.495,
                                                      child: MyText(
                                                        text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_notification']
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        size:
                                                            media.width * 0.035,
                                                        color: textColor,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    (userDetails[
                                                                'notifications_count'] ==
                                                            0)
                                                        ? Container()
                                                        : Container(
                                                            height: 25,
                                                            width: 25,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  buttonColor,
                                                            ),
                                                            child: Text(
                                                              userDetails[
                                                                      'notifications_count']
                                                                  .toString(),
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  color: (isDarkTheme)
                                                                      ? Colors
                                                                          .black
                                                                      : buttonText),
                                                            ),
                                                          ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                  : Container(),

                              // if (userDetails['show_outstation_ride_feature'] ==
                              //     "1")
                              //   SizedBox(
                              //     width: media.width * 0.7,
                              //     child: NavMenu(
                              //       onTap: () {
                              //         Navigator.push(
                              //             context,
                              //             MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     const OutStation()));
                              //       },
                              //       text: languages[choosenLanguage]
                              //           ['text_outstation'],
                              //       icon: Icons.luggage_outlined,
                              //     ),
                              //   ),

                              //wallet page

                              // userDetails['owner_id'] == null &&
                              //         userDetails[
                              //                 'show_wallet_feature_on_mobile_app'] ==
                              //             '1'
                              //     ? SizedBox(
                              //         width: media.width * 0.7,
                              //         child: NavMenu(
                              //           onTap: () {
                              //             Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         const WalletPage()));
                              //           },
                              //           text: languages[choosenLanguage]
                              //               ['text_enable_wallet'],
                              //           icon: Icons.payment,
                              //         ),
                              //       )
                              //     : Container(),

                              //Earnings
                              // SizedBox(
                              //   width: media.width * 0.7,
                              //   child: NavMenu(
                              //     onTap: () {
                              //       Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   const DriverEarnings()));
                              //     },
                              //     text: languages[choosenLanguage]
                              //         ['text_earnings'],
                              //     image: 'assets/images/earing.png',
                              //   ),
                              // ),

                              //manage vehicle

                              // userDetails['role'] == 'owner'
                              //     ? SizedBox(
                              //         width: media.width * 0.7,
                              //         child: NavMenu(
                              //           onTap: () {
                              //             Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         const ManageVehicles()));
                              //           },
                              //           text: languages[choosenLanguage]
                              //               ['text_manage_vehicle'],
                              //           image:
                              //               'assets/images/updateVehicleInfo.png',
                              //         ),
                              //       )
                              //     : Container(),

                              //manage Driver
                              // userDetails['role'] == 'owner'
                              //     ? SizedBox(
                              //         width: media.width * 0.7,
                              //         child: NavMenu(
                              //           onTap: () {
                              //             Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         const DriverList()));
                              //           },
                              //           text: languages[choosenLanguage]
                              //               ['text_manage_drivers'],
                              //           image: 'assets/images/managedriver.png',
                              //         ),
                              //       )
                              //     : Container(),

                              // //bank details
                              // userDetails['owner_id'] == null &&
                              //         userDetails[
                              //                 'show_bank_info_feature_on_mobile_app'] ==
                              //             "1"
                              //     ? SizedBox(
                              //         width: media.width * 0.7,
                              //         child: NavMenu(
                              //           onTap: () {
                              //             Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         const BankDetails()));
                              //           },
                              //           text: languages[choosenLanguage]
                              //               ['text_updateBank'],
                              //           icon: Icons.account_balance_outlined,
                              //         ),
                              //       )
                              //     : Container(),

                              // //sos
                              // userDetails['role'] != 'owner'
                              //     ? SizedBox(
                              //         width: media.width * 0.7,
                              //         child: NavMenu(
                              //           onTap: () async {
                              //             var nav = await Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         const Sos()));
                              //             if (nav) {
                              //               setState(() {});
                              //             }
                              //           },
                              //           text: languages[choosenLanguage]
                              //               ['text_sos'],
                              //           icon: Icons.connect_without_contact,
                              //         ),
                              //       )
                              //     : Container(),

                              //makecomplaints
                              // SizedBox(
                              //   width: media.width * 0.7,
                              //   child: NavMenu(
                              //     icon: Icons.toc,
                              //     text: languages[choosenLanguage]
                              //         ['text_make_complaints'],
                              //     onTap: () {
                              //       Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   const MakeComplaint()));
                              //     },
                              //   ),
                              // ),

                              //settings
                              // SizedBox(
                              //   width: media.width * 0.7,
                              //   child: NavMenu(
                              //     onTap: () async {
                              //       var nav = await Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   const SettingsPage()));
                              //       if (nav) {
                              //         setState(() {});
                              //       }
                              //     },
                              //     text: languages[choosenLanguage]
                              //         ['text_settings'],
                              //     icon: Icons.settings,
                              //   ),
                              // ),
                              
                              SizedBox(
                                width: media.width * 0.7,
                                child: NavMenu(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SelectLanguage()));
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_change_language'],
                                  icon: Icons.translate,
                                ),
                              ),

                              //support
                              // ValueListenableBuilder(
                              //     valueListenable: valueNotifierChat.value,
                              //     builder: (context, value, child) {
                              //       return InkWell(
                              //         onTap: () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       const SupportPage()));
                              //         },
                              //         child: Container(
                              //           width: media.width * 0.7,
                              //           padding: EdgeInsets.only(
                              //               top: media.width * 0.07),
                              //           child: Row(
                              //             children: [
                              //               Icon(Icons.support_agent,
                              //                   size: media.width * 0.04,
                              //                   color: textColor),
                              //               SizedBox(
                              //                 width: media.width * 0.025,
                              //               ),
                              //               Row(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment.spaceBetween,
                              //                 children: [
                              //                   SizedBox(
                              //                     width: (unSeenChatCount == '0')
                              //                         ? media.width * 0.55
                              //                         : media.width * 0.495,
                              //                     child: MyText(
                              //                       text:
                              //                           languages[choosenLanguage]
                              //                               ['text_support'],
                              //                       overflow:
                              //                           TextOverflow.ellipsis,
                              //                       size: media.width * sixteen,
                              //                       color: textColor,
                              //                     ),
                              //                   ),
                              //                   (unSeenChatCount == '0')
                              //                       ? Container()
                              //                       : Container(
                              //                           height: 20,
                              //                           width: 20,
                              //                           alignment:
                              //                               Alignment.center,
                              //                           decoration: BoxDecoration(
                              //                             shape: BoxShape.circle,
                              //                             color: buttonColor,
                              //                           ),
                              //                           child: Text(
                              //                             unSeenChatCount,
                              //                             style: GoogleFonts.notoSans(
                              //                                 fontSize:
                              //                                     media.width *
                              //                                         fourteen,
                              //                                 color: (isDarkTheme)
                              //                                     ? Colors.black
                              //                                     : buttonText),
                              //                           ),
                              //                         ),
                              //                 ],
                              //               )
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     }),

                              // //referral page
                              // userDetails['owner_id'] == null &&
                              //         userDetails['role'] == 'driver'
                              //     ? SizedBox(
                              //         width: media.width * 0.7,
                              //         child: NavMenu(
                              //           onTap: () {
                              //             Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         const ReferralPage()));
                              //           },
                              //           text: languages[choosenLanguage]
                              //               ['text_enable_referal'],
                              //           icon: Icons.offline_share_outlined,
                              //         ),
                              //       )
                              //     : Container(),
                              SizedBox(
                                width: media.width * 0.7,
                                child: NavMenu(
                                  onTap: () async {
                                    final Uri url = Uri.parse(
                                        'https://15deabril.macrobyte.site/privacy');
                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                    // https://15deabril.macrobyte.site/privacy
                                  },
                                  text: 'Politica de privacidad',
                                  icon: Icons.shield_outlined,
                                ),
                              ),
                              // Divider(),
                              
                              // Divider(),
                              // Padding(
                              //   padding: EdgeInsets.all(20),
                              //   child: Divider(),
                              // ),
                              //  Padding(
                              //    padding: const EdgeInsets.all(8.0),
                              //    child: ListTile(
                              //                  title: Text('Modo Oscuro', style: TextStyle(color: Colors.black),),
                              //                  trailing: Switch(
                              //                    value: themeProvider.isDarkTheme,
                              //                    onChanged: (value) {
                              //                      themeProvider.toggleTheme(); // Cambia el tema
                              //                    },
                              //                  ),
                              //                ),
                              //  ),
                              SizedBox(
                                // padding: EdgeInsets.only(top: 100),
                                width: media.width * 0.7,
                                child: NavMenu(
                                    onTap: () {
                                      setState(() {
                                        logout = true;
                                      });
                                      valueNotifierHome.incrementNotifier();
                                      Navigator.pop(context);
                                    },
                                    text: languages[choosenLanguage]
                                        ['text_sign_out'],
                                    icon: Icons.logout,
                                    textcolor: newRedColor),
                              ),

                              SizedBox(
                                height: media.width * 1,
                              ),
                              Image.asset(
                                'assets/images/logo_macrobyte.png',
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //
            ),
          );
        });
  }
}
