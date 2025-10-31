import 'package:abril_driver_app/pages/NavigatorPages/novedades_page.dart';
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
  bool _autoMaxVolume = true;
  // ignore: unused_field
  final bool _isLoading = false;
  // ignore: unused_field
  final String _error = '';
  List myHistory = [];

  Future<void> _loadAutoMaxVolume() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _autoMaxVolume = prefs.getBool('autoMaxVolume') ?? true;
  });
}

Future<void> _saveAutoMaxVolume(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('autoMaxVolume', value);
}

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
    _loadAutoMaxVolume();
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
    child: Column(
      mainAxisSize: MainAxisSize.min, // 🔥 evita altura infinita
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.speaker, color: theme),
            const SizedBox(width: 10),
            Expanded(
              child: Consumer<SpeechProvider>(
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
            ),
          ],
        ),
        Text(
          'Velocidad de la voz',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, color: theme),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Subir volumen automáticamente',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Switch(
              value: _autoMaxVolume,
              activeColor: theme,
              onChanged: (bool value) {
                setState(() {
                  _autoMaxVolume = value;
                });
                _saveAutoMaxVolume(value);
              },
            ),
          ],
        ),
      ],
    ),
  ),
),

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

                              SizedBox(
                                width: media.width * 0.7,
                                child: NavMenu(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const NovedadesPage()));
                                  },
                                  text: 'Novedades',
                                  icon: Icons.article,
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
                              SizedBox(
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
