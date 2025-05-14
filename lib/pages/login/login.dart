// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/notifications.dart';
import 'package:abril_driver_app/models/code_whats_app.dart';
import 'package:abril_driver_app/pages/onTripPage/map_page.dart';
import 'package:abril_driver_app/pages/onTripPage/rides.dart';
import 'package:abril_driver_app/pages/vehicleInformations/docs_onprocess.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'dart:math' as math;
import '../loadingPage/loading.dart';
import 'package:latlong2/latlong.dart' as fmlt;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

//code as int for getting phone dial code of choosen country
String phnumber = ''; // phone number as string entered in input field
List pages = [1, 2, 3, 4];
List images = [];
int currentPage = 0;
String name = '';
String email = ''; // email of user
String password = '';
var values = 0;
bool isfromomobile = true;

dynamic proImageFile1;
ImagePicker picker = ImagePicker();
bool pickImage = false;

late StreamController profilepicturecontroller;
StreamSink get profilepicturesink => profilepicturecontroller.sink;
Stream get profilepicturestream => profilepicturecontroller.stream;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  CodeWhatsApp? code;
  TextEditingController controller = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  bool loginLoading = true;
  final ScrollController _scroll = ScrollController();
  dynamic aController;
  String _error = '';
  bool showSignin = false;
  int signIn = 0;
  var searchVal = '';
  bool isLoginemail = true;
  bool withOtp = false;
  bool showPassword = false;
  bool showNewPassword = false;
  bool otpSent = false;
  bool _resend = false;
  int resendTimer = 60;
  bool mobileVerified = false;
  dynamic resendTime;
  bool forgotPassword = false;
  bool newPassword = false;

  Future<void> requestOverlayPermission() async {
    // Verifica si el permiso ya ha sido concedido
    if (await Permission.systemAlertWindow.isGranted) {
      print('✅ Permiso de superposición ya concedido.');
      return;
    }

    try {
      const intent = AndroidIntent(
        action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
        data: 'package:com.deabrilconductoresdriver.driver', // Tu paquete
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      await intent.launch();

      // Espera unos segundos para que el usuario dé tiempo a conceder el permiso
      await Future.delayed(const Duration(seconds: 3));

      // Puedes seguir verificando periódicamente si se otorgó
      bool granted = await Permission.systemAlertWindow.isGranted;
      if (granted) {
        print('✅ Permiso de superposición concedido después del intento.');
      } else {
        print('❌ El usuario no concedió el permiso de superposición.');
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de superposición: $e');
    }
  }

  resend() {
    resendTime?.cancel();
    resendTime = null;

    resendTime = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          _resend = true;
          resendTime?.cancel();
          timer.cancel();
          resendTime = null;
        }
      });
    });
  }

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool terms = true; //terms and conditions true or false
  late geolocator.LocationPermission permission;

  obtenerPosicionActual() async {
    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('El servicio de ubicación está deshabilitado.');
      // Aquí podrías mostrar un diálogo indicando que habiliten el servicio
      return;
    }

    // Verificar el estado de los permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Solicitar permisos si están denegados
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('El usuario denegó los permisos de ubicación.');
        // Aquí podrías mostrar un diálogo explicando por qué se necesitan los permisos
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('El usuario denegó permanentemente los permisos de ubicación.');
      // Aquí podrías redirigir al usuario a la configuración para habilitar los permisos manualmente
      return;
    }

    // Obtener la posición actual
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      setState(() {
        currentPositionNew = fmlt.LatLng(position.latitude, position.longitude);
      });
      print('Posición actual: $position');
    } catch (e) {
      print('Error al obtener la posición: $e');
    }
  }

  @override
  void initState() {
    requestOverlayPermission();

    FlutterBackgroundService().invoke('setAsForeground');
    obtenerPosicionActual();
    currentPage = 0;
    controller.text = '';
    proImageFile1 = null;
    gender = '';
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    countryCode();

    super.initState();
  }

  @override
  void dispose() {
    resendTime?.cancel();
    resendTime = null;
    super.dispose();
  }

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      proImageFile1 = pickedFile?.path;
      pickImage = false;
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    } else {
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      proImageFile1 = pickedFile?.path;
      pickImage = false;
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    } else {
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    }
  }

  navigate(verify) {
    if (verify == true) {
      if (userDetails['uploaded_document'] == true &&
          userDetails['approve'] == true) {
        if (userDetails['role'] != 'owner' &&
            userDetails['enable_bidding'] == true) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const RidePage()),
              (route) => false);
        } else if (userDetails['role'] != 'owner' &&
            userDetails['enable_bidding'] == false) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Maps()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Maps()),
              (route) => false);
        }
      } else if (userDetails['approve'] == false) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DocsProcess()),
            (route) => false);
      }
    } else if (verify == false) {
      setState(() {
        _error =
            'User Doesn\'t exists with this number, please Signup to continue';
      });
    } else {
      setState(() {
        _error = verify.toString();
      });
    }
  }

  countryCode() async {
    // isLoginemail = false;
    isfromomobile = true;
    var result = await getCountryCode();
    if (loginImages.isNotEmpty) {
      images.clear();
      for (var e in loginImages) {
        images.add(Image.network(
          e['onboarding_image'],
          gaplessPlayback: true,
          fit: BoxFit.cover,
        ));
      }
    }
    if (result == 'success') {
      setState(() {
        loginLoading = false;
      });
    } else {
      setState(() {
        loginLoading = false;
      });
    }
  }

  List landings = [
    {
      'heading': 'ASSURANCE',
      'text':
          'Customer safety first,Always and forever our pledge,Your well-being, our priority,With you every step, edge to edge.'
    },
    {
      'heading': 'CLARITY',
      'text':
          'Fair pricing, crystal clear, Your trust, our promise sincere. With us, you\'ll find no hidden fee, Transparency is our guarantee.'
    },
    {
      'heading': 'INTUTIVE',
      'text':
          'Seamless journeys, Just a tap away, Explore hassle-free, Every step of the way.'
    },
    {
      'heading': 'SUPPORT',
      'text':
          'Embark on your journey with confidence, knowing that our commitment to your satisfaction is unwavering'
    },
  ];

  //Controladores Page View
  final PageController _pageController = PageController();
  final TextEditingController _otpController = TextEditingController();
  var verifyEmailError = '';
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ValueListenableBuilder(
              valueListenable: valueNotifierLogin.value,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    SizedBox(
                      height: media.height,
                      child: (loginImages.isNotEmpty)
                          ? Column(
                              children: [
                                SizedBox(
                                  height: media.height * 0.6,
                                  width: media.width,
                                  child: ClipPath(
                                    clipper: ShapePainter(),
                                    child: images[currentPage],
                                  ),
                                ),
                                SizedBox(
                                  height: media.height * 0.18,
                                  child: PageView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    onPageChanged: (v) {
                                      setState(() {
                                        currentPage = v;
                                      });
                                    },
                                    children: loginImages
                                        .asMap()
                                        .map((k, value) => MapEntry(
                                              k,
                                              Column(
                                                children: [
                                                  MyText(
                                                      text: loginImages[k]
                                                          ['title'],
                                                      size: media.height * 0.02,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                  SizedBox(
                                                    height: media.height * 0.02,
                                                  ),
                                                  SizedBox(
                                                      width: media.width * 0.6,
                                                      child: MyText(
                                                        text: loginImages[k]
                                                            ['description'],
                                                        size: media.height *
                                                            0.015,
                                                        maxLines: 4,
                                                        textAlign:
                                                            TextAlign.center,
                                                        color: Colors.black,
                                                      )),
                                                ],
                                              ),
                                            ))
                                        .values
                                        .toList(),
                                  ),
                                ),
                                SizedBox(
                                  width: media.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: loginImages
                                        .asMap()
                                        .map((k, value) => MapEntry(
                                              k,
                                              Container(
                                                margin: EdgeInsets.only(
                                                  right: (k <
                                                              loginImages
                                                                      .length -
                                                                  1 ||
                                                          languageDirection ==
                                                              'rtl')
                                                      ? media.width * 0.025
                                                      : 0,
                                                  // left: (k < loginImages.length - 1 || languageDirection == 'ltr') ? media.width*0.025 : 0
                                                ),
                                                height: media.height * 0.01,
                                                width: media.height * 0.01,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (currentPage == k)
                                                        ? theme
                                                        : Colors.grey),
                                              ),
                                            ))
                                        .values
                                        .toList(),
                                  ),
                                )
                              ],
                            )
                          : Container(),
                    ),
                    Positioned(
                        child: (showSignin == true)
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    showSignin = false;
                                  });
                                },
                                child: Container(
                                  height: media.height,
                                  width: media.width,
                                  color: Colors.transparent.withOpacity(0.8),
                                ),
                              )
                            : Container()),
                    Positioned(
                        bottom: 0,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              height: media.height * 0.2,
                              width: media.width,
                              child: ClipPath(
                                clipper: ShapePainterBottom(),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (showSignin == false) {
                                        showSignin = true;
                                      }
                                    });
                                  },
                                  onVerticalDragStart: (v) {
                                    setState(() {
                                      if (showSignin == false) {
                                        showSignin = true;
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: theme, width: 0),
                                      color: theme,
                                    ),
                                    child: (showSignin == false)
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_sign_in'],
                                                size: media.width * sixteen,
                                                color: Colors.white,
                                                fontweight: FontWeight.w600,
                                              ),
                                              SizedBox(
                                                height: media.height * 0.01,
                                              ),
                                              Icon(
                                                Icons
                                                    .keyboard_double_arrow_up_rounded,
                                                size: media.width * 0.07,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                height: media.height * 0.01,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: media.width * 0.7,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (signIn == 1) {
                                                          setState(() {
                                                            forgotPassword =
                                                                false;
                                                            newPassword = false;
                                                            otpSent = false;
                                                            withOtp = false;
                                                            isLoginemail = true;
                                                            _error = '';
                                                            _email.clear();
                                                            _password.clear();
                                                            _name.clear();
                                                            _mobile.clear();
                                                            signIn = 0;
                                                          });
                                                        }
                                                      },
                                                      child: MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            ['text_sign_in'],
                                                        size: media.width *
                                                            sixteen,
                                                        color: (signIn == 0)
                                                            ? Colors.white
                                                            : Colors.white
                                                                .withOpacity(
                                                                    0.5),
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.05,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: (showSignin == true)
                                  ? (signIn == 0)
                                      ? media.height * 0.6 +
                                          (MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom /
                                              2)
                                      : media.height * 0.6 +
                                          (MediaQuery.of(context)
                                              .viewInsets
                                              .bottom)
                                  : 0,
                              width: media.width,
                              decoration: BoxDecoration(
                                  color: theme,
                                  border: Border.all(color: theme, width: 0)),
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  SingleChildScrollView(
                                    controller: _scroll,
                                    child: Column(
                                      children: [
                                        AnimatedCrossFade(
                                            firstChild: Container(),
                                            secondChild: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      pickImage = true;
                                                    });
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        height:
                                                            media.width * 0.2,
                                                        width:
                                                            media.width * 0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                                image: (proImageFile1 ==
                                                                        null)
                                                                    ? const DecorationImage(
                                                                        image:
                                                                            AssetImage(
                                                                          'assets/images/default-profile-picture.jpeg',
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover)
                                                                    : DecorationImage(
                                                                        image: FileImage(File(
                                                                            proImageFile1)),
                                                                        fit: BoxFit
                                                                            .cover)),
                                                      ),
                                                      Positioned(
                                                          bottom: 0,
                                                          right: 0,
                                                          child: Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.015),
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .grey),
                                                              child: Icon(
                                                                Icons.edit,
                                                                size: media
                                                                        .width *
                                                                    0.025,
                                                              )))
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                              ],
                                            ),
                                            crossFadeState: (signIn == 0)
                                                ? CrossFadeState.showFirst
                                                : CrossFadeState.showSecond,
                                            duration: const Duration(
                                                milliseconds: 200)),

                                        AnimatedCrossFade(
                                            firstChild: Container(),
                                            secondChild: Column(
                                              children: [
                                                Container(
                                                  height: media.width * 0.12,
                                                  width: media.width * 0.8,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.white),
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          media.width * 0.025,
                                                      left:
                                                          media.width * 0.025),
                                                  child: TextField(
                                                    controller: _name,
                                                    decoration: InputDecoration(
                                                        hintText: languages[
                                                                choosenLanguage]
                                                            ['text_name'],
                                                        border:
                                                            InputBorder.none),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                              ],
                                            ),
                                            crossFadeState: (signIn == 0)
                                                ? CrossFadeState.showFirst
                                                : CrossFadeState.showSecond,
                                            duration: const Duration(
                                                milliseconds: 200)),

                                        Container(
                                          height: media.width * 0.12,
                                          width: media.width * 0.8,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.white),
                                          padding: EdgeInsets.only(
                                              right: media.width * 0.025,
                                              left: media.width * 0.025),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: media.width * 0.12,
                                                  child: TextField(
                                                    keyboardType: TextInputType.number,
                                                    enabled: (otpSent == true &&
                                                            signIn == 0)
                                                        ? false
                                                        : true,
                                                    controller: _email,
                                                    onChanged: (v) {
                                                      String pattern =
                                                          r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                      RegExp regExp =
                                                          RegExp(pattern);

                                                      if (regExp.hasMatch(
                                                              _email.text) &&
                                                          isLoginemail ==
                                                              true &&
                                                          signIn == 0) {
                                                        setState(() {
                                                          isLoginemail = false;
                                                        });
                                                      } else if (isLoginemail ==
                                                              false &&
                                                          regExp.hasMatch(_email
                                                                  .text) ==
                                                              false) {
                                                        setState(() {
                                                          isLoginemail = true;
                                                        });
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                        hintText: (signIn == 0)
                                                            ? "Celular"
                                                            : "Celular",
                                                        border:
                                                            InputBorder.none),
                                                  ),
                                                ),
                                              ),
                                              if (otpSent == true &&
                                                  signIn == 0)
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _error = '';
                                                        otpSent = false;
                                                        _password.clear();
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: media.width * 0.05,
                                                    ))
                                            ],
                                          ),
                                        ),

                                        AnimatedCrossFade(
                                            firstChild: Container(),
                                            secondChild: Column(
                                              children: [
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Container(
                                                  height: media.width * 0.12,
                                                  width: media.width * 0.8,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.white),
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          media.width * 0.025,
                                                      left:
                                                          media.width * 0.025),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _newPassword,
                                                          decoration:
                                                              const InputDecoration(
                                                                  hintText:
                                                                      'Enter New Password',
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                          keyboardType:
                                                              TextInputType
                                                                  .emailAddress,
                                                          obscureText:
                                                              (showNewPassword ==
                                                                      false)
                                                                  ? true
                                                                  : false,
                                                        ),
                                                      ),
                                                      // if(withOtp == false || signIn == 1)
                                                      IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              if (showNewPassword) {
                                                                showNewPassword =
                                                                    false;
                                                              } else {
                                                                showNewPassword =
                                                                    true;
                                                              }
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .remove_red_eye_sharp,
                                                            color: (showNewPassword ==
                                                                    true)
                                                                ? const Color(
                                                                    0xffD88D0D)
                                                                : null,
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            crossFadeState:
                                                (newPassword == false)
                                                    ? CrossFadeState.showFirst
                                                    : CrossFadeState.showSecond,
                                            duration: const Duration(
                                                milliseconds: 200)),

                                        AnimatedCrossFade(
                                            firstChild: Container(),
                                            secondChild: Column(
                                              children: [
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Container(
                                                  height: media.width * 0.12,
                                                  width: media.width * 0.8,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.white),
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          media.width * 0.025,
                                                      left:
                                                          media.width * 0.025),
                                                  child: Row(
                                                    children: [
                                                      // if(isLoginemail == false && phcode != null)
                                                      InkWell(
                                                        onTap: () {
                                                          if (otpSent ==
                                                              false) {
                                                            showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (builder) {
                                                                  return Container(
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.05),
                                                                    width: media
                                                                        .width,
                                                                    color: page,
                                                                    child:
                                                                        Directionality(
                                                                      textDirection: (languageDirection ==
                                                                              'rtl')
                                                                          ? TextDirection
                                                                              .rtl
                                                                          : TextDirection
                                                                              .ltr,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 20, right: 20),
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                media.width * 0.9,
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey, width: 1.5)),
                                                                            child:
                                                                                TextField(
                                                                              decoration: InputDecoration(contentPadding: (languageDirection == 'rtl') ? EdgeInsets.only(bottom: media.width * 0.035) : EdgeInsets.only(bottom: media.width * 0.04), border: InputBorder.none, hintText: languages[choosenLanguage]['text_search'], hintStyle: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: hintColor)),
                                                                              style: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: textColor),
                                                                              onChanged: (val) {
                                                                                setState(() {
                                                                                  searchVal = val;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 20),
                                                                          Expanded(
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              child: Column(
                                                                                children: countries
                                                                                    .asMap()
                                                                                    .map((i, value) {
                                                                                      return MapEntry(
                                                                                          i,
                                                                                          // MyText(text: 'ttwer', size: 14)
                                                                                          SizedBox(
                                                                                            width: media.width * 0.9,
                                                                                            child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                                ? InkWell(
                                                                                                    onTap: () {
                                                                                                      setState(() {
                                                                                                        phcode = i;
                                                                                                      });
                                                                                                      Navigator.pop(context);
                                                                                                    },
                                                                                                    child: Container(
                                                                                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                                      color: page,
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Image.network(countries[i]['flag']),
                                                                                                              SizedBox(
                                                                                                                width: media.width * 0.02,
                                                                                                              ),
                                                                                                              SizedBox(
                                                                                                                width: media.width * 0.4,
                                                                                                                child: MyText(
                                                                                                                  text: countries[i]['name'],
                                                                                                                  size: media.width * sixteen,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                          MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                                        ],
                                                                                                      ),
                                                                                                    ))
                                                                                                : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                                    ? InkWell(
                                                                                                        onTap: () {
                                                                                                          setState(() {
                                                                                                            phcode = i;
                                                                                                          });
                                                                                                          Navigator.pop(context);
                                                                                                        },
                                                                                                        child: Container(
                                                                                                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                                          color: page,
                                                                                                          child: Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                            children: [
                                                                                                              Row(
                                                                                                                children: [
                                                                                                                  Image.network(countries[i]['flag']),
                                                                                                                  SizedBox(
                                                                                                                    width: media.width * 0.02,
                                                                                                                  ),
                                                                                                                  SizedBox(
                                                                                                                    width: media.width * 0.4,
                                                                                                                    child: MyText(text: countries[i]['name'], size: media.width * sixteen),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                              MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                                            ],
                                                                                                          ),
                                                                                                        ))
                                                                                                    : Container(),
                                                                                          ));
                                                                                    })
                                                                                    .values
                                                                                    .toList(),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: media
                                                                          .width *
                                                                      0.025),
                                                          child: Row(
                                                            children: [
                                                              (phcode != null)
                                                                  ? Image
                                                                      .network(
                                                                      countries[
                                                                              phcode]
                                                                          [
                                                                          'flag'],
                                                                      width: media
                                                                              .width *
                                                                          0.06,
                                                                    )
                                                                  : Container(),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.015,
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                size: media
                                                                        .width *
                                                                    0.05,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      Expanded(
                                                        child: TextField(
                                                          controller: _mobile,
                                                          decoration: InputDecoration(
                                                              hintText: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_mobile'],
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          enabled:
                                                              (otpSent == true)
                                                                  ? false
                                                                  : true,
                                                        ),
                                                      ),

                                                      if (otpSent == true)
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _error = '';
                                                                otpSent = false;
                                                                mobileVerified =
                                                                    false;
                                                                _otp.clear();
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.edit,
                                                              size:
                                                                  media.width *
                                                                      0.05,
                                                            ))
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            crossFadeState: (signIn == 0)
                                                ? CrossFadeState.showFirst
                                                : CrossFadeState.showSecond,
                                            duration: const Duration(
                                                milliseconds: 200)),
                                        AnimatedCrossFade(
                                            firstChild: Container(),
                                            secondChild: Column(
                                              children: [
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Container(
                                                  height: media.width * 0.12,
                                                  width: media.width * 0.8,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.white),
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          media.width * 0.025,
                                                      left:
                                                          media.width * 0.025),
                                                  child: TextField(
                                                    controller: _otp,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                        hintText: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_enter_otp_login'],
                                                        border:
                                                            InputBorder.none),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            crossFadeState: (signIn == 1 &&
                                                    otpSent == true &&
                                                    mobileVerified == false)
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                            duration: const Duration(
                                                milliseconds: 200)),

                                        if (signIn == 0 &&
                                            forgotPassword == false)
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: media.width * 0.01,
                                              ),

                                            ],
                                          ),
                                        AnimatedCrossFade(
                                            firstChild: Container(),
                                            secondChild: Column(
                                              children: [
                                                SizedBox(
                                                  width: media.width * 0.8,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.05,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            languages[
                                                                    choosenLanguage]
                                                                ['text_gender'],
                                                            // 'Gender',
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.025,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                gender = 'male';
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        width:
                                                                            1.2,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  // decoration: BoxDecoration(
                                                                  //     border: Border.all(
                                                                  //         color: Colors
                                                                  //             .black,
                                                                  //         width:
                                                                  //             1.2)),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: (gender ==
                                                                          'male')
                                                                      ? Container(
                                                                          height:
                                                                              media.width * 0.03,
                                                                          width:
                                                                              media.width * 0.03,
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.white),
                                                                        )
                                                                      // ? Center(
                                                                      //     child:
                                                                      //         Icon(
                                                                      //     Icons
                                                                      //         .done,
                                                                      //     size: media.width *
                                                                      //         0.04,
                                                                      //   ))
                                                                      : Container(),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.015,
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.15,
                                                                  child: Text(
                                                                    languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_male'],
                                                                    // 'Male',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                fourteen,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                gender =
                                                                    'female';
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        width:
                                                                            1.2,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  // decoration: BoxDecoration(
                                                                  //     border: Border.all(
                                                                  //         color: Colors
                                                                  //             .black,
                                                                  //         width:
                                                                  //             1.2)),
                                                                  child: (gender ==
                                                                          'female')
                                                                      ? Container(
                                                                          height:
                                                                              media.width * 0.03,
                                                                          width:
                                                                              media.width * 0.03,
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.white),
                                                                        )
                                                                      // ? Center(
                                                                      //     child:
                                                                      //         Icon(
                                                                      //     Icons
                                                                      //         .done,
                                                                      //     size: media.width *
                                                                      //         0.04,
                                                                      //   ))
                                                                      : Container(),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.015,
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.15,
                                                                  child: Text(
                                                                    languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_female'],
                                                                    // 'Female',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                fourteen,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                gender =
                                                                    'others';
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        width:
                                                                            1.2,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  // decoration: BoxDecoration(
                                                                  //     border: Border.all(
                                                                  //         color: Colors
                                                                  //             .black,
                                                                  //         width:
                                                                  //             1.2)),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: (gender ==
                                                                          'others')
                                                                      ? Container(
                                                                          height:
                                                                              media.width * 0.03,
                                                                          width:
                                                                              media.width * 0.03,
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.white),
                                                                        )
                                                                      // ? Center(
                                                                      //     child:
                                                                      //         Icon(
                                                                      //     Icons
                                                                      //         .done,
                                                                      //     size: media.width *
                                                                      //         0.04,
                                                                      //   ))
                                                                      : Container(),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.015,
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.25,
                                                                  child: Text(
                                                                    languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_others'],
                                                                    // 'Neutral/Unknown',
                                                                    // 'text_other_gender',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                fourteen,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            crossFadeState: (signIn == 0)
                                                ? CrossFadeState.showFirst
                                                : CrossFadeState.showSecond,
                                            duration: const Duration(
                                                milliseconds: 200)),
                                        SizedBox(
                                          height: media.width * 0.025,
                                        ),
                                        if (_error != '')
                                          Column(
                                            children: [
                                              Container(
                                                  width: media.width * 0.5,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: Colors.white),
                                                  child: MyText(
                                                    text: _error,
                                                    size: 15,
                                                    color: Colors.red,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    fontweight: FontWeight.w500,
                                                  )),
                                              SizedBox(
                                                height: media.width * 0.025,
                                              ),
                                            ],
                                          ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: SvgPicture.asset(
                                                  'assets/images/whatsapp.svg',
                                                  width: 24),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: const Text(
                                                'Recibirás un código de confirmación en tu Whatsapp',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Button(
                                          width: media.width * 0.5,
                                          textcolor: Colors.white,
                                          onTap: () async {
                                            // FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            ProgressDialog pd = ProgressDialog(
                                                context: context);
                                            if (_email.text != '') {
                                           

                                              bool resp = await loginWithWhatsapp(_email.text);
                                              if (resp == true) {
                                                  pd.show(
                                                  max: 100,
                                                  msg: 'Enviando...',
                                                  progressBgColor: Colors.grey,
                                                  progressValueColor: theme);
                                                var res = await sendCodeWhatsApp(
                                                        number: _email.text,
                                                        code: '+591');
                                                pd.close();
                                                if (res != null) {
                                                  if (res.codigo == 0) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content:
                                                            Text(res.message),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                }
                                                code = res;
                                                  _pageController.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeInOut);
                                              } else {
                                                showDialog(context: context, builder: (context){
                                                  return AlertDialog(
                                                    content: Text(errorMessageValidateMobile ?? ''),
                                                  );
                                                });
                                              }

                                            
                                            } else {
                                              
                                            }
                                         
                                          },
                                          text: 'Enviar Codigo',
                                        ),
                                        if (otpSent == true && newPassword == false)
                                          Container(
                                            alignment: Alignment.center,
                                            width: media.width * 0.5,
                                            height: media.width * 0.1,
                                            child: (_resend == true)
                                                ? TextButton(
                                                    onPressed: () async {
                                                      var exist = true;
                                                      if (forgotPassword ==
                                                          true) {
                                                        var ver =
                                                            await verifyUser(
                                                                _email.text,
                                                                (isLoginemail ==
                                                                        true)
                                                                    ? 1
                                                                    : 0,
                                                                _password.text,
                                                                '',
                                                                withOtp,
                                                                forgotPassword);
                                                        if (ver == true) {
                                                          exist = true;
                                                        } else {
                                                          exist = false;
                                                        }
                                                      }
                                                      if (exist == true) {
                                                        if (isLoginemail ==
                                                            false) {
                                                          String pattern =
                                                              r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                          RegExp regExp =
                                                              RegExp(pattern);
                                                          if (regExp.hasMatch(
                                                                  _email
                                                                      .text) &&
                                                              _email.text
                                                                      .length <=
                                                                  countries[
                                                                          phcode]
                                                                      [
                                                                      'dial_max_length'] &&
                                                              _email.text
                                                                      .length >=
                                                                  countries[
                                                                          phcode]
                                                                      [
                                                                      'dial_min_length']) {
                                                            // setState(() {
                                                            //   _error = '';
                                                            //   loginLoading = true;
                                                            // });
                                                            var val =
                                                                await otpCall();

                                                            if (val.value ==
                                                                true) {
                                                              if (isCheckFireBaseOTP ==
                                                                  true) {
                                                                await phoneAuth(
                                                                    countries[phcode]
                                                                            [
                                                                            'dial_code'] +
                                                                        _email
                                                                            .text);
                                                                phoneAuthCheck =
                                                                    true;
                                                                _resend = false;
                                                                otpSent = true;
                                                                resendTimer =
                                                                    60;
                                                                resend();
                                                              } else {
                                                                var val = await sendOTPtoMobile(
                                                                    _email.text,
                                                                    countries[phcode]
                                                                            [
                                                                            'dial_code']
                                                                        .toString());
                                                                if (val ==
                                                                    'success') {
                                                                  phoneAuthCheck =
                                                                      true;
                                                                  _resend =
                                                                      false;
                                                                  otpSent =
                                                                      true;
                                                                  resendTimer =
                                                                      60;
                                                                  resend();
                                                                } else {
                                                                  _error = val;
                                                                }
                                                              }
                                                            } else {
                                                              phoneAuthCheck =
                                                                  false;
                                                              RemoteNotification
                                                                  noti =
                                                                  const RemoteNotification(
                                                                      title:
                                                                          'Otp for Login',
                                                                      body:
                                                                          'Login to your account with test OTP 123456');
                                                              showOtpNotification(
                                                                  noti);
                                                            }
                                                            // setState(() {
                                                            _resend = false;
                                                            otpSent = true;
                                                            resendTimer = 60;
                                                            resend();

                                                            // });
                                                          } else {
                                                            //  setState(() {
                                                            _error =
                                                                'Please enter valid mobile number';
                                                            // });
                                                          }
                                                        } else {
                                                          String pattern =
                                                              r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                                          RegExp regex =
                                                              RegExp(pattern);
                                                          if (regex.hasMatch(
                                                              _email.text)) {
                                                            phoneAuthCheck =
                                                                true;
                                                            var val =
                                                                await sendOTPtoEmail(
                                                                    _email
                                                                        .text);
                                                            if (val ==
                                                                'success') {
                                                              _resend = false;
                                                              otpSent = true;
                                                              resendTimer = 60;
                                                              resend();
                                                            } else {
                                                              _error = val;
                                                            }
                                                            // setState(() {
                                                            // _error = '';
                                                            // });
                                                          } else {
                                                            // setState(() {
                                                            _error =
                                                                'Please enter valid email address';
                                                            // });
                                                          }
                                                        }
                                                      } else {
                                                        _error = (isLoginemail ==
                                                                false)
                                                            ? 'Mobile Number doesn\'t exists'
                                                            : 'Email doesn\'t exists';
                                                      }
                                                    },
                                                    child: MyText(
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_resend_otp'],
                                                      size: media.width *
                                                          fourteen,
                                                      textAlign:
                                                          TextAlign.center,
                                                      color: Colors.white,
                                                    ))
                                                : (otpSent == true)
                                                    ? MyText(
                                                        text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_resend_otp_in']
                                                            .toString()
                                                            .replaceAll('1111',
                                                                '$resendTimer'),
                                                        size: media.width *
                                                            fourteen,
                                                        textAlign:
                                                            TextAlign.center,
                                                        color: Colors.white,
                                                      )
                                                    : Container(),
                                          ),
                                        SizedBox(
                                          height: media.width * 0.025,
                                        ),
                                      ],
                                    ),
                                  ),
                                  verifyCode()
                                ],
                              ),
                            )
                          ],
                        )),
                    (pickImage == true)
                        ? Positioned(
                            bottom: 0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  pickImage = false;
                                });
                              },
                              child: Container(
                                height: media.height * 1,
                                width: media.width * 1,
                                color: Colors.transparent.withOpacity(0.6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 1,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(25),
                                              topRight: Radius.circular(25)),
                                          border: Border.all(
                                            color: borderLines,
                                            width: 1.2,
                                          ),
                                          color: page),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: media.width * 0.02,
                                            width: media.width * 0.15,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.01),
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      pickImageFromCamera();
                                                    },
                                                    child: Container(
                                                        height:
                                                            media.width * 0.171,
                                                        width:
                                                            media.width * 0.171,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    borderLines,
                                                                width: 1.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          size: media.width *
                                                              0.064,
                                                          color: textColor,
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.02,
                                                  ),
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_camera'],
                                                    size: media.width * ten,
                                                    color: textColor
                                                        .withOpacity(0.4),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      pickImageFromGallery();
                                                    },
                                                    child: Container(
                                                        height:
                                                            media.width * 0.171,
                                                        width:
                                                            media.width * 0.171,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    borderLines,
                                                                width: 1.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Icon(
                                                          Icons.image_outlined,
                                                          size: media.width *
                                                              0.064,
                                                          color: textColor,
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.02,
                                                  ),
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_gallery'],
                                                    size: media.width * ten,
                                                    color: textColor
                                                        .withOpacity(0.4),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        : Container(),
                    Positioned(
                        top: MediaQuery.of(context).padding.top +
                            media.width * 0.05,
                        left: (languageDirection == 'ltr')
                            ? media.width * 0.05
                            : null,
                        right: (languageDirection == 'rtl')
                            ? media.width * 0.05
                            : null,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: (ownermodule == '1')
                              ? Container(
                                  height: media.width * 0.1,
                                  width: media.width * 0.1,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: backgroundColor),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: media.width * 0.05,
                                  ),
                                )
                              : Container(),
                        )),
                    (loginLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                );
              })),
    );
  }

  verifyCode() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: const Text(
              "Confirma el código enviado a tu Whatsapp",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            autofocus: true,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLength: 4,
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: inputDecoration(),
            onChanged: (value) {
              // print(value);
              // print(_email.tex/sz`t);
            },
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () async {
              ProgressDialog pd = ProgressDialog(context: context);

            if (_otpController.text == code!.codigo.toString()) {
               pd.show(
                    max: 100,
                    msg: 'Ingresando...',
                    progressBgColor: Colors.grey,
                    progressValueColor: theme);
                await verifyUser(
                    _email.text,
                    0,
                    '12345'
                        '',
                    '',
                    false,
                    false);
                pd.close();
                navigate(true);
            } else {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text('Error de verificacion'),
                      content: Text('El codigo es incorrecto'),
                    );
                  });
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            }
          },
          child: Text(
            'Verificar',
            style: TextStyle(color: theme, fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: TextButton(
                child: const Text(
                  'Cambiar número',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor:
                        Colors.white, // Cambia el color del subrayado
                    decorationThickness: 2.0,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                child: const Text(
                  'Reenviar código',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor:
                        Colors.white, // Cambia el color del subrayado
                    decorationThickness: 2.0,
                  ),
                ),
                onPressed: () async {
                  ProgressDialog pd = ProgressDialog(context: context);
                  if (_email.text != '') {
                    pd.show(
                        max: 100,
                        msg: 'Enviando...',
                        progressBgColor: Colors.grey,
                        progressValueColor: theme);
                    var res = await sendCodeWhatsApp(
                        number: _email.text, code: '+591');
                    pd.close();
                    if (res != null) {
                      if (res.codigo == 0) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(res.message)));
                        return;
                      }
                    }
                    // setState(() {
                    code = res;
                    // });
                    // wiud_pageController.nextPage(
                    //     duration: Duration(
                    //         milliseconds: 500),
                    //     curve: Curves.easeInOut);
                  } else {
                    // mostrar un error de que tiene que escribir un numero de telefono
                  }
                  //TODO: ENVIAR OTP: Este tiene que ser el boton de envair OTP
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const outlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.white),
);
InputDecoration inputDecoration(
    {String hintText = "_ _ _ _", double fontSize = 35}) {
  return InputDecoration(
    counter: const SizedBox(),
    contentPadding: const EdgeInsets.only(top: 5, bottom: 5),
    hintText: hintText,
    errorBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
    disabledBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    border: outlineInputBorder,
    errorStyle: const TextStyle(color: Colors.white),
    // hintStyle: TextStyle(color: textColorwhite),
    hintStyle: TextStyle(color: Colors.white, fontSize: fontSize),
    fillColor: Colors.white.withOpacity(0.3),
    filled: true,
  );
}

