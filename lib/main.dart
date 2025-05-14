// import 'dart:developer';
import 'package:abril_driver_app/firebase_options.dart';
import 'package:abril_driver_app/providers/handle_drop.dart';
import 'package:abril_driver_app/providers/speech_provider.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
import 'package:abril_driver_app/utils/notifications.dart';
import 'package:abril_driver_app/utils/temporizador_provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'functions/functions.dart';
import 'functions/notifications.dart';
import 'pages/loadingPage/loadingpage.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:bubble_head/bubble.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (message.notification!.title!.contains('Nuevo') || message.notification!.title!.contains('Nuevo mensaje de')) {
//     DeviceApps.openApp('com.deabrilconductoresdriver.driver'); 
//   }
// }

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       await Firebase.initializeApp();
//       var val = await Geolocator.getCurrentPosition();
//       var id;
//       if (inputData != null) {
//         id = inputData['id'];
//       }
//       FirebaseDatabase.instance.ref().child('drivers/driver_$id').update({
//         'lat-lng': val.latitude.toString(),
//         'l': {
//           '0': val.latitude, 
//           '1': val.longitude,
//         },
//         'updated_at': ServerValue.timestamp
//       });
//       // ignore: empty_catches
//     } catch (e) {}

//     return Future.value(true);
//   });
// }


void requestBatteryOptimizations() async {
  final service = FlutterBackgroundService();
  service.invoke("requestBatteryOptimizations");
}





Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
    try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
  
  requestBatteryOptimizations();
  

  await  Permission.notification.isDenied.then((value){
    if (value) {
      Permission.notification.request();
    }
  });
  // await initializeNotifications();/
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initMessaging();
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  checkInternetConnection();

  currentPositionUpdate();

  // Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // TODO: FM #Reset counter AwesomeNotifications
  // await AwesomeNotifications().resetGlobalBadge();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context)=>ThemeProvider(),),
      ChangeNotifierProvider(create: (context)=> TemporizadorProvider()),
      ChangeNotifierProvider(create: (_)=> DropProvider()),
       ChangeNotifierProvider(create: (_) => SpeechProvider()),
      // ChangeNotifierProvider(create: (_) => NotiProvider()),
    ],
    child: const MyApp(),)

  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // setDriverOnlineStatus(true);
    // Workmanager().cancelAll();
    super.initState();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if (state == AppLifecycleState.detached) {
    // setDriverOnlineStatus(false); // Marcar app como cerrada
  } else if (state == AppLifecycleState.resumed) {
    // setDriverOnlineStatus(true); // Marcar app como abierta
  }
}


  @override
  Widget build(BuildContext context) {
    platform = Theme.of(context).platform;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
      
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: MaterialApp(
             navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Radiomóvil 15 de abril Tarija Driver',
            theme: themeProvider.currentTheme,
            home: const LoadingPage(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          ));
      },
    );
  }
}

// void updateLocation(duration) {
//   for (var i = 0; i < 15; i++) {
//     Workmanager().registerPeriodicTask('locs_$i', 'update_locs_$i',
//         initialDelay: Duration(minutes: i),
//         frequency: const Duration(minutes: 15),
//         constraints: Constraints(
//             networkType: NetworkType.connected,
//             requiresBatteryNotLow: false,
//             requiresCharging: false,
//             requiresDeviceIdle: false,
//             requiresStorageNotLow: false),
//         inputData: {'id': userDetails['id'].toString()});
//   }
// }