// class VerifyCodeWidget extends StatefulWidget {
//   final TextEditingController verifyCodeController;
//   final PageController pageController;
//   final TextEditingController phoneController;
//   CodeWhatsApp code;
//    VerifyCodeWidget(
//       {super.key,
//       required this.verifyCodeController,
//       required this.code,
//       required this.pageController, required this.phoneController});

//   @override
//   State<VerifyCodeWidget> createState() => _VerifyCodeWidgetState();
// }

// class _VerifyCodeWidgetState extends State<VerifyCodeWidget> {
//     navigate(verify) {
//     if (verify == true) {
//       if (userDetails['uploaded_document'] == true &&
//           userDetails['approve'] == true) {
//         if (userDetails['role'] != 'owner' &&
//             userDetails['enable_bidding'] == true) {
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const RidePage()),
//               (route) => false);
//         } else if (userDetails['role'] != 'owner' &&
//             userDetails['enable_bidding'] == false) {
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const Maps()),
//               (route) => false);
//         } else {
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => const Maps()),
//               (route) => false);
//         }
//       }
//     } else if (verify == false) {
//       // setState(() {
//       //   _error =
//       //       'User Doesn\'t exists with this number, please Signup to continue';
//       // });
//     } else {
//       // setState(() {
//       //   _error = verify.toString();
//       // });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {

//   }
// }

class ShapePainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.9,
        size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.8, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ShapePainterBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.95, size.height * 0.25,
        size.width * 0.8, size.height * 0.25);
    path.lineTo(size.width * 0.2, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.25, 0, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
