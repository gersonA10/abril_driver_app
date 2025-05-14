// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:ui';
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:abril_driver_app/widgets/widget_image.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:dash_bubble/dash_bubble.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:abril_driver_app/functions/audio_servce.dart';
import 'package:abril_driver_app/functions/rides_services/fetch_data_client_ride.dart';
import 'package:abril_driver_app/main.dart';
import 'package:abril_driver_app/models/request_meta.dart';
import 'package:abril_driver_app/pages/chatPage/chat_page.dart';
import 'package:abril_driver_app/pages/login/landingpage.dart';
import 'package:abril_driver_app/pages/login/login.dart';
import 'package:abril_driver_app/pages/onTripPage/droplocation.dart';
import 'package:abril_driver_app/providers/handle_drop.dart';
import 'package:abril_driver_app/providers/theme_provider.dart';
// import 'package:abril_driver_app/utils/back_services.dart';
// import 'package:abril_driver_app/utils/location_manager.dart';
import 'package:abril_driver_app/utils/notifications.dart';
import 'package:abril_driver_app/widgets/center_position_destino.dart';
import 'package:abril_driver_app/widgets/custom_toast.dart';
import 'package:abril_driver_app/widgets/notificar_cliente.dart';
import 'package:abril_driver_app/widgets/open_map.dart';
import 'package:abril_driver_app/widgets/pick_up_open_map.dart';
import 'package:abril_driver_app/widgets/sheetCard/bottom_card_sheet.dart';
import 'package:abril_driver_app/widgets/online_offline_widget.dart';
import 'package:abril_driver_app/widgets/sheetCardDriverAceept/bottom_card_sheet_driver_accept.dart';
import 'package:abril_driver_app/widgets/show_rides.dart';
import 'package:abril_driver_app/widgets/toggle_theme.dart';
import 'package:abril_driver_app/widgets/viajes_disponibles.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../functions/functions.dart';
import '../../functions/geohash.dart';
import '../../functions/notifications.dart';
import '../../styles/styles.dart';

import '../../translation/translation.dart';
import '../../utils/back_services.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/notification.dart';
import '../loadingPage/loading.dart';
import '../navDrawer/nav_drawer.dart';
import '../noInternet/nointernet.dart';
import '../vehicleInformations/docs_onprocess.dart';
import 'digitalsignature.dart';
import 'invoice.dart';
import 'rides.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart' as fmlt;
import 'package:http/http.dart' as http;

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

bool showLocationRide = false;

dynamic _center = const LatLng(41.4219057, -102.0840772);
LatLng? centerPosition;
fmlt.LatLng? newPosition;
fmlt.LatLng? previousPosition;

fmlt.LatLng? startPoint;
fmlt.LatLng? endPoint;
List<fmlt.LatLng> routePoints = [];

bool locationAllowed = false;

List<Marker> myMarkers = [];
Set<Circle> circles = {};
bool polylineGot = false;
bool mostrarRutaDobleTap = false;
String? requestIdDoubleTapUser;

dynamic _timer;
String cancelReasonText = '';
bool notifyCompleted = false;
bool logout = false;
bool deleteAccount = false;
bool getStartOtp = false;
dynamic shipLoadImage;
dynamic shipUnloadImage;
bool unloadImage = false;
String driverOtp = '';
bool serviceEnabled = false;
bool show = true;

int filtericon = 0;
dynamic isAvailable;
List vechiletypeslist = [];
List<fmlt.LatLng> fmpoly = [];

// class _MapsState extends State<Maps>with WidgetsBindingObserver, SingleTickerProviderStateMixin {
class _MapsState extends State<Maps>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Map<String, dynamic>? datosDeuda;
  fmlt.LatLng? pickupLocation;
  List driverData = [];

  bool sosLoaded = false;
  bool cancelRequest = false;
  bool _pickAnimateDone = false;
  dynamic addressBottom;
  dynamic _addressBottom;
  late geolocator.LocationPermission permission;
  Location location = Location();
  String state = '';
  dynamic _controller;

  //
  final fm.MapController _fmController = fm.MapController();
  // late fm.MapController _fmController;

  fmlt.LatLng? _targetPositionNew;
  Timer? _timerNew;
  bool? _isTrackingNew;

  //
  Animation<double>? _animation;
  dynamic animationController;
  String _cancellingError = '';
  double mapPadding = 0.0;
  var iconDropKeys = {};
  String _cancelReason = '';
  bool _locationDenied = false;
  int gettingPerm = 0;
  bool _errorOtp = false;
  String beforeImageUploadError = '';
  String afterImageUploadError = '';
  dynamic loc;
  String _otp1 = '';
  String _otp2 = '';
  String _otp3 = '';
  String _otp4 = '';
  bool showSos = false;
  bool _showWaitingInfo = false;
  bool _isLoading = false;
  bool _reqCancelled = false;
  bool navigated = false;
  dynamic pinLocationIcon;
  dynamic pinLocationIcon2;
  dynamic pinLocationIcon3;
  dynamic userLocationIcon;
  bool makeOnline = false;
  bool contactus = false;
  GlobalKey iconKey = GlobalKey();
  GlobalKey iconDropKey = GlobalKey();
  List gesture = [];
  dynamic start;
  dynamic onrideicon;
  dynamic onridedeliveryicon;
  dynamic offlineicon;
  dynamic offlinedeliveryicon;
  dynamic onlineicon;
  dynamic onlinedeliveryicon;
  dynamic onridebikeicon;
  dynamic offlinebikeicon;
  dynamic onlinebikeicon;
  bool navigationtype = false;
  bool currentpage = true;
  bool _tripOpenMap = false;
  bool _isDarkTheme = false;

  final _mapMarkerSC = StreamController<List<Marker>>();
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;
  TextEditingController bidText = TextEditingController();

  //REQUEST META FIREBASE
  bool showRequestsOverlay = false;
  List<RequestMeta> requestMetas = [];
  List<String> allRequestID = [];
  List<String> rejectedRides = [];

  bool mostrarAlertaConfirmacion = false;
  StreamSubscription<String?>? confirmacionSubscription;
  bool alertaYaMostrada = false;

  double? showRidesLatRecoger;
  double? showRidesLonRecoger;

  String? nombreUsuario;

  AudioService audioService = AudioService();
  RequestMetaService requestMetaService =
      RequestMetaService(userDetails['id'].toString());
  RequestService requestService = RequestService();
  //BootomSheet
  final ValueNotifier<double> bottomSheetOffset = ValueNotifier(0.2);
  final ValueNotifier<double> acceptDriverBottomSheetOffset =
      ValueNotifier(0.28);

  final Location _location = Location();

  bool _isCameraFollowing = true;

  StreamSubscription<LocationData>? _locationSubscription;

  Future<void> _initializeLocation() async {
    try {
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          debugPrint("❌ Permiso de ubicación denegado");
          return;
        }
      }

      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint("❌ El servicio de ubicación está desactivado");
          return;
        }
      }

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 500,
        distanceFilter: 0,
      );

      final initialLocation = await _location.getLocation();
      setState(() {
        currentPositionNew = fmlt.LatLng(
          initialLocation.latitude!,
          initialLocation.longitude!,
        );
      });

      // 🔻 Guarda la suscripción
      _locationSubscription =
          _location.onLocationChanged.listen((LocationData newLocation) {
        if (userDetails['active'] == false) return;

        final newLatLng =
            fmlt.LatLng(newLocation.latitude!, newLocation.longitude!);
        currentPositionNew = newLatLng;

        if (_isCameraFollowing) {
          _fmController.move(newLatLng, _fmController.camera.zoom);
        }
      });
    } catch (e, stacktrace) {
      debugPrint("🔥 Error en _initializeLocation: $e");
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> detenerUbicacion() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint("🛑 GPS desactivado (stream cancelado)");
  }

// Método que se ejecuta cuando el usuario empieza a mover la cámara
  void _onCameraMoveStarted() {
    setState(() {
      _isCameraFollowing = false; // Detener el seguimiento automático
    });
  }

// Método que se ejecuta al presionar el botón de "mi ubicación"
  void _onFollowLocationPressed() {
    setState(() {
      _isCameraFollowing = true; // Reactivar el seguimiento
    });

    // Mover la cámara a la ubicación actual
    if (currentPositionNew != null) {
      // TODO: FM GPS Controller
      _fmController.move(currentPositionNew!, _fmController.camera.zoom);
    }
  }

  fmlt.LatLng? posicionActual;
  bool audioPlayed = false;

  Future<void> cargarPuntosRuta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Obtener la cadena JSON desde SharedPreferences
    String? puntosJson = prefs.getString('puntosRuta');

    if (puntosJson != null) {
      // Decodificar la cadena JSON a una lista de mapas
      List<dynamic> listaPuntos = jsonDecode(puntosJson);

      // Convertir la lista de mapas a una lista de objetos LatLng
      List<fmlt.LatLng> puntos = listaPuntos
          .map((punto) => fmlt.LatLng(punto['latitude'], punto['longitude']))
          .toList();

      // Asignar los puntos cargados a `routePoints`
      setState(() {
        routePoints = puntos;
      });
    }
  }

  Future<void> cargarLatLonDestino() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Obtener la cadena JSON desde SharedPreferences
    double? lonDestino = prefs.getDouble('longitudeDestino');
    double? latDestino = prefs.getDouble('latitudeDestino');

    if (lonDestino != null && latDestino != null) {
      // Asignar los puntos cargados a `routePoints`
      setState(() {
        latitudeDestino = latDestino;
        longitudeDestino = lonDestino;
      });
    }
  }

  void cargarEndPoint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble('endPointLat');
    double? lng = prefs.getDouble('endPointLng');

    if (lat != null && lng != null) {
      setState(() {
        endPoint = fmlt.LatLng(lat, lng);
      });
    }
  }

  obtenerPosicionActual() async {
    geolocator.Position position =
        await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation,
    );
    setState(() {
      currentPositionNew = fmlt.LatLng(position.latitude, position.longitude);
    });
    print('Posicion actua; $position');
  }

  final DatabaseReference _ref = FirebaseDatabase.instance.ref('drivers');
  bool? isAvailable; // Valor inicial (ajústalo según necesites)
  void _listenDriverAvailability(String driverId) {
    _ref.child('driver_$driverId/is_available').onValue.listen((event) {
      if (event.snapshot.value != null) {
        bool newValue = event.snapshot.value as bool;
        if (newValue != isAvailable) {
          setState(() {
            isAvailable = newValue;
          });
        }
      }
    });
  }

  Future<void> requestOverlayPermission() async {
    // Verifica si el permiso ya ha sido concedido
    if (await perm.Permission.systemAlertWindow.isGranted) {
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
      bool granted = await perm.Permission.systemAlertWindow.isGranted;
      if (granted) {
        print('✅ Permiso de superposición concedido después del intento.');
      } else {
        print('❌ El usuario no concedió el permiso de superposición.');
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de superposición: $e');
    }
  }

  Future<void> requestPermissions() async {
    var statuses = await [
      perm.Permission.location,
      perm.Permission.locationAlways,
      perm.Permission.notification,
    ].request();

    if (statuses[perm.Permission.location]!.isDenied ||
        statuses[perm.Permission.locationAlways]!.isDenied) {
      log('🚨 Permiso de ubicación denegado');
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    WidgetsBinding.instance.addObserver(this);
    requestOverlayPermission();
    // _fmController = fm.MapController();
    _initializeLocation();
    WidgetsFlutterBinding.ensureInitialized();
    // initializeNotifications();
    super.initState();
    cargarPuntosRuta();
    initializeService(userDetails['id'].toString());
    _listenDriverAvailability(userDetails['id'].toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final drop = Provider.of<DropProvider>(context, listen: false);
      drop.cargarPuntosRutaDestino();
    });
    cargarLatLonDestino();
    cargarEndPoint();
    obtenerPosicionActual();
    // obtenerPosicionEnTiempoReal();
    // Resto de inicializaciones
    // DashBubble.instance.stopBubble();
    myMarkers = [];
    show = true;
    navigated = false;
    filtericon = 0;
    polylineGot = false;
    currentpage = true;
    _isDarkTheme = isDarkTheme;
    // getadminCurrentMessages();
    getLocs();
    getonlineoffline();
    listenToRequestMeta();
    getData();
    log('App InitState');
  }

  Future<void> verificarDeudas() async {
    try {
      final resultado = await obtenerDeuda(userDetails['id'].toString());
      setState(() {
        datosDeuda = resultado;
      });

      if (resultado["deudas_coleccion"] != null &&
          resultado["deudas_coleccion"].isNotEmpty) {
        // mostrarAlerta(resultado["mensaje_bloqueo"]);
        showAlertSuccess(
          context,
          'Radio movil 15 de Abril',
          resultado["mensaje_bloqueo"],
          true,
        );
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // if (prefs.getDouble('longDestino') != null) {
      // longitudeDestino = prefs.getDouble('longDestino');
      // } else {
      // longitudeDestino = 0.0;
      // }
      // if (prefs.getDouble('latDestino') != null) {
      // latitudeDestino = prefs.getDouble('latDestino');
      // } else {
      // latitudeDestino = 0.0;
      // }
      if (prefs.getDouble('latRecoger') != null) {
        latRecoger = prefs.getDouble('latRecoger');
      } else {
        latRecoger = 0.0;
      }
      if (prefs.getDouble('lonRecoger') != null) {
        lonRecoger = prefs.getDouble('lonRecoger');
      } else {
        lonRecoger = 0.0;
      }
    });
  }

  void listenToRequestMeta() {
    int driverId = userDetails['id'];
    requestMetaService.getRequestMetaStream().listen((newRequestMetas) {
      setState(() {
        requestMetas = newRequestMetas.where((meta) {
          return meta.metaDrivers.containsKey(driverId) &&
              !rejectedRides.contains(meta.requestId);
        }).toList();

        if (requestMetas.isNotEmpty) {
          showRequestsOverlay = true;
        } else {
          showRequestsOverlay = false;
        }
      });
      for (var meta in requestMetas) {
        String requestId = meta.requestId;

        listenToRequests(requestId);
        listenMessages(requestId);
        listenClienteConfirmado(requestId);
        listenCancellRides(requestId);
      }
    });
  }

  void listenClienteConfirmado(String requestId) {
    confirmacionSubscription =
        requestService.getConfirmacion(requestId).listen((confirmacion) async {
      // Obtener la carrera aceptada por el conductor
      // var driverReq = await requestService.getDriverRequest(driverId);

      // Verificar si el driver ha aceptado la carrera (accepted_at no es nulo)
      if (driverReq['accepted_at'] != null) {
        // Verificar si cliente_confirmado es 'true' y la alerta no ha sido mostrada aún
        if (confirmacion == 'true' && !alertaYaMostrada) {
          setState(() {
            mostrarAlertaConfirmacion = true;
            alertaYaMostrada = true;
          });
        }
      }
    });
  }

  void listenMessages(String requestId) {
    log('ID PETICION: $requestId');
    final driverID = userDetails['id'];
    int previousMessageCount = 0;

    // Escuchar los mensajes solo si el driver es el asignado
    requestService
        .getMessageCountStream(requestId, driverID.toString())
        .listen((messageCount) {
      if (previousMessageCount == 0 && messageCount == null) {
        previousMessageCount = messageCount!;
      } else {
        if (messageCount != null && messageCount > previousMessageCount) {
          _navigateToChat();
        }
        previousMessageCount = messageCount!;
      }
    });
  }

  void _navigateToChat() {
    if (isInChatPage == false) {
      isInChatPage = true;
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => const ChatPage()));
    }
  }

  void listenCancellRides(String requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dropProvider = Provider.of<DropProvider>(context, listen: false);
    final driverID = userDetails['id']; // Obtén el ID del conductor actual
    audioPlayed = false;

    requestService.getDriverIdStream(requestId).listen((assignedDriverId) {
      // Solo escuchar si el conductor actual es el asignado
      if (assignedDriverId == driverID.toString()) {
        requestService.getRequestStream(requestId).listen((request) {
          if (!audioPlayed &&
              (request.cancelledByUser == 'true' ||
                  request.cancelledByUser == '1')) {
            setState(() {
              prefs.remove('mostrardDibujadoDestino');
              prefs.remove('puntosRutaDestino');
              prefs.remove('longitudeDestino');
              prefs.remove('latitudeDestino');
              mostrarRutaDobleTap = false;
              dropProvider.mostrardDibujadoDestino = false;
              showLocationRide = false;
              isPressed = false;
            });
            playAudio(); // Reproducir audio solo para el conductor asignado
            audioPlayed = true;
          }
        });
      }
    });
  }

  void listenToRequests(String requestId) {
    requestService.getRequestStream(requestId).listen((request) {
      if (request.isCancelled == 1 ||
          request.cancelledByUser == 'true' ||
          request.cancelledByUser == '1') return;
      if (request.movilAceptado != null &&
          request.movilAceptado != '' &&
          request.movilAceptado != userDetails['car_number']) {
        if (driverReq['is_driver_started'] == 1) return;
        //Cuando el driver esta en un estado de viaje no se muestre el toast
        CustomToast.show(
            context, 'Llamada aceptada por el móvil ${request.movilAceptado}.');
      }
    });
  }

  void listenToRequestChanges(String requestId) async {
    final dropProvider = Provider.of<DropProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    requestService.getRequestStream(requestId).listen((request) {
      if (request.isCancelled == 1 ||
          request.cancelledByUser == "1" ||
          request.cancelledByUser == 'true') {
        // cliente_cancelo_viaje
        setState(() {
          prefs.remove('mostrardDibujadoDestino');
          prefs.remove('puntosRutaDestino');
          mostrarRutaDobleTap = false;
          dropProvider.mostrardDibujadoDestino = false;
          showLocationRide = false;
          isPressed = false;
        });
      }
    });
  }

  void playAudio() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audio/cliente_cancelo_viaje.mp3'));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _controller?.setMapStyle(mapStyle);
    });
    if ((choosenRide.isNotEmpty || driverReq.isNotEmpty) &&
        _pickAnimateDone == false) {
      _pickAnimateDone = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        _pickAnimateDone = true;
        addMarkers();
      });
    }
  }

  bool _showToast = false;

  //show toast for demo
  addToast() {
    setState(() {
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }

  getonlineoffline() async {
    if (userDetails['role'] == 'driver' &&
        userDetails['owner_id'] != null &&
        userDetails['vehicle_type_id'] == null &&
        userDetails['active'] == true) {
      var val = await driverStatus();
      if (val == 'logout') {
        navigateLogout();
      }
    }
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  switch (state) {
    case AppLifecycleState.resumed:
      if (_controller != null) {
        _controller!.setMapStyle(mapStyle);
        valueNotifierHome.incrementNotifier();
      }
      isBackground = false;
      FlutterBackgroundService().invoke('setAsBackground');
      log('App Resumed');

      await obtenerPosicionActual();
      break;

    case AppLifecycleState.paused:
      isBackground = true;
      log('App Paused');
      break;

    case AppLifecycleState.inactive:
      isBackground = true;
      log('App Inactive');
      break;

    case AppLifecycleState.detached:
      FlutterBackgroundService().invoke('setAsForeground');
      FlutterBackgroundService()
          .invoke('updateAppLifeState', {"AppLifeState": true});
      log('App Detached');
      break;

    case AppLifecycleState.hidden:
      FlutterBackgroundService()
          .invoke('updateAppLifeState', {"AppLifeState": false});
      log('App Hidden');
      break;
  }
}


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isInChatPage = false;
    confirmacionSubscription?.cancel();
    if (_timer != null) {
      _timer.cancel();
    }
    fmpoly.clear();
    myMarkers.clear();
    _controller?.dispose();
    _controller = null;
    animationController?.dispose();
    _timerNew?.cancel();
    super.dispose();
    log('App Disponse');
  }

  //navigate
  navigate() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const DigitalSignature()));
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

  reqCancel() {
    _reqCancelled = true;

    Future.delayed(const Duration(seconds: 2), () {
      _reqCancelled = false;
      userReject = false;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  capturePng(GlobalKey iconKeys) async {
    dynamic bitmap;

    try {
      RenderRepaintBoundary boundary =
          iconKeys.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      bitmap = BitmapDescriptor.fromBytes(pngBytes);
      // return pngBytes;
      return bitmap;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getPoly() async {
    fmpoly.clear();
    for (var i = 1; i < addressList.length; i++) {
      var api = await http.get(Uri.parse(
          'https://routing.openstreetmap.de/routed-car/route/v1/driving/${addressList[i - 1].latlng.longitude},${addressList[i - 1].latlng.latitude};${addressList[i].latlng.longitude},${addressList[i].latlng.latitude}?overview=false&geometries=polyline&steps=true'));
      if (api.statusCode == 200) {
        // ignore: no_leading_underscores_for_local_identifiers
        List _poly = jsonDecode(api.body)['routes'][0]['legs'][0]['steps'];
        polyline.clear();
        for (var e in _poly) {
          decodeEncodedPolyline(e['geometry']);
        }
        double lat = (addressList[0].latlng.latitude +
                addressList[addressList.length - 1].latlng.latitude) /
            2;
        double lon = (addressList[0].latlng.longitude +
                addressList[addressList.length - 1].latlng.longitude) /
            2;
        var val = LatLng(lat, lon);
        // TODO: FM - Cambiar a LatLng
        _fmController.move(fmlt.LatLng(val.latitude, val.longitude), 15);
        setState(() {});
      }
    }
  }

  addMarkers() {
    if (mapType == 'google') {
      Future.delayed(const Duration(milliseconds: 200), () {
        addPickDropMarker();
      });
    } else {
      fmpoly.clear();
      Future.delayed(const Duration(milliseconds: 200), () {
        getPoly();
      });
    }
  }

  addDropMarker() async {
    if (tripStops.isNotEmpty) {
      for (var i = 0; i < tripStops.length; i++) {
        var testIcon = await capturePng(iconDropKeys[i]);
        // ignore: unnecessary_null_comparison
        if (testIcon != null) {
          myMarkers.add(Marker(
              markerId: MarkerId((i + 3).toString()),
              icon: testIcon,
              position:
                  LatLng(tripStops[i]['latitude'], tripStops[i]['longitude'])));
        }
      }
      setState(() {});
    } else if (choosenRide.isNotEmpty) {
      var testIcon = await capturePng(iconDropKey);
      if (testIcon != null) {
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('3'),
              icon: testIcon,
              position: LatLng(
                  choosenRide[0]['drop_lat'], choosenRide[0]['drop_lng'])));
        });
      }
    } else {
      var testIcon = await capturePng(iconDropKey);
      if (testIcon != null) {
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('3'),
              icon: testIcon,
              position: LatLng(driverReq['drop_lat'], driverReq['drop_lng'])));
        });
      }
    }
    // setState((){});
    LatLngBounds bound;
    if (driverReq.isNotEmpty) {
      if (driverReq['pick_lat'] > driverReq['drop_lat'] &&
          driverReq['pick_lng'] > driverReq['drop_lng']) {
        bound = LatLngBounds(
            southwest: LatLng(driverReq['drop_lat'], driverReq['drop_lng']),
            northeast: LatLng(driverReq['pick_lat'], driverReq['pick_lng']));
      } else if (driverReq['pick_lng'] > driverReq['drop_lng']) {
        bound = LatLngBounds(
            southwest: LatLng(driverReq['pick_lat'], driverReq['drop_lng']),
            northeast: LatLng(driverReq['drop_lat'], driverReq['pick_lng']));
      } else if (driverReq['pick_lat'] > driverReq['drop_lat']) {
        bound = LatLngBounds(
            southwest: LatLng(driverReq['drop_lat'], driverReq['pick_lng']),
            northeast: LatLng(driverReq['pick_lat'], driverReq['drop_lng']));
      } else {
        bound = LatLngBounds(
            southwest: LatLng(driverReq['pick_lat'], driverReq['pick_lng']),
            northeast: LatLng(driverReq['drop_lat'], driverReq['drop_lng']));
      }
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 100);
      _controller?.animateCamera(cameraUpdate);
    } else {
      if (choosenRide[0]['pick_lat'] > choosenRide[0]['drop_lat'] &&
          choosenRide[0]['pick_lng'] > choosenRide[0]['drop_lng']) {
        bound = LatLngBounds(
            southwest:
                LatLng(choosenRide[0]['drop_lat'], choosenRide[0]['drop_lng']),
            northeast:
                LatLng(choosenRide[0]['pick_lat'], choosenRide[0]['pick_lng']));
      } else if (choosenRide[0]['pick_lng'] > choosenRide[0]['drop_lng']) {
        bound = LatLngBounds(
            southwest:
                LatLng(choosenRide[0]['pick_lat'], choosenRide[0]['drop_lng']),
            northeast:
                LatLng(choosenRide[0]['drop_lat'], choosenRide[0]['pick_lng']));
      } else if (choosenRide[0]['pick_lat'] > choosenRide[0]['drop_lat']) {
        bound = LatLngBounds(
            southwest:
                LatLng(choosenRide[0]['drop_lat'], choosenRide[0]['pick_lng']),
            northeast:
                LatLng(choosenRide[0]['pick_lat'], choosenRide[0]['drop_lng']));
      } else {
        bound = LatLngBounds(
            southwest:
                LatLng(choosenRide[0]['pick_lat'], choosenRide[0]['pick_lng']),
            northeast:
                LatLng(choosenRide[0]['drop_lat'], choosenRide[0]['drop_lng']));
      }

      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 100);
      _controller?.animateCamera(cameraUpdate);
    }
  }

  addMarker() async {
    polyline.clear();
    if (choosenRide.isNotEmpty || driverReq.isNotEmpty) {
      var testIcon = await capturePng(iconKey);
      if (testIcon != null) {
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('2'),
              icon: testIcon,
              position: (driverReq.isNotEmpty)
                  ? LatLng(driverReq['pick_lat'], driverReq['pick_lng'])
                  : LatLng(
                      choosenRide[0]['pick_lat'], choosenRide[0]['pick_lng'])));
        });
      }
    }
  }

  addPickDropMarker() async {
    addMarker();
    if (driverReq['drop_address'] != null || choosenRide.isNotEmpty) {
      getPolylines();

      addDropMarker();
    }
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

//getting permission and current location
  getLocs() async {
    unloadImage = false;
    afterImageUploadError = '';
    beforeImageUploadError = '';
    shipLoadImage = null;
    shipUnloadImage = null;
    permission = await geolocator.GeolocatorPlatform.instance.checkPermission();
    serviceEnabled =
        await geolocator.GeolocatorPlatform.instance.isLocationServiceEnabled();

    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever ||
        serviceEnabled == false) {
      gettingPerm++;

      if (gettingPerm > 1) {
        locationAllowed = false;
        if (userDetails['active'] == true) {
          var val = await driverStatus();
          if (val == 'logout') {
            navigateLogout();
          }
        }
        state = '3';
      } else {
        state = '2';
      }
      setState(() {
        _isLoading = false;
      });
    } else if (permission == geolocator.LocationPermission.whileInUse ||
        permission == geolocator.LocationPermission.always) {
      if (serviceEnabled == true) {
        final Uint8List markerIcon;
        final Uint8List markerIcon2;
        final Uint8List markerIcon3;
        final Uint8List onrideicon1;
        final Uint8List onridedeliveryicon1;
        final Uint8List offlineicon1;
        final Uint8List offlinedeliveryicon1;
        final Uint8List onlineicon1;
        final Uint8List onlinedeliveryicon1;
        final Uint8List onlinebikeicon1;
        final Uint8List offlinebikeicon1;
        final Uint8List onridebikeicon1;
        // if(userDetails['transport_type'] == 'taxi'){
        markerIcon = await getBytesFromAsset('assets/images/auto-rojo.png', 40);
        markerIcon2 = await getBytesFromAsset('assets/images/bike.png', 40);
        markerIcon3 =
            await getBytesFromAsset('assets/images/vehicle-marker.png', 40);
        if (userDetails['role'] == 'owner') {
          onlinebikeicon1 =
              await getBytesFromAsset('assets/images/bike_online.png', 40);
          onridebikeicon1 =
              await getBytesFromAsset('assets/images/bike_onride.png', 40);
          offlinebikeicon1 =
              await getBytesFromAsset('assets/images/bike.png', 40);
          onrideicon1 =
              await getBytesFromAsset('assets/images/onboardicon.png', 40);
          offlineicon1 =
              await getBytesFromAsset('assets/images/offlineicon.png', 40);
          onlineicon1 =
              await getBytesFromAsset('assets/images/onlineicon.png', 40);
          onridedeliveryicon1 = await getBytesFromAsset(
              'assets/images/onboardicon_delivery.png', 40);
          offlinedeliveryicon1 = await getBytesFromAsset(
              'assets/images/offlineicon_delivery.png', 40);
          onlinedeliveryicon1 = await getBytesFromAsset(
              'assets/images/onlineicon_delivery.png', 40);
          onrideicon = BitmapDescriptor.fromBytes(onrideicon1);
          offlineicon = BitmapDescriptor.fromBytes(offlineicon1);
          onlineicon = BitmapDescriptor.fromBytes(onlineicon1);
          onridedeliveryicon = BitmapDescriptor.fromBytes(onridedeliveryicon1);
          offlinedeliveryicon =
              BitmapDescriptor.fromBytes(offlinedeliveryicon1);
          onlinedeliveryicon = BitmapDescriptor.fromBytes(onlinedeliveryicon1);
          onridebikeicon = BitmapDescriptor.fromBytes(onridebikeicon1);
          offlinebikeicon = BitmapDescriptor.fromBytes(offlinebikeicon1);
          onlinebikeicon = BitmapDescriptor.fromBytes(onlinebikeicon1);
        }

        // if (centerPosition == null) {

        //   geolocator.Geolocator.getPositionStream(
        //     locationSettings: geolocator.LocationSettings(
        //       accuracy: geolocator.LocationAccuracy.best,
        //       distanceFilter: 0,
        //     ),
        //   ).listen((Position? position){
        //     if (position != null) {
        //       setState(() {
        //       centerPosition = LatLng(position.latitude, position.longitude);
        //       heading = position.heading;
        //       newPosition = fmlt.LatLng(position.latitude, position.longitude);
        //       startPoint = newPosition;
        //       });

        //     }
        //     if (showLocationRide == false) {
        //       _fmController.move(newPosition!, 18);
        //     }
        //   });
        // }

        // if (mounted) {
        //   setState(() {
        //     pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
        //     pinLocationIcon2 = BitmapDescriptor.fromBytes(markerIcon2);
        //     pinLocationIcon3 = BitmapDescriptor.fromBytes(markerIcon3);

        //     if (myMarkers.isEmpty && userDetails['role'] != 'owner') {
        //       myMarkers = [
        //         Marker(
        //             markerId: const MarkerId('1'),
        //             rotation: heading,
        //             position: centerPosition ?? LatLng(-21.522367, -64.728692),
        //             icon: (userDetails['vehicle_type_icon_for'] == 'motor_bike')
        //                 ? pinLocationIcon2
        //                 : (userDetails['vehicle_type_icon_for'] == 'taxi')
        //                     ? pinLocationIcon
        //                     : pinLocationIcon3,
        //             anchor: const Offset(0.5, 0.5))
        //       ];
        //     }
        //   });
        // }
      }

      if (makeOnline == true && userDetails['active'] == false) {
        var val = await driverStatus();
        if (val == 'logout') {
          navigateLogout();
        }
      }
      makeOnline = false;
      if (mounted) {
        setState(() {
          locationAllowed = true;
          state = '3';
          _isLoading = false;
        });
      }
      if (choosenRide.isNotEmpty || driverReq.isNotEmpty) {}
    }
  }

  getLocationService() async {
    // await location.requestService();
    await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);
    getLocs();
  }

  getLocationPermission() async {
    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever) {
      if (permission != geolocator.LocationPermission.deniedForever) {
        if (platform == TargetPlatform.android) {
          await perm.Permission.location.request();
          await perm.Permission.locationAlways.request();
        } else {
          await [perm.Permission.location].request();
        }
        if (serviceEnabled == false) {
          // await location.requestService();
          await geolocator.Geolocator.getCurrentPosition(
              desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);
        }
      }
    } else if (serviceEnabled == false) {
      // await location.requestService();
      await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);
    }
    setState(() {
      _isLoading = true;
    });
    getLocs();
  }

  String _permission = '';

  GeoHasher geo = GeoHasher();

  @override
  Widget build(BuildContext context) {
    final dropProvider = Provider.of<DropProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    //get camera permission
    getCameraPermission() async {
      var status = await perm.Permission.camera.status;
      if (status != perm.PermissionStatus.granted) {
        status = await perm.Permission.camera.request();
      }
      return status;
    }

    ImagePicker picker = ImagePicker();
    //pick image from camera
    pickImageFromCamera(id) async {
      var permission = await getCameraPermission();
      if (permission == perm.PermissionStatus.granted) {
        final pickedFile = await picker.pickImage(
            source: ImageSource.camera, imageQuality: 50);
        if (pickedFile != null) {
          setState(() {
            if (id == 1) {
              shipLoadImage = pickedFile.path;
            } else {
              shipUnloadImage = pickedFile.path;
            }
            // _pickImage = false;
          });
        }
      } else {
        setState(() {
          _permission = 'noCamera';
        });
      }
    }

    var media = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      child: Material(
        child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            if (_isDarkTheme != isDarkTheme && _controller != null) {
              _controller!.setMapStyle(mapStyle);
              _isDarkTheme = isDarkTheme;
            }
            if (navigated == false) {
              if (driverReq.isEmpty &&
                  choosenRide.isEmpty &&
                  userDetails.isNotEmpty &&
                  userDetails['role'] != 'owner' &&
                  userDetails['enable_bidding'] == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const RidePage()),
                      (route) => false);
                });
              }
              if (isGeneral == true) {
                isGeneral = false;
                if (lastNotification != latestNotification) {
                  lastNotification = latestNotification;
                  pref.setString('lastNotification', latestNotification);
                  latestNotification = '';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()));
                  });
                }
              }
              if (((choosenRide.isNotEmpty && _pickAnimateDone == false) ||
                      (driverReq.isNotEmpty && _pickAnimateDone == false)) &&
                  (_controller != null || mapType != 'google')) {
                _pickAnimateDone = true;
                if (mounted) {
                  addMarkers();
                }
              }
              if (myMarkers
                  .where((element) => element.markerId == const MarkerId('1'))
                  .isNotEmpty) {
                if (userDetails['vehicle_type_icon_for'] != 'motor_bike' &&
                    myMarkers
                            .firstWhere((element) =>
                                element.markerId == const MarkerId('1'))
                            .icon ==
                        pinLocationIcon2) {
                  myMarkers.removeWhere(
                      (element) => element.markerId == const MarkerId('1'));
                } else if (userDetails['vehicle_type_icon_for'] != 'taxi' &&
                    myMarkers
                            .firstWhere((element) =>
                                element.markerId == const MarkerId('1'))
                            .icon ==
                        pinLocationIcon) {
                  myMarkers.removeWhere(
                      (element) => element.markerId == const MarkerId('1'));
                } else if (userDetails['vehicle_type_icon_for'] != 'truck' &&
                    myMarkers
                            .firstWhere((element) =>
                                element.markerId == const MarkerId('1'))
                            .icon ==
                        pinLocationIcon3) {
                  myMarkers.removeWhere(
                      (element) => element.markerId == const MarkerId('1'));
                }
              }
              if (myMarkers
                      .where(
                          (element) => element.markerId == const MarkerId('1'))
                      .isNotEmpty &&
                  pinLocationIcon != null &&
                  _controller != null &&
                  centerPosition != null) {
                var dist = calculateDistance(
                  myMarkers
                      .firstWhere(
                          (element) => element.markerId == const MarkerId('1'))
                      .position
                      .latitude,
                  myMarkers
                      .firstWhere(
                          (element) => element.markerId == const MarkerId('1'))
                      .position
                      .longitude,
                  centerPosition!.latitude,
                  centerPosition!.longitude,
                );
                if (dist > 100 &&
                    animationController == null &&
                    _controller != null) {
                  animationController = AnimationController(
                    duration: const Duration(
                        milliseconds: 1500), //Animation duration of marker

                    vsync: this, //From the widget
                  );
                  animateCar(
                      myMarkers
                          .firstWhere((element) =>
                              element.markerId == const MarkerId('1'))
                          .position
                          .latitude,
                      myMarkers
                          .firstWhere((element) =>
                              element.markerId == const MarkerId('1'))
                          .position
                          .longitude,
                      centerPosition!.latitude,
                      centerPosition!.longitude,
                      _mapMarkerSink,
                      this,
                      _controller,
                      '1',
                      (userDetails['vehicle_type_icon_for'] == 'motor_bike')
                          ? pinLocationIcon2
                          : (userDetails['vehicle_type_icon_for'] == 'taxi')
                              ? pinLocationIcon
                              : pinLocationIcon3,
                      '',
                      '');
                }
              } else if (myMarkers
                      .where(
                          (element) => element.markerId == const MarkerId('1'))
                      .isEmpty &&
                  pinLocationIcon != null &&
                  centerPosition != null &&
                  userDetails['role'] != 'owner') {
                myMarkers.add(Marker(
                    markerId: const MarkerId('1'),
                    rotation: heading,
                    position: centerPosition!,
                    icon: (userDetails['vehicle_type_icon_for'] == 'motor_bike')
                        ? pinLocationIcon2
                        : (userDetails['vehicle_type_icon_for'] == 'taxi')
                            ? pinLocationIcon
                            : pinLocationIcon3,
                    anchor: const Offset(0.5, 0.5)));
              }
              if (driverReq.isNotEmpty) {
                if (_controller != null) {
                  mapPadding = media.width * 1;
                }
                // if (driverReq['is_completed'] == 1 && driverReq['requestBill'] != null && currentpage == true) {
                //   dropProvider.mostrardDibujadoDestino = false;
                //   initSHaredEndTrip();
                //   pref.remove('requestId');
                //   // navigated = true;
                //   // currentpage = false;
                //   // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   //   Navigator.pushAndRemoveUntil(
                //   //       context,
                //   //       MaterialPageRoute(
                //   //           builder: (context) => const Invoice()),
                //   //       (route) => false);
                //   // });
                //   // _pickAnimateDone = false;
                //   // myMarkers.removeWhere( (element) => element.markerId != const MarkerId('1'));
                //   // polyline.clear();
                //   // polylineGot = false;
                // }
              } else if (choosenRide.isEmpty && driverReq.isEmpty) {
                mapPadding = 0;
                if (myMarkers
                        .where((element) =>
                            element.markerId != const MarkerId('1'))
                        .isNotEmpty &&
                    userDetails['role'] != 'owner') {
                  myMarkers.removeWhere(
                      (element) => element.markerId != const MarkerId('1'));
                  polyline.clear();

                  if (userReject == true) {
                    reqCancel();
                  }
                  _pickAnimateDone = false;
                }
              }
            }

            if (userDetails['approve'] == false && driverReq.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DocsProcess()),
                    (route) => false);
              });
            }
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                drawer: const NavDrawer(),
                // endDrawer: Container(
                //   width: 40,
                //   height: 40,
                //   color: Color.fromRGBO(51, 51, 51, 1),
                // ),
                body: StreamBuilder(
                  stream: userDetails['role'] == 'owner'
                      ? FirebaseDatabase.instance
                          .ref('drivers')
                          .orderByChild('ownerid')
                          .equalTo(userDetails['id'].toString())
                          .onValue
                      : null,
                  builder: (context, AsyncSnapshot<DatabaseEvent> event) {
                    if (event.hasData) {
                      driverData.clear();
                      for (var element in event.data!.snapshot.children) {
                        driverData.add(element.value);
                      }

                      for (var element in driverData) {
                        if (element['l'] != null &&
                            element['is_deleted'] != 1) {
                          if (userDetails['role'] == 'owner') {
                            if (userDetails['role'] == 'owner' &&
                                offlineicon != null &&
                                onlineicon != null &&
                                onrideicon != null &&
                                offlinebikeicon != null &&
                                onlinebikeicon != null &&
                                onridebikeicon != null &&
                                filtericon == 0) {
                              if (myMarkers
                                  .where((e) => e.markerId.toString().contains(
                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                  .isEmpty) {
                                myMarkers.add(Marker(
                                  markerId: (element['is_active'] == 0)
                                      ? MarkerId(
                                          'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                          : MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                  rotation: double.parse(
                                      element['bearing'].toString()),
                                  position:
                                      LatLng(element['l'][0], element['l'][1]),
                                  infoWindow: InfoWindow(
                                      title: element['vehicle_number'],
                                      snippet: element['name']),
                                  anchor: const Offset(0.5, 0.5),
                                  icon: (element['is_active'] == 0)
                                      ? (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                          ? offlinebikeicon
                                          : (element['vehicle_type_icon'] ==
                                                  'taxi')
                                              ? offlineicon
                                              : offlinedeliveryicon
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onlinebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onlineicon
                                                  : onlinedeliveryicon
                                          : (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onridebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onrideicon
                                                  : onridedeliveryicon,
                                ));
                              } else if ((element['is_active'] != 0 && myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon == offlineicon) ||
                                  (element['is_active'] != 0 &&
                                      myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon ==
                                          offlinebikeicon) ||
                                  (element['is_active'] != 0 &&
                                      myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon ==
                                          offlinedeliveryicon)) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'));
                                myMarkers.add(Marker(
                                  markerId: (element['is_active'] == 0)
                                      ? MarkerId(
                                          'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                          : MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                  rotation: double.parse(
                                      element['bearing'].toString()),
                                  position:
                                      LatLng(element['l'][0], element['l'][1]),
                                  infoWindow: InfoWindow(
                                      title: element['vehicle_number'],
                                      snippet: element['name']),
                                  anchor: const Offset(0.5, 0.5),
                                  icon: (element['is_active'] == 0)
                                      ? (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                          ? offlinebikeicon
                                          : (element['vehicle_type_icon'] ==
                                                  'taxi')
                                              ? offlineicon
                                              : offlinedeliveryicon
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onlinebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onlineicon
                                                  : onlinedeliveryicon
                                          : (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onridebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onrideicon
                                                  : onridedeliveryicon,
                                ));
                              } else if ((element['is_available'] != true && myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon == onlineicon) ||
                                  (element['is_available'] != true &&
                                      myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon ==
                                          onlinebikeicon) ||
                                  (element['is_available'] != true &&
                                      myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon ==
                                          onlinedeliveryicon)) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'));
                                myMarkers.add(Marker(
                                  markerId: (element['is_active'] == 0)
                                      ? MarkerId(
                                          'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                          : MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                  rotation: double.parse(
                                      element['bearing'].toString()),
                                  position:
                                      LatLng(element['l'][0], element['l'][1]),
                                  infoWindow: InfoWindow(
                                      title: element['vehicle_number'],
                                      snippet: element['name']),
                                  anchor: const Offset(0.5, 0.5),
                                  icon: (element['is_active'] == 0)
                                      ? (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                          ? offlinebikeicon
                                          : (element['vehicle_type_icon'] ==
                                                  'taxi')
                                              ? offlineicon
                                              : offlinedeliveryicon
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onlinebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onlineicon
                                                  : onlinedeliveryicon
                                          : (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onridebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onrideicon
                                                  : onridedeliveryicon,
                                ));
                              } else if ((element['is_active'] != 1 && myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon == onlineicon) ||
                                  (element['is_active'] != 1 &&
                                      myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon ==
                                          onlinebikeicon) ||
                                  (element['is_active'] != 1 &&
                                      myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon ==
                                          onlinedeliveryicon)) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'));
                                myMarkers.add(Marker(
                                  markerId: (element['is_active'] == 0)
                                      ? MarkerId(
                                          'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                          : MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                  rotation: double.parse(
                                      element['bearing'].toString()),
                                  position:
                                      LatLng(element['l'][0], element['l'][1]),
                                  infoWindow: InfoWindow(
                                      title: element['vehicle_number'],
                                      snippet: element['name']),
                                  anchor: const Offset(0.5, 0.5),
                                  icon: (element['is_active'] == 0)
                                      ? (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                          ? offlinebikeicon
                                          : (element['vehicle_type_icon'] ==
                                                  'taxi')
                                              ? offlineicon
                                              : offlinedeliveryicon
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onlinebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onlineicon
                                                  : onlinedeliveryicon
                                          : (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onridebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onrideicon
                                                  : onridedeliveryicon,
                                ));
                              } else if ((element['is_available'] == true && myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon == onrideicon) ||
                                  (element['is_available'] == true && myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon == onridebikeicon) ||
                                  (element['is_available'] == true && myMarkers.lastWhere((e) => e.markerId.toString().contains('car#${element['id']}#${element['vehicle_type_icon']}')).icon == onridedeliveryicon)) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'));
                                myMarkers.add(Marker(
                                  markerId: (element['is_active'] == 0)
                                      ? MarkerId(
                                          'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                          : MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                  rotation: double.parse(
                                      element['bearing'].toString()),
                                  position:
                                      LatLng(element['l'][0], element['l'][1]),
                                  infoWindow: InfoWindow(
                                      title: element['vehicle_number'],
                                      snippet: element['name']),
                                  anchor: const Offset(0.5, 0.5),
                                  icon: (element['is_active'] == 0)
                                      ? (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                          ? offlinebikeicon
                                          : (element['vehicle_type_icon'] ==
                                                  'taxi')
                                              ? offlineicon
                                              : offlinedeliveryicon
                                      : (element['is_available'] == true &&
                                              element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onlinebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onlineicon
                                                  : onlinedeliveryicon
                                          : (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onridebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onrideicon
                                                  : onridedeliveryicon,
                                ));
                              } else if (_controller != null) {
                                if (myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .latitude !=
                                        element['l'][0] ||
                                    myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .longitude !=
                                        element['l'][1]) {
                                  var dist = calculateDistance(
                                      myMarkers
                                          .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                                  'car#${element['id']}#${element['vehicle_type_icon']}'))
                                          .position
                                          .latitude,
                                      myMarkers
                                          .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                                  'car#${element['id']}#${element['vehicle_type_icon']}'))
                                          .position
                                          .longitude,
                                      element['l'][0],
                                      element['l'][1]);
                                  if (dist > 100 && _controller != null) {
                                    animationController = AnimationController(
                                      duration: const Duration(
                                          milliseconds:
                                              1500), //Animation duration of marker

                                      vsync: this, //From the widget
                                    );

                                    animateCar(
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .latitude,
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .longitude,
                                        element['l'][0],
                                        element['l'][1],
                                        _mapMarkerSink,
                                        this,
                                        _controller,
                                        'car#${element['id']}#${element['vehicle_type_icon']}',
                                        (element['is_active'] == 0)
                                            ? (element['vehicle_type_icon'] ==
                                                    'motor_bike')
                                                ? offlinebikeicon
                                                : (element['vehicle_type_icon'] ==
                                                        'taxi')
                                                    ? offlineicon
                                                    : offlinedeliveryicon
                                            : (element['is_available'] ==
                                                        true &&
                                                    element['is_active'] == 1)
                                                ? (element['vehicle_type_icon'] ==
                                                        'motor_bike')
                                                    ? onlinebikeicon
                                                    : (element['vehicle_type_icon'] ==
                                                            'taxi')
                                                        ? onlineicon
                                                        : onlinedeliveryicon
                                                : (element['vehicle_type_icon'] ==
                                                        'motor_bike')
                                                    ? onridebikeicon
                                                    : (element['vehicle_type_icon'] ==
                                                            'taxi')
                                                        ? onrideicon
                                                        : onridedeliveryicon,
                                        element['vehicle_number'],
                                        element['name']);
                                  }
                                }
                              }
                            } else if (filtericon == 1 &&
                                userDetails['role'] == 'owner' &&
                                onlineicon != null) {
                              if (element['l'] != null) {
                                if (element['is_active'] == 0 &&
                                    offlineicon != null) {
                                  if (myMarkers
                                      .where((e) => e.markerId.toString().contains(
                                          'car#${element['id']}#${element['vehicle_type_icon']}'))
                                      .isEmpty) {
                                    myMarkers.add(Marker(
                                      markerId: (element['is_active'] == 0)
                                          ? MarkerId(
                                              'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                          : (element['is_available'] == true &&
                                                  element['is_active'] == 1)
                                              ? MarkerId(
                                                  'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                              : MarkerId(
                                                  'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                          ? offlinebikeicon
                                          : (element['vehicle_type_icon'] ==
                                                  'taxi')
                                              ? offlineicon
                                              : offlinedeliveryicon,
                                    ));
                                  } else if (_controller != null) {
                                    if (myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                                .position
                                                .latitude !=
                                            element['l'][0] ||
                                        myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                                .position
                                                .longitude !=
                                            element['l'][1]) {
                                      var dist = calculateDistance(
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .latitude,
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .longitude,
                                          element['l'][0],
                                          element['l'][1]);
                                      if (dist > 100 && _controller != null) {
                                        animationController =
                                            AnimationController(
                                          duration: const Duration(
                                              milliseconds:
                                                  1500), //Animation duration of marker

                                          vsync: this, //From the widget
                                        );

                                        animateCar(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1],
                                            _mapMarkerSink,
                                            this,
                                            _controller,
                                            'car#${element['id']}#${element['vehicle_type_icon']}',
                                            (element['vehicle_type_icon'] ==
                                                    'motor_bike')
                                                ? offlinebikeicon
                                                : (element['vehicle_type_icon'] ==
                                                        'taxi')
                                                    ? offlineicon
                                                    : offlinedeliveryicon,
                                            element['vehicle_number'],
                                            element['name']);
                                      }
                                    }
                                  }
                                } else {
                                  if (myMarkers
                                      .where((e) => e.markerId.toString().contains(
                                          'car#${element['id']}#${element['vehicle_type_icon']}'))
                                      .isNotEmpty) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains(
                                            'car#${element['id']}#${element['vehicle_type_icon']}'));
                                  }
                                }
                              }
                            } else if (filtericon == 2 &&
                                userDetails['role'] == 'owner' &&
                                onlineicon != null) {
                              if (element['is_available'] == false &&
                                  element['is_active'] == 1) {
                                if (myMarkers
                                    .where((e) => e.markerId.toString().contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                    .isEmpty) {
                                  myMarkers.add(Marker(
                                    markerId: (element['is_active'] == 0)
                                        ? MarkerId(
                                            'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                        : (element['is_available'] == true &&
                                                element['is_active'] == 1)
                                            ? MarkerId(
                                                'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                            : MarkerId(
                                                'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                    rotation: double.parse(
                                        element['bearing'].toString()),
                                    position: LatLng(
                                        element['l'][0], element['l'][1]),
                                    anchor: const Offset(0.5, 0.5),
                                    icon: (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                        ? onridebikeicon
                                        : (element['vehicle_type_icon'] ==
                                                'taxi')
                                            ? onrideicon
                                            : onridedeliveryicon,
                                  ));
                                } else if (_controller != null) {
                                  if (myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .latitude !=
                                          element['l'][0] ||
                                      myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .longitude !=
                                          element['l'][1]) {
                                    var dist = calculateDistance(
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .latitude,
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .longitude,
                                        element['l'][0],
                                        element['l'][1]);
                                    if (dist > 100 && _controller != null) {
                                      animationController = AnimationController(
                                        duration: const Duration(
                                            milliseconds:
                                                1500), //Animation duration of marker

                                        vsync: this, //From the widget
                                      );

                                      animateCar(
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .latitude,
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .longitude,
                                          element['l'][0],
                                          element['l'][1],
                                          _mapMarkerSink,
                                          this,
                                          _controller,
                                          'car#${element['id']}#${element['vehicle_type_icon']}',
                                          (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onridebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onrideicon
                                                  : onridedeliveryicon,
                                          element['vehicle_number'],
                                          element['name']);
                                    }
                                  }
                                }
                              } else {
                                if (myMarkers
                                    .where((e) => e.markerId.toString().contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                    .isNotEmpty) {
                                  myMarkers.removeWhere((e) => e.markerId
                                      .toString()
                                      .contains(
                                          'car#${element['id']}#${element['vehicle_type_icon']}'));
                                }
                              }
                            } else if (filtericon == 3 &&
                                userDetails['role'] == 'owner' &&
                                onlineicon != null) {
                              if (element['is_available'] == true &&
                                  element['is_active'] == 1) {
                                if (myMarkers
                                    .where((e) => e.markerId.toString().contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'))
                                    .isEmpty) {
                                  myMarkers.add(Marker(
                                    markerId: (element['is_active'] == 0)
                                        ? MarkerId(
                                            'car#${element['id']}#${element['vehicle_type_icon']}#0')
                                        : (element['is_available'] == true &&
                                                element['is_active'] == 1)
                                            ? MarkerId(
                                                'car#${element['id']}#${element['vehicle_type_icon']}#1')
                                            : MarkerId(
                                                'car#${element['id']}#${element['vehicle_type_icon']}#2'),
                                    rotation: double.parse(
                                        element['bearing'].toString()),
                                    position: LatLng(
                                        element['l'][0], element['l'][1]),
                                    anchor: const Offset(0.5, 0.5),
                                    icon: (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                        ? onlinebikeicon
                                        : (element['vehicle_type_icon'] ==
                                                'taxi')
                                            ? onlineicon
                                            : onlinedeliveryicon,
                                  ));
                                } else if (_controller != null) {
                                  if (myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .latitude !=
                                          element['l'][0] ||
                                      myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .longitude !=
                                          element['l'][1]) {
                                    var dist = calculateDistance(
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .latitude,
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                    'car#${element['id']}#${element['vehicle_type_icon']}'))
                                            .position
                                            .longitude,
                                        element['l'][0],
                                        element['l'][1]);
                                    if (dist > 100 && _controller != null) {
                                      animationController = AnimationController(
                                        duration: const Duration(
                                            milliseconds:
                                                1500), //Animation duration of marker

                                        vsync: this, //From the widget
                                      );

                                      animateCar(
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .latitude,
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                              .position
                                              .longitude,
                                          element['l'][0],
                                          element['l'][1],
                                          _mapMarkerSink,
                                          this,
                                          _controller,
                                          'car#${element['id']}#${element['vehicle_type_icon']}',
                                          (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                              ? onlinebikeicon
                                              : (element['vehicle_type_icon'] ==
                                                      'taxi')
                                                  ? onlineicon
                                                  : onlinedeliveryicon,
                                          element['vehicle_number'],
                                          element['name']);
                                    }
                                  }
                                }
                              }
                            } else {
                              if (myMarkers
                                  .where((e) => e.markerId.toString().contains(
                                      'car#${element['id']}#${element['vehicle_type_icon']}'))
                                  .isNotEmpty) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains(
                                        'car#${element['id']}#${element['vehicle_type_icon']}'));
                              }
                            }
                          }
                        } else {
                          if (myMarkers
                              .where((e) => e.markerId.toString().contains(
                                  'car#${element['id']}#${element['vehicle_type_icon']}'))
                              .isNotEmpty) {
                            myMarkers.removeWhere((e) => e.markerId
                                .toString()
                                .contains(
                                    'car#${element['id']}#${element['vehicle_type_icon']}'));
                          }
                        }
                      }
                    }
                    return SingleChildScrollView(
                      child: Stack(
                        children: [
                          // if (estaCargando == true)
                          Container(
                            color: page,
                            height: media.height * 1,
                            width: media.width * 1,
                            child: Column(
                              mainAxisAlignment: (state == '1' || state == '2')
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                (state == '1')
                                    ? Container(
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        width: media.width * 0.6,
                                        height: media.width * 0.3,
                                        decoration: BoxDecoration(
                                            color: page,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 5,
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 2)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              languages[choosenLanguage]
                                                  ['text_enable_location'],
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * sixteen,
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    state = '';
                                                  });
                                                  getLocs();
                                                },
                                                child: Text(
                                                  languages[choosenLanguage]
                                                      ['text_ok'],
                                                  style: GoogleFonts.notoSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          media.width * twenty,
                                                      color: buttonColor),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : (state == '2')
                                        ? Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: media.height * 0.31,
                                                  width: media.width * 0.8,
                                                  child: Image.asset(
                                                    'assets/images/ubicacion_p.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                SizedBox(
                                                  width: media.width * 0.86,
                                                  child: Text(
                                                    'Radio Movil 15 de Abril es un servicio de Taxis las 24 horas en la ciudad de Tarija, Bolivia.',
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            color: const Color
                                                                .fromRGBO(
                                                                212, 16, 22, 1),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                                // Text(
                                                //   languages[choosenLanguage]
                                                //       ['text_trustedtaxi'],
                                                //   style:
                                                //       GoogleFonts.notoSans(
                                                //           fontSize:
                                                //               media.width *
                                                //                   eighteen,
                                                //           fontWeight:
                                                //               FontWeight
                                                //                   .w600),
                                                // ),
                                                SizedBox(
                                                  height: media.width * 0.04,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_allowpermission1'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      0.033,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_allowpermission2'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      0.033,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.08,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      media.width * 0.05,
                                                      0,
                                                      media.width * 0.05,
                                                      0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.075,
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: newRedColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.025,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.8,
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_loc_permission'],
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  fontSize:
                                                                      media.width *
                                                                          0.033,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      media.width * 0.05,
                                                      0,
                                                      media.width * 0.05,
                                                      0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                          width: media.width *
                                                              0.075,
                                                          child: Icon(
                                                            Icons.location_on,
                                                            color: newRedColor,
                                                          )),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.025,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.8,
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_background_permission'],
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  fontSize:
                                                                      media.width *
                                                                          0.033,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        media.height * 0.08),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          newRedColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                  onPressed: () async {
                                                    getLocationPermission();
                                                  },
                                                  child: Text(
                                                    languages[choosenLanguage]
                                                        ['text_continue'],
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            color: page,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : (state == '3')
                                            ? Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: media.height * 1,
                                                    width: media.width * 1,
                                                    //google maps
                                                    child: (mapType == 'google')
                                                        ? StreamBuilder<
                                                            List<Marker>>(
                                                            stream:
                                                                mapMarkerStream,
                                                            builder: (context,
                                                                snapshot) {
                                                              return GoogleMap(
                                                                padding: EdgeInsets.only(
                                                                    bottom:
                                                                        media.width *
                                                                            1,
                                                                    top: media.height *
                                                                            0.1 +
                                                                        MediaQuery.of(context)
                                                                            .padding
                                                                            .top),
                                                                onMapCreated:
                                                                    _onMapCreated,
                                                                initialCameraPosition:
                                                                    CameraPosition(
                                                                  target: (centerPosition ==
                                                                          null)
                                                                      ? _center
                                                                      : centerPosition,
                                                                  zoom: 11.0,
                                                                ),
                                                                markers: Set<
                                                                        Marker>.from(
                                                                    myMarkers),
                                                                polylines:
                                                                    polyline,
                                                                minMaxZoomPreference:
                                                                    const MinMaxZoomPreference(
                                                                        0.0,
                                                                        20.0),
                                                                myLocationButtonEnabled:
                                                                    false,
                                                                compassEnabled:
                                                                    false,
                                                                buildingsEnabled:
                                                                    false,
                                                                zoomControlsEnabled:
                                                                    false,
                                                              );
                                                            },
                                                          )
                                                        : StreamBuilder<
                                                            List<Marker>>(
                                                            stream:
                                                                mapMarkerStream,
                                                            builder: (context,
                                                                snapshot) {
                                                              return fm.FlutterMap(
                                                                mapController:
                                                                    _fmController,
                                                                options: fm
                                                                    .MapOptions(
                                                                  onPositionChanged: (position, bool hasGesture) {
                                                                    if (hasGesture)
                                                                      _onCameraMoveStarted();
                                                                  },
                                                                  initialCenter: currentPositionNew ??
                                                                      const fmlt.LatLng(
                                                                          -21.5355,
                                                                          -64.7296),
                                                                  initialZoom:
                                                                      16,
                                                                  onTap:
                                                                      (P, L) {},
                                                                ),
                                                                children: [
                                                                  ColorFiltered(
                                                                    colorFilter: themeProvider
                                                                            .isDarkTheme
                                                                        ? const ColorFilter
                                                                            .matrix([
                                                                            -1,
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            255, // Invert colors for red
                                                                            0,
                                                                            -1,
                                                                            0,
                                                                            0,
                                                                            255, // Invert colors for green
                                                                            0,
                                                                            0,
                                                                            -1,
                                                                            0,
                                                                            255, // Invert colors for blue
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            1,
                                                                            0, // Alpha channel remains unchanged
                                                                          ])
                                                                        : const ColorFilter.mode(
                                                                            Colors.transparent,
                                                                            BlendMode.multiply),
                                                                    child: fm
                                                                        .TileLayer(
                                                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                                      userAgentPackageName: 'com.example.app',
                                                                    ),
                                                                  ),
                                                                  if (driverReq[
                                                                          'accepted_at'] !=
                                                                      null)
                                                                    driverReq['is_driver_arrived'] ==
                                                                                1 &&
                                                                            driverReq['is_trip_start'] ==
                                                                                0
                                                                        ? Container()
                                                                        : driverReq['is_trip_start'] ==
                                                                                1
                                                                            ? Container()
                                                                            : fm.PolylineLayer(
                                                                                polylines: [
                                                                                  fm.Polyline(
                                                                                    points: routePoints,
                                                                                    color: trazoColor,
                                                                                    strokeWidth: 6,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                  if (endPoint !=
                                                                      null)
                                                                    if (driverReq[
                                                                            'accepted_at'] !=
                                                                        null)
                                                                      if (driverReq[
                                                                              'is_trip_start'] !=
                                                                          1)
                                                                        fm.MarkerLayer(
                                                                          markers: [
                                                                            fm.Marker(
                                                                              rotate: true,
                                                                              height: 55,
                                                                              width: 55,
                                                                              point: endPoint!,
                                                                              child: Container(
                                                                                //Todo: Aumentar tamano y reconstruir
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(themeProvider.isDarkTheme ? 'assets/gifs/icon-user2.gif' : 'assets/gifs/icon-user1.gif'), fit: BoxFit.contain)),
                                                                                height: (platform == TargetPlatform.android) ? media.width * 0.05 : media.width * 0.09,
                                                                                width: (platform == TargetPlatform.android) ? media.width * 0.05 : media.width * 0.09,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                  if (routePoints
                                                                          .isNotEmpty &&
                                                                      mostrarRutaDobleTap ==
                                                                          true)
                                                                    fm.PolylineLayer(
                                                                      // polylineCulling:
                                                                      //     false,
                                                                      polylines: [
                                                                        fm.Polyline(
                                                                            points:
                                                                                routePoints,
                                                                            strokeWidth:
                                                                                4.0,
                                                                            color:
                                                                                newRedColor),
                                                                      ],
                                                                    ),
                                                                  if (dropProvider
                                                                          .routePointsDestino
                                                                          .isNotEmpty &&
                                                                      dropProvider
                                                                              .mostrardDibujadoDestino ==
                                                                          true)
                                                                    fm.PolylineLayer(
                                                                      // polylineCulling:
                                                                      //     false,
                                                                      polylines: [
                                                                        fm.Polyline(
                                                                            points: dropProvider
                                                                                .routePointsDestino,
                                                                            strokeWidth:
                                                                                4.0,
                                                                            color:
                                                                                Colors.green),
                                                                      ],
                                                                    ),
                                                                  fm.MarkerLayer(
                                                                    markers: [
                                                                      //esto marca cuando el driver presiona dos veces sobre la carrera para ver destino
                                                                      if (dropProvider.mostrardDibujadoDestino ==
                                                                              true &&
                                                                          showRequestsOverlay ==
                                                                              false)
                                                                        if (latitudeDestino! != 0.0 && longitudeDestino! != 0.0 ||
                                                                            latitudeDestino != null &&
                                                                                longitudeDestino != null)
                                                                          fm.Marker(
                                                                            rotate:
                                                                                true,
                                                                            width:
                                                                                70,
                                                                            height:
                                                                                70,
                                                                            alignment:
                                                                                Alignment.topCenter,
                                                                            point:
                                                                                fmlt.LatLng(latitudeDestino!, longitudeDestino!),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                const SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Container(
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/meta.png'), fit: BoxFit.contain)),
                                                                                  width: 60,
                                                                                  height: 60,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                      //esto marca cuando el driver presiona dos veces sobre la carrera
                                                                      if (showLocationRide ==
                                                                              true &&
                                                                          showRequestsOverlay ==
                                                                              false)
                                                                        fm.Marker(
                                                                          rotate:
                                                                              true,
                                                                          width:
                                                                              media.width * 0.8,
                                                                          height:
                                                                              media.height * 0.1,
                                                                          alignment:
                                                                              Alignment.topCenter,
                                                                          point: fmlt.LatLng(
                                                                              showRidesLatRecoger!,
                                                                              showRidesLonRecoger!),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Container(
                                                                                padding: const EdgeInsets.all(5),
                                                                                decoration: BoxDecoration(
                                                                                  gradient: LinearGradient(colors: [
                                                                                    (isDarkTheme == true) ? const Color(0xff000000) : const Color(0xffFFFFFF),
                                                                                    (isDarkTheme == true) ? const Color(0xff808080) : const Color(0xffEFEFEF),
                                                                                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                ),
                                                                                child: Text(
                                                                                  nombreUsuario ?? '',
                                                                                  style: GoogleFonts.notoSans(color: textColor, fontSize: (platform == TargetPlatform.android) ? media.width * ten : media.width * twelve),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Container(
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: themeProvider.isDarkTheme ? const AssetImage('assets/gifs/icon-user2.gif') : const AssetImage('assets/gifs/icon-user1.gif'), fit: BoxFit.contain)),
                                                                                height: (platform == TargetPlatform.android) ? media.width * 0.09 : media.width * 0.18,
                                                                                width: (platform == TargetPlatform.android) ? media.width * 0.09 : media.width * 0.18,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      fm.Marker(
                                                                        key: const ValueKey(
                                                                            'driver_marker'), // <- Mantener la misma key
                                                                        rotate:
                                                                            true,
                                                                        alignment:
                                                                            Alignment.topCenter,
                                                                        point: currentPositionNew ??
                                                                            const fmlt.LatLng(-21.5355,
                                                                                -64.7296),
                                                                        width:
                                                                            80,
                                                                        height:
                                                                            80,
                                                                        child: Image.asset(themeProvider.isDarkTheme
                                                                            ? 'assets/gifs/icon-driver2.gif'
                                                                            : 'assets/gifs/icon-driver1.png'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const fm
                                                                      .RichAttributionWidget(
                                                                    attributions: [],
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                  ),
                                                  Positioned(
                                                    right:
                                                        MediaQuery.of(context)
                                                                .padding
                                                                .right +
                                                            20,
                                                    top: MediaQuery.of(context)
                                                            .padding
                                                            .top +
                                                        10,
                                                    child: Column(
                                                      children: [
                                                        ToggleThemeWidget(
                                                            themeProvider:
                                                                themeProvider),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),

                                                        //*ESTE BOTON TIENE QUE ABRIR EL OSMAND DEL DESTINO
                                                        (driverReq['accepted_at'] ==
                                                                null)
                                                            ? Container()
                                                            : latitudeDestino ==
                                                                        null ||
                                                                    latitudeDestino ==
                                                                        0.0
                                                                ? Container()
                                                                : OpenMapApp(
                                                                    acceptDriverBottomSheetOffset:
                                                                        acceptDriverBottomSheetOffset,
                                                                    media:
                                                                        media),
                                                        //*ESTE BOTON TIENE QUE ABRIR EL OSMAND DE LA RECOGIDA
                                                        (driverReq['accepted_at'] ==
                                                                null)
                                                            ? Container()
                                                            : PickUpOpenMap(
                                                                acceptDriverBottomSheetOffset:
                                                                    acceptDriverBottomSheetOffset,
                                                                media: media),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        (driverReq['accepted_at'] ==
                                                                null)
                                                            ? Container()
                                                            : latRecoger == null
                                                                ? Container()
                                                                : CenterDestination(
                                                                    acceptDriverBottomSheetOffset:
                                                                        acceptDriverBottomSheetOffset,
                                                                    media:
                                                                        media,
                                                                    onTap:
                                                                        () async {
                                                                      _onCameraMoveStarted();
                                                                      if (locationAllowed ==
                                                                          true) {
                                                                        if (mapType ==
                                                                            'google') {
                                                                          _controller?.animateCamera(CameraUpdate.newLatLngZoom(
                                                                              centerPosition!,
                                                                              22.0));
                                                                        } else {
                                                                          // TODO: FM GPS Controller
                                                                          _fmController.move(
                                                                              fmlt.LatLng(latRecoger!, lonRecoger!),
                                                                              _fmController.camera.zoom);
                                                                        }
                                                                      } else {
                                                                        if (serviceEnabled ==
                                                                            true) {
                                                                          setState(
                                                                              () {
                                                                            _locationDenied =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          await geolocator.Geolocator.getCurrentPosition(
                                                                              desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);

                                                                          setState(
                                                                              () {
                                                                            _isLoading =
                                                                                true;
                                                                          });
                                                                          await getLocs();
                                                                          if (serviceEnabled ==
                                                                              true) {
                                                                            setState(() {
                                                                              _locationDenied = true;
                                                                            });
                                                                          }
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        //*ESTE BOTON TIENE QUE centrar  al ususario
                                                        (driverReq['accepted_at'] ==
                                                                null)
                                                            ? Container()
                                                            : ValueListenableBuilder(
                                                                valueListenable:
                                                                    acceptDriverBottomSheetOffset,
                                                                builder:
                                                                    (context,
                                                                        offset,
                                                                        child) {
                                                                  double
                                                                      bottomPadding =
                                                                      915 *
                                                                          (offset);
                                                                  return Container(
                                                                    decoration: BoxDecoration(
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              blurRadius: 2,
                                                                              color: Colors.black.withOpacity(0.2),
                                                                              spreadRadius: 2)
                                                                        ],
                                                                        color:
                                                                            page,
                                                                        borderRadius:
                                                                            BorderRadius.circular(media.width *
                                                                                0.02)),
                                                                    child:
                                                                        Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          _onFollowLocationPressed();
                                                                          if (locationAllowed ==
                                                                              true) {
                                                                            if (mapType ==
                                                                                'google') {
                                                                              _controller?.animateCamera(CameraUpdate.newLatLngZoom(centerPosition!, 18.0));
                                                                            } else {
                                                                              // TODO: FM GPS Controller
                                                                              _fmController.move(fmlt.LatLng(currentPositionNew!.latitude, currentPositionNew!.longitude), _fmController.camera.zoom);
                                                                            }
                                                                          } else {
                                                                            if (serviceEnabled ==
                                                                                true) {
                                                                              setState(() {
                                                                                _locationDenied = true;
                                                                              });
                                                                            } else {
                                                                              await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);

                                                                              setState(() {
                                                                                _isLoading = true;
                                                                              });
                                                                              await getLocs();
                                                                              if (serviceEnabled == true) {
                                                                                setState(() {
                                                                                  _locationDenied = true;
                                                                                });
                                                                              }
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              media.width * 0.1,
                                                                          width:
                                                                              media.width * 0.1,

                                                                          // alignment:
                                                                          //     Alignment.center,
                                                                          child:
                                                                              Icon(
                                                                            Icons.my_location_sharp,
                                                                            color:
                                                                                newRedColor,
                                                                            size:
                                                                                media.width * 0.068,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                      ],
                                                    ),
                                                  ),

                                                  //driver status
                                                  Positioned(
                                                    top: MediaQuery.of(context)
                                                            .padding
                                                            .top +
                                                        20,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        if (driverReq[
                                                                'accepted_at'] ==
                                                            null) {
                                                          // Si las condiciones de ubicación están permitidas y el servicio está habilitado
                                                          if (locationAllowed ==
                                                                  true &&
                                                              serviceEnabled ==
                                                                  true) {
                                                            SharedPreferences
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            setState(() {
                                                              _isLoading = true;
                                                            });

                                                            var val =
                                                                await driverStatus();
                                                            if (val == true) {
                                                              if (userDetails[
                                                                      'active'] ==
                                                                  true) {
                                                                FlutterBackgroundService()
                                                                    .invoke(
                                                                        'updateAppLifeState',
                                                                        {
                                                                      "AppLifeState":
                                                                          true
                                                                    });
                                                                SharedPreferences
                                                                    prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                await prefs.setBool(
                                                                    'estaActivo',
                                                                    true);

                                                                await verificarDeudas();
                                                              } else {
                                                                await prefs.setBool(
                                                                    'estaActivo',
                                                                    false);
                                                                if (userDetails[ 'active'] == false) {
                                                                  await detenerUbicacion();
                                                                  // Detén otros recursos aquí
                                                                }
                                                              }
                                                            }
                                                            if (val ==
                                                                'logout') {
                                                              navigateLogout();
                                                            }
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          } else if (locationAllowed ==
                                                                  true &&
                                                              serviceEnabled ==
                                                                  false) {
                                                            // Pedir ubicación si no está habilitada
                                                            await geolocator
                                                                    .Geolocator
                                                                .getCurrentPosition(
                                                              desiredAccuracy:
                                                                  geolocator
                                                                      .LocationAccuracy
                                                                      .bestForNavigation,
                                                            );

                                                            if (await geolocator
                                                                .GeolocatorPlatform
                                                                .instance
                                                                .isLocationServiceEnabled()) {
                                                              serviceEnabled =
                                                                  true;
                                                              setState(() {
                                                                _isLoading =
                                                                    true;
                                                              });

                                                              // Llama a verificarDeudas aquí también
                                                              await verificarDeudas();

                                                              var val =
                                                                  await driverStatus();
                                                              if (val ==
                                                                  'logout') {
                                                                navigateLogout();
                                                              }
                                                              setState(() {
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            }
                                                          } else {
                                                            // Caso en que el servicio está habilitado
                                                            if (serviceEnabled ==
                                                                true) {
                                                              setState(() {
                                                                makeOnline =
                                                                    true;
                                                                _locationDenied =
                                                                    true;
                                                              });
                                                            } else {
                                                              // Intentar obtener la posición si el servicio no está habilitado
                                                              await geolocator
                                                                      .Geolocator
                                                                  .getCurrentPosition(
                                                                desiredAccuracy:
                                                                    geolocator
                                                                        .LocationAccuracy
                                                                        .bestForNavigation,
                                                              );

                                                              setState(() {
                                                                _isLoading =
                                                                    true;
                                                              });
                                                              await getLocs();

                                                              if (serviceEnabled ==
                                                                  true) {
                                                                setState(() {
                                                                  makeOnline =
                                                                      true;
                                                                  _locationDenied =
                                                                      true;
                                                                });
                                                              }
                                                            }
                                                          }
                                                        }
                                                      },
                                                      child:
                                                          OnlineOfflineWidget(
                                                              media: media),
                                                    ),
                                                  ),

                                                  //menu bar -
                                                  Positioned(
                                                    top: MediaQuery.of(context)
                                                            .padding
                                                            .top +
                                                        12.5,
                                                    child: SizedBox(
                                                      width: media.width * 0.9,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.width *
                                                                    0.1,
                                                            width: media.width *
                                                                0.1,
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    blurRadius:
                                                                        2,
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.2),
                                                                    spreadRadius:
                                                                        2)
                                                              ],
                                                              color: page,
                                                              borderRadius: BorderRadius
                                                                  .circular(media
                                                                          .width *
                                                                      0.025),
                                                            ),
                                                            child: StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if ((userDetails['role'] !=
                                                                            'owner' &&
                                                                        userDetails['enable_bidding'] ==
                                                                            true)) {
                                                                      // Scaffold.of(context).openDrawer();
                                                                      addressList
                                                                          .clear();
                                                                      tripStops
                                                                          .clear();
                                                                      Navigator.pop(
                                                                          context);
                                                                    } else {
                                                                      // Navigator.pop(context);
                                                                      Scaffold.of(
                                                                              context)
                                                                          .openDrawer();
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                      (userDetails['role'] != 'owner' &&
                                                                              userDetails['enable_bidding'] ==
                                                                                  true)
                                                                          ? Icons
                                                                              .arrow_back
                                                                          : Icons
                                                                              .menu,
                                                                      size: media
                                                                              .width *
                                                                          0.08,
                                                                      color:
                                                                          newRedColor));
                                                            }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  //online or offline button
                                                  (userDetails['role'] !=
                                                          'owner')
                                                      ? Container()
                                                      : (languageDirection ==
                                                              'rtl')
                                                          ? Positioned(
                                                              top: MediaQuery.of(
                                                                          context)
                                                                      .padding
                                                                      .top +
                                                                  12.5,
                                                              left: 10,
                                                              child:
                                                                  AnimatedContainer(
                                                                curve: Curves
                                                                    .fastLinearToSlowEaseIn,
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            0),
                                                                height: media
                                                                        .width *
                                                                    0.13,
                                                                width: (show == true)
                                                                    ? media.width *
                                                                        0.13
                                                                    : media.width *
                                                                        0.7,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius: show ==
                                                                          true
                                                                      ? BorderRadius.circular(
                                                                          100.0)
                                                                      : const BorderRadius
                                                                          .only(
                                                                          topLeft: Radius.circular(
                                                                              100),
                                                                          bottomLeft: Radius.circular(
                                                                              100),
                                                                          topRight: Radius.circular(
                                                                              20),
                                                                          bottomRight:
                                                                              Radius.circular(20)),
                                                                  color: Colors
                                                                      .white,
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      color: ui
                                                                              .Color
                                                                          .fromARGB(
                                                                              255,
                                                                              8,
                                                                              38,
                                                                              172),
                                                                      offset: Offset(
                                                                          0.0,
                                                                          1.0), //(x,y)
                                                                      blurRadius:
                                                                          10.0,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    show == false
                                                                        ? SizedBox(
                                                                            width:
                                                                                media.width * 0.57,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                OwnerCarImagecontainer(
                                                                                  color: Colors.green,
                                                                                  imgurl: (transportType == 'taxi' || transportType == 'both') ? 'assets/images/available.png' : 'assets/images/available_delivery.png',
                                                                                  text: languages[choosenLanguage]['text_available'],
                                                                                  ontap: () {
                                                                                    setState(() {
                                                                                      filtericon = 3;
                                                                                      myMarkers.clear();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                OwnerCarImagecontainer(
                                                                                  color: Colors.red,
                                                                                  imgurl: (transportType == 'taxi' || transportType == 'both') ? 'assets/images/onboard.png' : 'assets/images/onboard_delivery.png',
                                                                                  text: languages[choosenLanguage]['text_onboard'],
                                                                                  ontap: () {
                                                                                    setState(() {
                                                                                      filtericon = 2;
                                                                                      myMarkers.clear();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                OwnerCarImagecontainer(
                                                                                  color: Colors.grey,
                                                                                  imgurl: (transportType == 'taxi' || transportType == 'both') ? 'assets/images/offlinecar.png' : 'assets/images/offlinecar_delivery.png',
                                                                                  text: languages[choosenLanguage]['text_offline'],
                                                                                  ontap: () {
                                                                                    setState(() {
                                                                                      filtericon = 1;
                                                                                      myMarkers.clear();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          filtericon =
                                                                              0;
                                                                          myMarkers
                                                                              .clear();
                                                                          if (show ==
                                                                              false) {
                                                                            show =
                                                                                true;
                                                                          } else {
                                                                            show =
                                                                                false;
                                                                          }
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: media.width *
                                                                            0.13,
                                                                        decoration: BoxDecoration(
                                                                            image:
                                                                                DecorationImage(image: (transportType == 'taxi' || transportType == 'both') ? const AssetImage('assets/images/bluecar.png') : const AssetImage('assets/images/bluecar_delivery.png'), fit: BoxFit.contain),
                                                                            borderRadius: BorderRadius.circular(100.0)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Positioned(
                                                              top: MediaQuery.of(
                                                                          context)
                                                                      .padding
                                                                      .top +
                                                                  12.5,
                                                              right: 10,
                                                              child:
                                                                  AnimatedContainer(
                                                                curve: Curves
                                                                    .fastLinearToSlowEaseIn,
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            0),
                                                                height: media
                                                                        .width *
                                                                    0.13,
                                                                width: (show == true)
                                                                    ? media.width *
                                                                        0.13
                                                                    : media.width *
                                                                        0.7,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius: show ==
                                                                          true
                                                                      ? BorderRadius.circular(
                                                                          100.0)
                                                                      : const BorderRadius
                                                                          .only(
                                                                          topLeft: Radius.circular(
                                                                              20),
                                                                          bottomLeft: Radius.circular(
                                                                              20),
                                                                          topRight: Radius.circular(
                                                                              100),
                                                                          bottomRight:
                                                                              Radius.circular(100)),
                                                                  color: Colors
                                                                      .white,
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      color: ui
                                                                              .Color
                                                                          .fromARGB(
                                                                              255,
                                                                              8,
                                                                              38,
                                                                              172),
                                                                      offset: Offset(
                                                                          0.0,
                                                                          1.0), //(x,y)
                                                                      blurRadius:
                                                                          10.0,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    show == false
                                                                        ? SizedBox(
                                                                            width:
                                                                                media.width * 0.57,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                OwnerCarImagecontainer(
                                                                                  color: Colors.green,
                                                                                  imgurl: (transportType == 'taxi' || transportType == 'both') ? 'assets/images/available.png' : 'assets/images/available_delivery.png',
                                                                                  text: languages[choosenLanguage]['text_available'],
                                                                                  ontap: () {
                                                                                    setState(() {
                                                                                      filtericon = 3;
                                                                                      myMarkers.clear();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                OwnerCarImagecontainer(
                                                                                  color: Colors.red,
                                                                                  imgurl: (transportType == 'taxi' || transportType == 'both') ? 'assets/images/onboard.png' : 'assets/images/onboard_delivery.png',
                                                                                  text: languages[choosenLanguage]['text_onboard'],
                                                                                  ontap: () {
                                                                                    setState(() {
                                                                                      filtericon = 2;
                                                                                      myMarkers.clear();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                                OwnerCarImagecontainer(
                                                                                  color: Colors.grey,
                                                                                  imgurl: (transportType == 'taxi' || transportType == 'both') ? 'assets/images/offlinecar.png' : 'assets/images/offlinecar_delivery.png',
                                                                                  text: 'Offline',
                                                                                  ontap: () {
                                                                                    setState(() {
                                                                                      filtericon = 1;
                                                                                      myMarkers.clear();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          filtericon =
                                                                              0;
                                                                          myMarkers
                                                                              .clear();
                                                                          if (show ==
                                                                              false) {
                                                                            show =
                                                                                true;
                                                                          } else {
                                                                            show =
                                                                                false;
                                                                          }
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: media.width *
                                                                            0.13,
                                                                        decoration: BoxDecoration(
                                                                            image:
                                                                                DecorationImage(image: (transportType == 'taxi' || transportType == 'both') ? const AssetImage('assets/images/bluecar.png') : const AssetImage('assets/images/bluecar_delivery.png'), fit: BoxFit.contain),
                                                                            borderRadius: BorderRadius.circular(100.0)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                  (driverReq.isEmpty &&
                                                          userDetails['role'] !=
                                                              'owner' &&
                                                          userDetails['transport_type'] !=
                                                              'delivery' &&
                                                          userDetails[
                                                                  'active'] ==
                                                              true &&
                                                          userDetails['show_instant_ride_feature_on_mobile_app'] ==
                                                              '1')
                                                      ? Positioned(
                                                          bottom: media.width *
                                                              0.05,
                                                          left: media.width *
                                                              0.05,
                                                          right: media.width *
                                                              0.05,
                                                          child: Row(
                                                            children: [
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  addressList
                                                                      .clear();
                                                                  var val = await geoCoding(
                                                                      centerPosition!
                                                                          .latitude,
                                                                      centerPosition!
                                                                          .longitude);
                                                                  setState(() {
                                                                    if (addressList
                                                                        .where((element) =>
                                                                            element.type ==
                                                                            'pickup')
                                                                        .isNotEmpty) {
                                                                      var add = addressList.firstWhere((element) =>
                                                                          element
                                                                              .type ==
                                                                          'pickup');
                                                                      add.address =
                                                                          val;
                                                                      add.latlng =
                                                                          LatLng(
                                                                        centerPosition!
                                                                            .latitude,
                                                                        centerPosition!
                                                                            .longitude,
                                                                      );
                                                                    } else {
                                                                      addressList
                                                                          .add(
                                                                        AddressList(
                                                                          id: '1',
                                                                          type:
                                                                              'pickup',
                                                                          address:
                                                                              val,
                                                                          latlng: LatLng(
                                                                              centerPosition!.latitude,
                                                                              centerPosition!.longitude),
                                                                        ),
                                                                      );
                                                                    }
                                                                  });
                                                                  if (addressList
                                                                      .isNotEmpty) {
                                                                    // ignore: use_build_context_synchronously
                                                                    Navigator.push(
                                                                        // ignore: use_build_context_synchronously
                                                                        context,
                                                                        MaterialPageRoute(builder: (context) => const DropLocation()));
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: media
                                                                          .width *
                                                                      0.12,
                                                                  padding: EdgeInsets
                                                                      .all(media
                                                                              .width *
                                                                          0.03),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: (isDarkTheme)
                                                                        ? buttonColor
                                                                        : Colors
                                                                            .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(media.width *
                                                                            0.02),
                                                                  ),
                                                                  child: MyText(
                                                                    text: languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_instant_ride'],
                                                                    size: media
                                                                            .width *
                                                                        sixteen,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: (isDarkTheme)
                                                                        ? Colors
                                                                            .black
                                                                        : page,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ))
                                                      : Container(),

                                                  //request popup accept or reject

                                                  //user cancelled request popup
                                                  (_reqCancelled == true)
                                                      ? Positioned(
                                                          bottom: media.height *
                                                              0.5,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.05),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: page,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.2),
                                                                      blurRadius:
                                                                          2,
                                                                      spreadRadius:
                                                                          2)
                                                                ]),
                                                            child: Text(languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_user_cancelled_request']),
                                                          ))
                                                      : Container(),

                                                  //*Boton de posicionamiento
                                                  (driverReq['accepted_at'] !=
                                                          null)
                                                      ? Container()
                                                      : ValueListenableBuilder(
                                                          valueListenable:
                                                              bottomSheetOffset,
                                                          builder: (context,
                                                              offset, child) {
                                                            double
                                                                bottomPadding =
                                                                500 * (offset);
                                                            return AnimatedPositioned(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              bottom:
                                                                  bottomPadding,
                                                              right: 20,
                                                              child: Container(
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
                                                                    color: themeProvider
                                                                            .isDarkTheme
                                                                        ? newRedColor
                                                                        : page,
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
                                                                      _onFollowLocationPressed();
                                                                      if (locationAllowed ==
                                                                          true) {
                                                                        // _fmController.move(fmlt.LatLng(newPosition!.latitude, newPosition!.longitude), 17);
                                                                        _fmController.move(
                                                                            currentPositionNew ??
                                                                                const fmlt.LatLng(-21.5355, -64.7296),
                                                                            17);
                                                                      } else {
                                                                        if (serviceEnabled ==
                                                                            true) {
                                                                          setState(
                                                                              () {
                                                                            _locationDenied =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          await geolocator.Geolocator.getCurrentPosition(
                                                                              desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);

                                                                          setState(
                                                                              () {
                                                                            _isLoading =
                                                                                true;
                                                                          });
                                                                          await getLocs();
                                                                          if (serviceEnabled ==
                                                                              true) {
                                                                            setState(() {
                                                                              _locationDenied = true;
                                                                            });
                                                                          }
                                                                        }
                                                                      }
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
                                                                          Icons
                                                                              .my_location_sharp,
                                                                          color: themeProvider.isDarkTheme
                                                                              ? page
                                                                              : newRedColor,
                                                                          size: media.width *
                                                                              0.068),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),

                                                  //*Boton de viajes disponibles
                                                  (driverReq['accepted_at'] !=
                                                          null)
                                                      ? Container()
                                                      : ValueListenableBuilder(
                                                          valueListenable:
                                                              bottomSheetOffset,
                                                          builder: (context,
                                                              offset, child) {
                                                            double
                                                                bottomPadding =
                                                                500 * (offset);
                                                            return AnimatedPositioned(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              bottom:
                                                                  bottomPadding,
                                                              left: 20,
                                                              child:
                                                                  BotonMostrarViajesDisponibles(
                                                                onTap: () {
                                                                  setState(() {
                                                                    showRequestsOverlay =
                                                                        true;
                                                                    showLocationRide =
                                                                        false;
                                                                    mostrarRutaDobleTap =
                                                                        false;
                                                                    dropProvider
                                                                            .mostrardDibujadoDestino =
                                                                        false;
                                                                  });
                                                                },
                                                                numViajesDis:
                                                                    '${requestMetas.length}',
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                  //*SHEET CARD QUE APARECE DESDE EL INICIO
                                                  Positioned(
                                                    bottom: 0,
                                                    child: BottomCardSheet(
                                                      bottomSheetOffset:
                                                          bottomSheetOffset,
                                                    ),
                                                  ),
                                                  //*Sheet carreras entrantes
                                                  // Positioned(
                                                  //   bottom: 0,
                                                  //   child: Column(
                                                  //     crossAxisAlignment:
                                                  //         CrossAxisAlignment
                                                  //             .end,
                                                  //     children: [
                                                  //       (driverReq.isNotEmpty &&
                                                  //               driverReq[
                                                  //                       'is_trip_start'] ==
                                                  //                   1)
                                                  //           ? InkWell(
                                                  //               onTap:
                                                  //                   () async {
                                                  //                 setState(
                                                  //                     () {
                                                  //                   showSos =
                                                  //                       true;
                                                  //                 });
                                                  //               },
                                                  //               child:
                                                  //                   Container(
                                                  //                 height:
                                                  //                     media.width *
                                                  //                         0.1,
                                                  //                 width: media
                                                  //                         .width *
                                                  //                     0.1,
                                                  //                 decoration: BoxDecoration(
                                                  //                     boxShadow: [
                                                  //                       BoxShadow(
                                                  //                           blurRadius: 2,
                                                  //                           color: Colors.black.withOpacity(0.2),
                                                  //                           spreadRadius: 2)
                                                  //                     ],
                                                  //                     color:
                                                  //                         buttonColor,
                                                  //                     borderRadius:
                                                  //                         BorderRadius.circular(media.width * 0.02)),
                                                  //                 alignment:
                                                  //                     Alignment
                                                  //                         .center,
                                                  //                 child:
                                                  //                     Text(
                                                  //                   'SOS',
                                                  //                   style: GoogleFonts.notoSans(
                                                  //                       fontSize: media.width *
                                                  //                           fourteen,
                                                  //                       color:
                                                  //                           page),
                                                  //                 ),
                                                  //               ))
                                                  //           : Container(),
                                                  //       const SizedBox(
                                                  //         height: 20,
                                                  //       ),
                                                  //       (driverReq.isNotEmpty &&
                                                  //               driverReq[
                                                  //                       'accepted_at'] !=
                                                  //                   null &&
                                                  //               driverReq[
                                                  //                       'drop_address'] !=
                                                  //                   null)
                                                  //           ? Row(
                                                  //               children: [
                                                  //                 (navigationtype ==
                                                  //                         true)
                                                  //                     ? Container(
                                                  //                         padding: EdgeInsets.all(media.width * 0.02),
                                                  //                         decoration: BoxDecoration(boxShadow: [
                                                  //                           BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                  //                         ], color: page, borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                  //                         child: Row(
                                                  //                           children: [
                                                  //                             InkWell(
                                                  //                               onTap: () {
                                                  //                                 if (driverReq['is_trip_start'] == 0) {
                                                  //                                   openMap(driverReq['pick_lat'], driverReq['pick_lng']);
                                                  //                                 }
                                                  //                                 if (tripStops.isEmpty && driverReq['is_trip_start'] != 0) {
                                                  //                                   openMap(driverReq['drop_lat'], driverReq['drop_lng']);
                                                  //                                 }
                                                  //                               },
                                                  //                               child: SizedBox(
                                                  //                                 width: media.width * 00.07,
                                                  //                                 child: Image.asset('assets/images/googlemaps.png', width: media.width * 0.05, fit: BoxFit.contain),
                                                  //                               ),
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                               width: media.width * 0.02,
                                                  //                             ),
                                                  //                             InkWell(
                                                  //                               onTap: () {
                                                  //                                 if (driverReq['is_trip_start'] == 0) {
                                                  //                                   openWazeMap(driverReq['pick_lat'], driverReq['pick_lng']);
                                                  //                                 }
                                                  //                                 if (tripStops.isEmpty && driverReq['is_trip_start'] != 0) {
                                                  //                                   openWazeMap(driverReq['drop_lat'], driverReq['drop_lng']);
                                                  //                                 }
                                                  //                               },
                                                  //                               child: SizedBox(
                                                  //                                 width: media.width * 00.08,
                                                  //                                 child: Image.asset('assets/images/waze.png', width: media.width * 0.05, fit: BoxFit.contain),
                                                  //                               ),
                                                  //                             ),
                                                  //                           ],
                                                  //                         ),
                                                  //                       )
                                                  //                     : Container(),
                                                  //                 SizedBox(
                                                  //                   width: media.width *
                                                  //                       0.01,
                                                  //                 ),
                                                  //                 InkWell(
                                                  //                   onTap:
                                                  //                       () async {
                                                  //                     if (userDetails['enable_vase_map'] ==
                                                  //                         '1') {
                                                  //                       if (navigationtype ==
                                                  //                           false) {
                                                  //                         if (driverReq['is_trip_start'] == 0) {
                                                  //                           setState(() {
                                                  //                             navigationtype = true;
                                                  //                           });
                                                  //                         } else if (tripStops.isNotEmpty) {
                                                  //                           setState(() {
                                                  //                             _tripOpenMap = true;
                                                  //                           });
                                                  //                         } else {
                                                  //                           setState(() {
                                                  //                             navigationtype = true;
                                                  //                           });
                                                  //                         }
                                                  //                       } else {
                                                  //                         setState(() {
                                                  //                           navigationtype = false;
                                                  //                         });
                                                  //                       }
                                                  //                     } else {
                                                  //                       if (driverReq['is_trip_start'] ==
                                                  //                           0) {
                                                  //                         openMap(driverReq['pick_lat'], driverReq['pick_lng']);
                                                  //                       }
                                                  //                       if (tripStops.isEmpty &&
                                                  //                           driverReq['is_trip_start'] != 0) {
                                                  //                         openMap(driverReq['drop_lat'], driverReq['drop_lng']);
                                                  //                       }
                                                  //                     }
                                                  //                   },
                                                  //                   child: Container(
                                                  //                       height: media.width *
                                                  //                           0.1,
                                                  //                       width: media.width *
                                                  //                           0.1,
                                                  //                       decoration:
                                                  //                           BoxDecoration(boxShadow: [
                                                  //                         BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                  //                       ], color: page, borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                  //                       alignment: Alignment.center,
                                                  //                       child: Image.asset('assets/images/locationFind.png', width: media.width * 0.06, color: textColor)),
                                                  //                 ),
                                                  //               ],
                                                  //             )
                                                  //           : Container(),
                                                  //       const SizedBox(
                                                  //           height: 20),
                                                  //       SizedBox(height: media.width * 0.40),
                                                  //       (choosenRide.isNotEmpty && driverReq.isEmpty)
                                                  //           ? Column(
                                                  //               children: [
                                                  //                 Container(
                                                  //                   padding: const EdgeInsets
                                                  //                       .fromLTRB(
                                                  //                       0,
                                                  //                       0,
                                                  //                       0,
                                                  //                       0),
                                                  //                   width: media.width *
                                                  //                       0.9,
                                                  //                   decoration: BoxDecoration(
                                                  //                       borderRadius:
                                                  //                           BorderRadius.circular(10),
                                                  //                       color: page,
                                                  //                       boxShadow: [
                                                  //                         BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                  //                       ]),
                                                  //                   child:
                                                  //                       Column(
                                                  //                     crossAxisAlignment:
                                                  //                         CrossAxisAlignment.start,
                                                  //                     mainAxisAlignment:
                                                  //                         MainAxisAlignment.spaceBetween,
                                                  //                     children: [
                                                  //                       Container(
                                                  //                         padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.02, media.width * 0.05, media.width * 0.05),
                                                  //                         child: Column(
                                                  //                           crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                           children: [
                                                  //                             Row(
                                                  //                               children: [
                                                  //                                 Container(
                                                  //                                   height: media.width * 0.15,
                                                  //                                   width: media.width * 0.15,
                                                  //                                   decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(choosenRide[0]['user_img']), fit: BoxFit.cover)),
                                                  //                                 ),
                                                  //                                 SizedBox(width: media.width * 0.05),
                                                  //                                 Expanded(
                                                  //                                   child: SizedBox(
                                                  //                                     height: media.width * 0.2,
                                                  //                                     child: Column(
                                                  //                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  //                                       children: [
                                                  //                                         Text(
                                                  //                                           choosenRide[0]['user_name'],
                                                  //                                           maxLines: 1,
                                                  //                                           overflow: TextOverflow.ellipsis,
                                                  //                                           style: GoogleFonts.notoSans(fontSize: media.width * eighteen, color: textColor),
                                                  //                                         ),
                                                  //                                       ],
                                                  //                                     ),
                                                  //                                   ),
                                                  //                                 ),
                                                  //                                 MyText(
                                                  //                                   text: '${choosenRide[0]['km']} km',
                                                  //                                   // maxLines: 1,
                                                  //                                   size: media.width * sixteen,
                                                  //                                 ),
                                                  //                               ],
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                               height: media.width * 0.02,
                                                  //                             ),
                                                  //                             Row(
                                                  //                               mainAxisAlignment: MainAxisAlignment.start,
                                                  //                               children: [
                                                  //                                 Container(
                                                  //                                   height: media.width * 0.05,
                                                  //                                   width: media.width * 0.05,
                                                  //                                   alignment: Alignment.center,
                                                  //                                   decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                                  //                                   child: Container(
                                                  //                                     height: media.width * 0.025,
                                                  //                                     width: media.width * 0.025,
                                                  //                                     decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.8)),
                                                  //                                   ),
                                                  //                                 ),
                                                  //                                 SizedBox(
                                                  //                                   width: media.width * 0.06,
                                                  //                                 ),
                                                  //                                 Expanded(
                                                  //                                   child: MyText(
                                                  //                                     text: choosenRide[0]['pick_address'],
                                                  //                                     // maxLines: 1,
                                                  //                                     size: media.width * twelve,
                                                  //                                   ),
                                                  //                                 ),
                                                  //                               ],
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                               height: media.width * 0.03,
                                                  //                             ),
                                                  //                             Row(
                                                  //                               mainAxisAlignment: MainAxisAlignment.start,
                                                  //                               children: [
                                                  //                                 Container(
                                                  //                                   height: media.width * 0.06,
                                                  //                                   width: media.width * 0.06,
                                                  //                                   alignment: Alignment.center,
                                                  //                                   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                                                  //                                   child: Icon(
                                                  //                                     Icons.location_on_outlined,
                                                  //                                     color: const Color(0xFFFF0000),
                                                  //                                     size: media.width * eighteen,
                                                  //                                   ),
                                                  //                                 ),
                                                  //                                 SizedBox(
                                                  //                                   width: media.width * 0.05,
                                                  //                                 ),
                                                  //                                 Expanded(
                                                  //                                   child: MyText(
                                                  //                                     text: choosenRide[choosenRide.length - 1]['drop_address'],
                                                  //                                     // maxLines: 1,
                                                  //                                     size: media.width * twelve,
                                                  //                                   ),
                                                  //                                 ),
                                                  //                               ],
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                               height: media.width * 0.025,
                                                  //                             ),
                                                  //                             (choosenRide[0]['is_luggage_available'] == true || choosenRide[0]['is_pet_available'] == true)
                                                  //                                 ? Column(
                                                  //                                     children: [
                                                  //                                       Row(
                                                  //                                         children: [
                                                  //                                           MyText(
                                                  //                                             text: languages[choosenLanguage]['text_ride_preference'] + ' :- ',
                                                  //                                             size: media.width * twelve,
                                                  //                                             fontweight: FontWeight.w600,
                                                  //                                           ),
                                                  //                                           SizedBox(
                                                  //                                             width: media.width * 0.025,
                                                  //                                           ),
                                                  //                                           if (choosenRide[0]['is_pet_available'] == true)
                                                  //                                             Row(
                                                  //                                               children: [
                                                  //                                                 Icon(Icons.pets, size: media.width * 0.035, color: theme),
                                                  //                                                 SizedBox(
                                                  //                                                   width: media.width * 0.01,
                                                  //                                                 ),
                                                  //                                                 MyText(
                                                  //                                                   text: languages[choosenLanguage]['text_pets'],
                                                  //                                                   size: media.width * twelve,
                                                  //                                                   fontweight: FontWeight.w600,
                                                  //                                                   color: theme,
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             ),
                                                  //                                           if (choosenRide[0]['is_luggage_available'] == true && choosenRide[0]['is_pet_available'] == true)
                                                  //                                             MyText(
                                                  //                                               text: ', ',
                                                  //                                               size: media.width * fourteen,
                                                  //                                               fontweight: FontWeight.w600,
                                                  //                                               color: theme,
                                                  //                                             ),
                                                  //                                           if (choosenRide[0]['is_luggage_available'] == true)
                                                  //                                             Row(
                                                  //                                               children: [
                                                  //                                                 // Icon(Icons.luggage, size: media.width * 0.05, color: theme),
                                                  //                                                 SizedBox(
                                                  //                                                   height: media.width * 0.035,
                                                  //                                                   width: media.width * 0.05,
                                                  //                                                   child: Image.asset(
                                                  //                                                     'assets/images/luggages.png',
                                                  //                                                     color: theme,
                                                  //                                                   ),
                                                  //                                                 ),
                                                  //                                                 SizedBox(
                                                  //                                                   width: media.width * 0.01,
                                                  //                                                 ),
                                                  //                                                 MyText(
                                                  //                                                   text: languages[choosenLanguage]['text_luggages'],
                                                  //                                                   size: media.width * twelve,
                                                  //                                                   fontweight: FontWeight.w600,
                                                  //                                                   color: theme,
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             ),
                                                  //                                         ],
                                                  //                                       ),
                                                  //                                     ],
                                                  //                                   )
                                                  //                                 : Container(),
                                                  //                             SizedBox(
                                                  //                               height: media.width * 0.02,
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                               child: Row(
                                                  //                                 children: [
                                                  //                                   InkWell(
                                                  //                                     onTap: () {
                                                  //                                       if ((bidText.text.isEmpty && int.parse(choosenRide[0]['price'].toString()) > ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))) || (bidText.text.isNotEmpty && int.parse(bidText.text.toString()) > ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))) {
                                                  //                                         setState(() {
                                                  //                                           bidText.text = (bidText.text.isEmpty)
                                                  //                                               ? (choosenRide[0]['price'].toString().contains('.'))
                                                  //                                                   ? (double.parse(choosenRide[0]['price'].toString()) - ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                                  //                                                   : (int.parse(choosenRide[0]['price'].toString()) - ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString()
                                                  //                                               : (bidText.text.toString().contains('.'))
                                                  //                                                   ? (double.parse(bidText.text.toString()) - ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                                  //                                                   : (int.parse(bidText.text.toString()) - ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString();
                                                  //                                         });
                                                  //                                       }
                                                  //                                     },
                                                  //                                     child: Container(
                                                  //                                       width: media.width * 0.2,
                                                  //                                       alignment: Alignment.center,
                                                  //                                       decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(media.width * 0.04)),
                                                  //                                       padding: EdgeInsets.all(media.width * 0.025),
                                                  //                                       child: Text(
                                                  //                                         // '-10',
                                                  //                                         (userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? '-${double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}' : '-${int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}',
                                                  //                                         style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: page),
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                   ),
                                                  //                                   SizedBox(
                                                  //                                     width: media.width * 0.4,
                                                  //                                     child: TextField(
                                                  //                                       textAlign: TextAlign.center,
                                                  //                                       keyboardType: TextInputType.number,
                                                  //                                       controller: bidText,
                                                  //                                       decoration: InputDecoration(
                                                  //                                         hintText: (choosenRide.isNotEmpty) ? choosenRide[0]['price'].toString() : '',
                                                  //                                         hintStyle: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: textColor),
                                                  //                                         border: UnderlineInputBorder(borderSide: BorderSide(color: hintColor)),
                                                  //                                       ),
                                                  //                                       style: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: textColor),
                                                  //                                     ),
                                                  //                                   ),
                                                  //                                   InkWell(
                                                  //                                     onTap: () {
                                                  //                                       setState(() {
                                                  //                                         bidText.text = (bidText.text.isEmpty)
                                                  //                                             ? (choosenRide[0]['price'].toString().contains('.'))
                                                  //                                                 ? (double.parse(choosenRide[0]['price'].toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                                  //                                                 : (int.parse(choosenRide[0]['price'].toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString()
                                                  //                                             : (bidText.text.toString().contains('.'))
                                                  //                                                 ? (double.parse(bidText.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                                  //                                                 : (int.parse(bidText.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString();
                                                  //                                       });
                                                  //                                     },
                                                  //                                     child: Container(
                                                  //                                       width: media.width * 0.2,
                                                  //                                       alignment: Alignment.center,
                                                  //                                       decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(media.width * 0.04)),
                                                  //                                       padding: EdgeInsets.all(media.width * 0.025),
                                                  //                                       child: Text(
                                                  //                                         // '+10',
                                                  //                                         (userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? '+${double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}' : '+${int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}',
                                                  //                                         style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: page),
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                   ),
                                                  //                                 ],
                                                  //                               ),
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                               height: media.width * 0.02,
                                                  //                             ),
                                                  //                             SizedBox(
                                                  //                                 width: media.width * 0.9,
                                                  //                                 child: Button(
                                                  //                                     onTap: () async {
                                                  //                                       if (bidText.text.isNotEmpty || choosenRide[0]['price'] != null) {
                                                  //                                         setState(() {
                                                  //                                           _isLoading = true;
                                                  //                                         });
                                                  //                                         try {
                                                  //                                           await FirebaseDatabase.instance.ref().child('bid-meta/${choosenRide[0]["request_id"]}/drivers/driver_${userDetails["id"]}').update({
                                                  //                                             'driver_id': userDetails['id'],
                                                  //                                             'price': bidText.text.isNotEmpty ? bidText.text : choosenRide[0]['price'].toString(),
                                                  //                                             'driver_name': userDetails['name'],
                                                  //                                             'driver_img': userDetails['profile_picture'],
                                                  //                                             'bid_time': ServerValue.timestamp,
                                                  //                                             'is_rejected': 'none',
                                                  //                                             'vehicle_make': userDetails['car_make_name'],
                                                  //                                             'vehicle_model': userDetails['car_model_name'],
                                                  //                                             'lat': center!.latitude,
                                                  //                                             'lng': center!.longitude
                                                  //                                           });
                                                  //                                           setState(() {
                                                  //                                             isAvailable = false;
                                                  //                                           });
                                                  //                                           FirebaseDatabase.instance.ref().child('drivers/driver_${userDetails['id']}').update({
                                                  //                                             'is_available': false
                                                  //                                           });
                                                  //                                           // ignore: use_build_context_synchronously
                                                  //                                           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const RidePage()), (route) => false);
                                                  //                                           // Navigator.pop(context);
                                                  //                                         } catch (e) {
                                                  //                                           debugPrint(e.toString());
                                                  //                                         }
                                                  //                                         setState(() {
                                                  //                                           _isLoading = false;
                                                  //                                         });
                                                  //                                       }
                                                  //                                     },
                                                  //                                     text: languages[choosenLanguage]['text_bid']))
                                                  //                           ],
                                                  //                         ),
                                                  //                       )
                                                  //                     ],
                                                  //                   ),
                                                  //                 ),
                                                  //               ],
                                                  //             )
                                                  //           : (driverReq.isNotEmpty)
                                                  //               ? (driverReq['accepted_at'] == null)
                                                  //               //Aca se hace la verificacion si el driver acepta la carrera
                                                  //               //si no la acepta significa que esta disponible para rechazar o ac
                                                  //                   ? Column(
                                                  //                       children: [
                                                  //                         (driverReq['is_later'] == 1 && driverReq['is_rental'] != true)
                                                  //                             ? Container(
                                                  //                                 alignment: Alignment.center,
                                                  //                                 margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                  //                                 padding: EdgeInsets.all(media.width * 0.025),
                                                  //                                 decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                  //                                 width: media.width * 1,
                                                  //                                 child: MyText(
                                                  //                                   text: '${languages[choosenLanguage]['text_rideLaterTime']} ${driverReq['cv_trip_start_time']}',
                                                  //                                   size: media.width * sixteen,
                                                  //                                   color: topBar,
                                                  //                                 ),
                                                  //                               )
                                                  //                             : (driverReq['is_rental'] == true && driverReq['is_later'] != 1)
                                                  //                                 ? Container(
                                                  //                                     alignment: Alignment.center,
                                                  //                                     margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                  //                                     padding: EdgeInsets.all(media.width * 0.025),
                                                  //                                     decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                  //                                     width: media.width * 1,
                                                  //                                     child: MyText(
                                                  //                                       text: '${languages[choosenLanguage]['text_rental_ride']} - ${driverReq['rental_package_name']}',
                                                  //                                       size: media.width * sixteen,
                                                  //                                       color: Colors.black,
                                                  //                                     ),
                                                  //                                   )
                                                  //                                 : (driverReq['is_rental'] == true && driverReq['is_later'] == 1)
                                                  //                                     ? Container(
                                                  //                                         alignment: Alignment.center,
                                                  //                                         margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                  //                                         padding: EdgeInsets.all(media.width * 0.025),
                                                  //                                         decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                  //                                         width: media.width * 1,
                                                  //                                         child: Column(
                                                  //                                           children: [
                                                  //                                             MyText(
                                                  //                                               text: '${languages[choosenLanguage]['text_rideLaterTime']}  ${driverReq['cv_trip_start_time']}',
                                                  //                                               size: media.width * sixteen,
                                                  //                                               color: Colors.black,
                                                  //                                             ),
                                                  //                                             SizedBox(height: media.width * 0.02),
                                                  //                                             MyText(
                                                  //                                               text: '${languages[choosenLanguage]['text_rental_ride']} ${driverReq['rental_package_name']}',
                                                  //                                               size: media.width * sixteen,
                                                  //                                               color: Colors.black,
                                                  //                                             ),
                                                  //                                           ],
                                                  //                                         ),
                                                  //                                       )
                                                  //                                     : Container(),

                                                  //                         Container(
                                                  //                             padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  //                             width: media.width * 1,
                                                  //                             decoration: BoxDecoration(
                                                  //                               borderRadius: BorderRadius.only(topLeft: Radius.circular(media.width * 0.02), topRight: Radius.circular(media.width * 0.02)),
                                                  //                               color: page,
                                                  //                               boxShadow: [
                                                  //                                BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                  //                               ],
                                                  //                           ),
                                                  //                           child: Column(
                                                  //                               crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //                               children: [
                                                  //                                 (duration != 0)
                                                  //                                     ? AnimatedContainer(
                                                  //                                         duration: const Duration(milliseconds: 100),
                                                  //                                         height: 10,
                                                  //                                         width: (media.width * 0.9 / double.parse(userDetails['trip_accept_reject_duration_for_driver'].toString())) * (double.parse(userDetails['trip_accept_reject_duration_for_driver'].toString()) - duration),
                                                  //                                         decoration: BoxDecoration(
                                                  //                                             color: buttonColor,
                                                  //                                             borderRadius: (languageDirection == 'ltr')
                                                  //                                                 ? BorderRadius.only(
                                                  //                                                     topLeft: const Radius.circular(100),
                                                  //                                                     topRight: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                  //                                                   )
                                                  //                                                 : BorderRadius.only(
                                                  //                                                     topRight: const Radius.circular(100),
                                                  //                                                     topLeft: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                  //                                                   )),
                                                  //                                       )
                                                  //                                     : Container(),
                                                  //                                 //*Sheet cuando aparece una carrera - remplazar luego
                                                  //                                 Container(
                                                  //                                   color: Colors.green,
                                                  //                                   padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.02, media.width * 0.05, media.width * 0.05),
                                                  //                                   child: Column(
                                                  //                                     children: [
                                                  //                                       Container(
                                                  //                                         height: media.width * 0.15,
                                                  //                                         width: media.width * 0.15,
                                                  //                                         decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                  //                                       ),
                                                  //                                       SizedBox(
                                                  //                                         height: media.width * 0.05,
                                                  //                                       ),
                                                  //                                       MyText(
                                                  //                                         text: driverReq['userDetail']['data']['name'],
                                                  //                                         size: media.width * eighteen,
                                                  //                                       ),
                                                  //                                       SizedBox(
                                                  //                                         height: media.width * 0.05,
                                                  //                                       ),
                                                  //                                       (driverReq['drop_address'] == null && driverReq['is_rental'] == false)
                                                  //                                           ? Container()
                                                  //                                           : Row(
                                                  //                                               mainAxisAlignment: MainAxisAlignment.center,
                                                  //                                               children: [
                                                  //                                                 Container(
                                                  //                                                   padding: EdgeInsets.all(media.width * 0.03),
                                                  //                                                   decoration: BoxDecoration(
                                                  //                                                     color: Colors.grey.withOpacity(0.1),
                                                  //                                                     border: Border.all(
                                                  //                                                       color: textColor.withOpacity(0.2),
                                                  //                                                     ),
                                                  //                                                     borderRadius: BorderRadius.circular(media.width * 0.02),
                                                  //                                                   ),
                                                  //                                                   child: Row(
                                                  //                                                     children: [
                                                  //                                                       //payment image
                                                  //                                                       SizedBox(
                                                  //                                                         width: media.width * 0.06,
                                                  //                                                         child: (driverReq['payment_opt'].toString() == '1')
                                                  //                                                             ? Image.asset(
                                                  //                                                                 'assets/images/cash.png',
                                                  //                                                                 fit: BoxFit.contain,
                                                  //                                                               )
                                                  //                                                             : (driverReq['payment_opt'].toString() == '2')
                                                  //                                                                 ? Image.asset(
                                                  //                                                                     'assets/images/wallet.png',
                                                  //                                                                     fit: BoxFit.contain,
                                                  //                                                                   )
                                                  //                                                                 : (driverReq['payment_opt'].toString() == '0')
                                                  //                                                                     ? Image.asset(
                                                  //                                                                         'assets/images/card.png',
                                                  //                                                                         fit: BoxFit.contain,
                                                  //                                                                       )
                                                  //                                                                     : Container(),
                                                  //                                                       ),
                                                  //                                                       SizedBox(
                                                  //                                                         width: media.width * 0.02,
                                                  //                                                       ),
                                                  //                                                       MyText(
                                                  //                                                         text: (driverReq['payment_opt'].toString() == '1')
                                                  //                                                             ? languages[choosenLanguage]['text_cash']
                                                  //                                                             : (driverReq['payment_opt'].toString() == '2')
                                                  //                                                                 ? languages[choosenLanguage]['text_wallet']
                                                  //                                                                 : (driverReq['payment_opt'].toString() == '0')
                                                  //                                                                     ? languages[choosenLanguage]['text_card']
                                                  //                                                                     : languages[choosenLanguage]['text_upi'],
                                                  //                                                         // driverReq['payment_type_string'].toString(),
                                                  //                                                         size: media.width * sixteen,
                                                  //                                                       ),
                                                  //                                                       SizedBox(width: media.width * 0.02),
                                                  //                                                       (driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                  //                                                           ? Row(
                                                  //                                                               children: [
                                                  //                                                                 MyText(
                                                  //                                                                   text: driverReq['request_eta_amount'].toStringAsFixed(2),
                                                  //                                                                   size: media.width * fourteen,
                                                  //                                                                   fontweight: FontWeight.w700,
                                                  //                                                                 ),
                                                  //                                                                 MyText(
                                                  //                                                                   text: userDetails['currency_symbol'],
                                                  //                                                                   size: media.width * fourteen,
                                                  //                                                                 )
                                                  //                                                               ],
                                                  //                                                             )
                                                  //                                                           : Container()
                                                  //                                                     ],
                                                  //                                                   ),
                                                  //                                                 )
                                                  //                                               ],
                                                  //                                             ),
                                                  //                                       SizedBox(
                                                  //                                         height: media.width * 0.02,
                                                  //                                       ),
                                                  //                                       SizedBox(
                                                  //                                         height: (tripStops.isEmpty) ? media.width * 0.3 : media.width * 0.4,
                                                  //                                         child: SingleChildScrollView(
                                                  //                                           child: Column(
                                                  //                                             children: [
                                                  //                                               Row(
                                                  //                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                 children: [
                                                  //                                                   Container(
                                                  //                                                     height: media.width * 0.05,
                                                  //                                                     width: media.width * 0.05,
                                                  //                                                     alignment: Alignment.center,
                                                  //                                                     decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                                  //                                                     child: Container(
                                                  //                                                       height: media.width * 0.025,
                                                  //                                                       width: media.width * 0.025,
                                                  //                                                       decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.8)),
                                                  //                                                     ),
                                                  //                                                   ),
                                                  //                                                   SizedBox(
                                                  //                                                     width: media.width * 0.06,
                                                  //                                                   ),
                                                  //                                                   Expanded(
                                                  //                                                     child: MyText(
                                                  //                                                       text: driverReq['pick_address'],
                                                  //                                                       size: media.width * twelve,
                                                  //                                                       // overflow: TextOverflow.ellipsis,
                                                  //                                                       // maxLines: 1,
                                                  //                                                     ),
                                                  //                                                   ),
                                                  //                                                 ],
                                                  //                                               ),
                                                  //                                               SizedBox(
                                                  //                                                 height: media.width * 0.02,
                                                  //                                               ),
                                                  //                                               (tripStops.isNotEmpty)
                                                  //                                                   ? Column(
                                                  //                                                       children: tripStops
                                                  //                                                           .asMap()
                                                  //                                                           .map((i, value) {
                                                  //                                                             return MapEntry(
                                                  //                                                                 i,
                                                  //                                                                 (i < tripStops.length - 1)
                                                  //                                                                     ? Container(
                                                  //                                                                         padding: EdgeInsets.only(top: media.width * 0.02),
                                                  //                                                                         child: Column(
                                                  //                                                                           children: [
                                                  //                                                                             Row(
                                                  //                                                                               children: [
                                                  //                                                                                 SizedBox(
                                                  //                                                                                   width: media.width * 0.8,
                                                  //                                                                                   child: Row(
                                                  //                                                                                     mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                                                     children: [
                                                  //                                                                                       Container(
                                                  //                                                                                         height: media.width * 0.06,
                                                  //                                                                                         width: media.width * 0.06,
                                                  //                                                                                         alignment: Alignment.center,
                                                  //                                                                                         decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                                                  //                                                                                         child: MyText(
                                                  //                                                                                           text: (i + 1).toString(),
                                                  //                                                                                           // maxLines: 1,
                                                  //                                                                                           color: const Color(0xFFFF0000),
                                                  //                                                                                           fontweight: FontWeight.w600,
                                                  //                                                                                           size: media.width * twelve,
                                                  //                                                                                         ),
                                                  //                                                                                       ),
                                                  //                                                                                       SizedBox(
                                                  //                                                                                         width: media.width * 0.05,
                                                  //                                                                                       ),
                                                  //                                                                                       Expanded(
                                                  //                                                                                         child: MyText(
                                                  //                                                                                           text: tripStops[i]['address'],
                                                  //                                                                                           // maxLines: 1,
                                                  //                                                                                           size: media.width * twelve,
                                                  //                                                                                         ),
                                                  //                                                                                       ),
                                                  //                                                                                     ],
                                                  //                                                                                   ),
                                                  //                                                                                 ),
                                                  //                                                                               ],
                                                  //                                                                             ),
                                                  //                                                                           ],
                                                  //                                                                         ),
                                                  //                                                                       )
                                                  //                                                                     : Container());
                                                  //                                                           })
                                                  //                                                           .values
                                                  //                                                           .toList(),
                                                  //                                                     )
                                                  //                                                   : Container(),
                                                  //                                               SizedBox(
                                                  //                                                 height: media.width * 0.02,
                                                  //                                               ),
                                                  //                                               (driverReq['is_rental'] != true && driverReq['drop_address'] != null)
                                                  //                                                   ? Column(
                                                  //                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                       children: [
                                                  //                                                         Row(
                                                  //                                                           mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                           children: [
                                                  //                                                             Container(
                                                  //                                                               height: media.width * 0.06,
                                                  //                                                               width: media.width * 0.06,
                                                  //                                                               alignment: Alignment.center,
                                                  //                                                               decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                                                  //                                                               child: Icon(
                                                  //                                                                 Icons.location_on_outlined,
                                                  //                                                                 color: const Color(0xFFFF0000),
                                                  //                                                                 size: media.width * eighteen,
                                                  //                                                               ),
                                                  //                                                             ),
                                                  //                                                             SizedBox(
                                                  //                                                               width: media.width * 0.05,
                                                  //                                                             ),
                                                  //                                                             Expanded(
                                                  //                                                               child: MyText(
                                                  //                                                                 text: driverReq['drop_address'],
                                                  //                                                                 // maxLines: 1,
                                                  //                                                                 size: media.width * twelve,
                                                  //                                                               ),
                                                  //                                                             ),
                                                  //                                                           ],
                                                  //                                                         ),
                                                  //                                                       ],
                                                  //                                                     )
                                                  //                                                   : Container(),
                                                  //                                             ],
                                                  //                                           ),
                                                  //                                         ),
                                                  //                                       ),
                                                  //                                       SizedBox(
                                                  //                                         height: media.width * 0.02,
                                                  //                                       ),
                                                  //                                       (driverReq['goods_type'] != '-' && driverReq['goods_type'] != null)
                                                  //                                           ? MyText(
                                                  //                                               text: driverReq['goods_type'].toString(),
                                                  //                                               size: media.width * fourteen,
                                                  //                                               color: verifyDeclined,
                                                  //                                             )
                                                  //                                           : Container(),
                                                  //                                       (driverReq['is_luggage_available'] == 1 || driverReq['is_pet_available'] == 1)
                                                  //                                           ? Column(
                                                  //                                               children: [
                                                  //                                                 Row(
                                                  //                                                   children: [
                                                  //                                                     MyText(
                                                  //                                                       text: languages[choosenLanguage]['text_ride_preference'] + ' :- ',
                                                  //                                                       size: media.width * fourteen,
                                                  //                                                       fontweight: FontWeight.w600,
                                                  //                                                     ),
                                                  //                                                     SizedBox(
                                                  //                                                       width: media.width * 0.025,
                                                  //                                                     ),
                                                  //                                                     if (driverReq['is_pet_available'] == 1)
                                                  //                                                       Row(
                                                  //                                                         children: [
                                                  //                                                           Icon(Icons.pets, size: media.width * 0.05, color: theme),
                                                  //                                                           SizedBox(
                                                  //                                                             width: media.width * 0.01,
                                                  //                                                           ),
                                                  //                                                           MyText(
                                                  //                                                             text: languages[choosenLanguage]['text_pets'],
                                                  //                                                             size: media.width * fourteen,
                                                  //                                                             fontweight: FontWeight.w600,
                                                  //                                                             color: theme,
                                                  //                                                           ),
                                                  //                                                         ],
                                                  //                                                       ),
                                                  //                                                     if (driverReq['is_luggage_available'] == 1 && driverReq['is_pet_available'] == 1)
                                                  //                                                       MyText(
                                                  //                                                         text: ', ',
                                                  //                                                         size: media.width * fourteen,
                                                  //                                                         fontweight: FontWeight.w600,
                                                  //                                                         color: theme,
                                                  //                                                       ),
                                                  //                                                     if (driverReq['is_luggage_available'] == 1)
                                                  //                                                       Row(
                                                  //                                                         children: [
                                                  //                                                           // Icon(Icons.luggage, size: media.width * 0.05, color: theme),
                                                  //                                                           SizedBox(
                                                  //                                                             height: media.width * 0.05,
                                                  //                                                             width: media.width * 0.075,
                                                  //                                                             child: Image.asset(
                                                  //                                                               'assets/images/luggages.png',
                                                  //                                                               color: theme,
                                                  //                                                             ),
                                                  //                                                           ),
                                                  //                                                           SizedBox(
                                                  //                                                             width: media.width * 0.01,
                                                  //                                                           ),
                                                  //                                                           MyText(
                                                  //                                                             text: languages[choosenLanguage]['text_luggages'],
                                                  //                                                             size: media.width * fourteen,
                                                  //                                                             fontweight: FontWeight.w600,
                                                  //                                                             color: theme,
                                                  //                                                           ),
                                                  //                                                         ],
                                                  //                                                       ),
                                                  //                                                   ],
                                                  //                                                 ),
                                                  //                                                 SizedBox(
                                                  //                                                   height: media.width * 0.025,
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             )
                                                  //                                           : Container(),
                                                  //                                       SizedBox(
                                                  //                                         height: media.width * 0.04,
                                                  //                                       ),
                                                  //                                       Row(
                                                  //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //                                         children: [
                                                  //                                           Button(
                                                  //                                               color: const Color(0xFFFF0000).withOpacity(0.2),
                                                  //                                               width: media.width * 0.4,
                                                  //                                               textcolor: const Color(0XFFFF0000),
                                                  //                                               onTap: () async {
                                                  //                                                 setState(() {
                                                  //                                                   _isLoading = true;
                                                  //                                                 });
                                                  //                                                 //reject request
                                                  //                                                 await requestReject();
                                                  //                                                 setState(() {
                                                  //                                                   _isLoading = false;
                                                  //                                                 });
                                                  //                                               },
                                                  //                                               text: languages[choosenLanguage]['text_decline']),
                                                  //                                           Button(
                                                  //                                             onTap: () async {
                                                  //                                               setState(() {
                                                  //                                                 _isLoading = true;
                                                  //                                               });
                                                  //                                               await requestAccept();
                                                  //                                               setState(() {
                                                  //                                                 _isLoading = false;
                                                  //                                               });
                                                  //                                             },
                                                  //                                             text: languages[choosenLanguage]['text_accept'],
                                                  //                                             width: media.width * 0.4,
                                                  //                                           )
                                                  //                                         ],
                                                  //                                       )
                                                  //                                     ],
                                                  //                                   ),
                                                  //                                 )

                                                  //                               ],
                                                  //                             ),
                                                  //                         ),
                                                  //                       ],
                                                  //                     )
                                                  //                     //*Aca termina la carta que aparece cuando exitse una carrera
                                                  //                   : (driverReq['accepted_at'] !=
                                                  //                           null)
                                                  //                       ? SizedBox(
                                                  //                           width: media.width * 0.9,
                                                  //                           height: media.width * 0.7,
                                                  //                         )
                                                  //                       : Container(width: media.width * 0.9)
                                                  //               : Container(
                                                  //                   width: media.width *
                                                  //                       0.9,
                                                  //                 ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  // if(showLocationRide == true && showRequestsOverlay == false)
                                                  //  Container(
                                                  //   height: 300,
                                                  //   width: 300,
                                                  //   color: Colors.amber,
                                                  //  ),

                                                  //                                             fm.FlutterMap(
                                                  //                                                           mapController:
                                                  //                                                               _fmController,
                                                  //                                                           options: fm.MapOptions(
                                                  //                                                               initialCenter: pickupLocation ?? fmlt.LatLng(center!.latitude, center!.longitude),
                                                  //                                                               initialZoom: 16,
                                                  //                                                               onTap: (P, L) {},
                                                  //                                                             ),
                                                  //                                                           children: [
                                                  //                                                             fm.TileLayer(
                                                  //                                                               urlTemplate:
                                                  //                                                                   'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                  //                                                               userAgentPackageName:
                                                  //                                                                   'com.example.app',
                                                  //                                                             ),
                                                  //                                                              // Si hay una ubicación de recogida seleccionada, mostrar el marcador
                                                  //                                                               if (pickupLocation != null)
                                                  // fm.MarkerLayer(
                                                  //   markers: [
                                                  //     fm.Marker(
                                                  //       // point: pickupLocation!,
                                                  //        point: pickupLocation!,
                                                  //       child:  const Icon(Icons.location_pin, color: Colors.red, size: 50),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  //                                                           ],
                                                  //                                                         ),

                                                  //  fm.FlutterMap(
                                                  //   options: fm.MapOptions(
                                                  //     initialCenter: pickupLocation ?? fmlt.LatLng(center!.latitude, center!.longitude),
                                                  //     initialZoom: 16,
                                                  //   ),
                                                  //   children: [
                                                  //         fm.TileLayer(
                                                  //           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                  //           userAgentPackageName: 'com.example.app',
                                                  //            ),
                                                  //            if (pickupLocation != null)
                                                  //            fm.MarkerLayer(
                                                  //              markers: [
                                                  //               fm.Marker(
                                                  //                 point: pickupLocation!,
                                                  //                  child: const Icon(Icons.location_pin, color: Colors.red, size: 50),
                                                  //                  ),
                                                  //                  ],
                                                  //                 ),
                                                  //   ],
                                                  // ),

                                                  if (showRequestsOverlay &&
                                                      requestMetas.isNotEmpty &&
                                                      mostrarRutaDobleTap ==
                                                          false)
                                                    (driverReq['accepted_at'] !=
                                                            null)
                                                        ? Container()
                                                        : ShowRides(
                                                            onDoubleTap: (int
                                                                index) async {
                                                              setState(() {
                                                                showLocationRide =
                                                                    true;
                                                                showRequestsOverlay =
                                                                    false;
                                                                requestIdDoubleTapUser =
                                                                    requestMetas[
                                                                            index]
                                                                        .requestId;
                                                                showRidesLatRecoger =
                                                                    requestMetas[
                                                                            index]
                                                                        .recogidaLat;
                                                                showRidesLonRecoger =
                                                                    requestMetas[
                                                                            index]
                                                                        .recogidaLong;

                                                                longitudeDestino =
                                                                    requestMetas[
                                                                            index]
                                                                        .destinoLong;
                                                                latitudeDestino =
                                                                    requestMetas[
                                                                            index]
                                                                        .destinoLat;
                                                                nombreUsuario =
                                                                    requestMetas[
                                                                            index]
                                                                        .nomUsuario;
                                                                final lonlat =
                                                                    fmlt.LatLng(
                                                                        showRidesLatRecoger!,
                                                                        showRidesLonRecoger!);
                                                                _fmController
                                                                    .move(
                                                                        lonlat,
                                                                        18);
                                                              });

                                                              // Obtener la ruta del servicio GraphHopper
                                                              if (showRidesLatRecoger !=
                                                                      null &&
                                                                  showRidesLonRecoger !=
                                                                      null) {
                                                                try {
                                                                  // Aquí llamamos a la función que obtiene la ruta desde GraphHopper
                                                                  List<fmlt.LatLng> points = await getRouteFromGraphHopper(
                                                                      currentPositionNew!
                                                                          .latitude,
                                                                      currentPositionNew!
                                                                          .longitude,
                                                                      showRidesLatRecoger!,
                                                                      showRidesLonRecoger!);

                                                                  setState(() {
                                                                    mostrarRutaDobleTap =
                                                                        true;
                                                                    routePoints =
                                                                        points; // Actualizamos los puntos de la ruta
                                                                  });
                                                                } catch (e) {
                                                                  print(
                                                                      'Error al obtener la ruta: $e');
                                                                }
                                                              }
                                                              if (latitudeDestino !=
                                                                      0.0 &&
                                                                  longitudeDestino !=
                                                                      0.0) {
                                                                try {
                                                                  // Aquí llamamos a la función que obtiene la ruta desde GraphHopper
                                                                  List<
                                                                          fmlt
                                                                          .LatLng>
                                                                      points =
                                                                      await getRouteFromGraphHopper(
                                                                          showRidesLatRecoger!,
                                                                          showRidesLonRecoger!,
                                                                          latitudeDestino!,
                                                                          longitudeDestino!);

                                                                  setState(() {
                                                                    dropProvider
                                                                            .mostrardDibujadoDestino =
                                                                        true;
                                                                    dropProvider
                                                                            .routePointsDestino =
                                                                        points; // Actualizamos los puntos de la ruta
                                                                  });
                                                                } catch (e) {
                                                                  print(
                                                                      'Error al obtener la ruta: $e');
                                                                }
                                                              }

                                                              // Seguir escuchando cambios en la solicitud
                                                              listenToRequestChanges(
                                                                  requestIdDoubleTapUser!);
                                                            },
                                                            rejectedRides:
                                                                rejectedRides,
                                                            listRequests:
                                                                requestMetas,
                                                            media: media,
                                                            onTap: () {
                                                              setState(() {
                                                                showRequestsOverlay =
                                                                    false;
                                                              });
                                                            },
                                                          ),

                                                  if (estaCargando)
                                                    Container(
                                                      height: media.height * 1,
                                                      width: media.width * 1,
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: newRedColor,
                                                        ),
                                                      ),
                                                    ),

                                                  // //*ESTE BOTON TIENE QUE centrar  al ususario
                                                  // (driverReq['accepted_at'] ==
                                                  //         null)
                                                  //     ? Container()
                                                  //     : ValueListenableBuilder(
                                                  //         valueListenable:
                                                  //             acceptDriverBottomSheetOffset,
                                                  //         builder: (context,
                                                  //             offset, child) {
                                                  //           double
                                                  //               bottomPadding =
                                                  //               915 * (offset);
                                                  //           return AnimatedPositioned(
                                                  //             duration:
                                                  //                 const Duration(
                                                  //                     milliseconds:
                                                  //                         300),
                                                  //             bottom:
                                                  //                 bottomPadding,
                                                  //             right: 20,
                                                  //             child: Container(
                                                  //               decoration: BoxDecoration(
                                                  //                   boxShadow: [
                                                  //                     BoxShadow(
                                                  //                         blurRadius:
                                                  //                             2,
                                                  //                         color: Colors.black.withOpacity(
                                                  //                             0.2),
                                                  //                         spreadRadius:
                                                  //                             2)
                                                  //                   ],
                                                  //                   color: page,
                                                  //                   borderRadius:
                                                  //                       BorderRadius.circular(media.width *
                                                  //                           0.02)),
                                                  //               child: Material(
                                                  //                 color: Colors
                                                  //                     .transparent,
                                                  //                 child:
                                                  //                     InkWell(
                                                  //                   onTap:
                                                  //                       () async {
                                                  //                         _onFollowLocationPressed();
                                                  //                     if (locationAllowed ==
                                                  //                         true) {
                                                  //                       if (mapType ==
                                                  //                           'google') {
                                                  //                         _controller?.animateCamera(CameraUpdate.newLatLngZoom(
                                                  //                             centerPosition!,
                                                  //                             18.0));
                                                  //                       } else {
                                                  //                         _fmController.move(
                                                  //                             fmlt.LatLng(currentPositionNew!.latitude, currentPositionNew!.longitude),
                                                  //                             _fmController.camera.zoom);
                                                  //                       }
                                                  //                     } else {
                                                  //                       if (serviceEnabled ==
                                                  //                           true) {
                                                  //                         setState(
                                                  //                             () {
                                                  //                           _locationDenied =
                                                  //                               true;
                                                  //                         });
                                                  //                       } else {
                                                  //                         await geolocator.Geolocator.getCurrentPosition(
                                                  //                             desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation);

                                                  //                         setState(
                                                  //                             () {
                                                  //                           _isLoading =
                                                  //                               true;
                                                  //                         });
                                                  //                         await getLocs();
                                                  //                         if (serviceEnabled ==
                                                  //                             true) {
                                                  //                           setState(() {
                                                  //                             _locationDenied = true;
                                                  //                           });
                                                  //                         }
                                                  //                       }
                                                  //                     }
                                                  //                   },
                                                  //                   child:
                                                  //                       SizedBox(
                                                  //                     height:
                                                  //                         media.width *
                                                  //                             0.1,
                                                  //                     width: media
                                                  //                             .width *
                                                  //                         0.1,

                                                  //                     // alignment:
                                                  //                     //     Alignment.center,
                                                  //                     child:
                                                  //                         Icon(
                                                  //                       Icons
                                                  //                           .my_location_sharp,
                                                  //                       color:
                                                  //                           newRedColor,
                                                  //                       size: media.width *
                                                  //                           0.068,
                                                  //                     ),
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //           );
                                                  //         }),

                                                  (driverReq['is_driver_arrived'] ==
                                                              1 &&
                                                          driverReq[
                                                                  'is_trip_start'] ==
                                                              0)
                                                      ? NotificarCliente(
                                                          acceptDriverBottomSheetOffset:
                                                              acceptDriverBottomSheetOffset,
                                                          media: media,
                                                          onTap: () async {
                                                            showAdaptiveDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return const AlertaNotificarLlegada();
                                                                });
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                  // //*ESTE BOTON TIENE QUE ABRIR centrar el donde esta el ususario
                                                  // (driverReq['accepted_at'] ==
                                                  //         null)
                                                  //     ? Container()
                                                  //     : latRecoger == null
                                                  //         ? Container()
                                                  //         : CenterDestination(
                                                  //             acceptDriverBottomSheetOffset:
                                                  //                 acceptDriverBottomSheetOffset,
                                                  //             media: media,
                                                  //             onTap: () async {
                                                  //               _onCameraMoveStarted();
                                                  //               if (locationAllowed ==
                                                  //                   true) {
                                                  //                 if (mapType ==
                                                  //                     'google') {
                                                  //                   _controller?.animateCamera(
                                                  //                       CameraUpdate.newLatLngZoom(
                                                  //                           centerPosition!,
                                                  //                           22.0));
                                                  //                 } else {
                                                  //                   _fmController.move(
                                                  //                       fmlt.LatLng(
                                                  //                           latRecoger!,
                                                  //                           lonRecoger!),
                                                  //                       _fmController
                                                  //                           .camera
                                                  //                           .zoom);
                                                  //                 }
                                                  //               } else {
                                                  //                 if (serviceEnabled ==
                                                  //                     true) {
                                                  //                   setState(
                                                  //                       () {
                                                  //                     _locationDenied =
                                                  //                         true;
                                                  //                   });
                                                  //                 } else {
                                                  //                   await geolocator
                                                  //                           .Geolocator
                                                  //                       .getCurrentPosition(
                                                  //                           desiredAccuracy:
                                                  //                               geolocator.LocationAccuracy.bestForNavigation);

                                                  //                   setState(
                                                  //                       () {
                                                  //                     _isLoading =
                                                  //                         true;
                                                  //                   });
                                                  //                   await getLocs();
                                                  //                   if (serviceEnabled ==
                                                  //                       true) {
                                                  //                     setState(
                                                  //                         () {
                                                  //                       _locationDenied =
                                                  //                           true;
                                                  //                     });
                                                  //                   }
                                                  //                 }
                                                  //               }
                                                  //             },
                                                  //           ),

                                                  // //*ESTE BOTON TIENE QUE ABRIR EL OSMAND DE LA RECOGIDA
                                                  // (driverReq['accepted_at'] ==
                                                  //         null)
                                                  //     ? Container()
                                                  //     : PickUpOpenMap(
                                                  //         acceptDriverBottomSheetOffset:
                                                  //             acceptDriverBottomSheetOffset,
                                                  //         media: media),

                                                  // //*ESTE BOTON TIENE QUE ABRIR EL OSMAND DEL DESTINO
                                                  // (driverReq['accepted_at'] ==
                                                  //         null)
                                                  //     ? Container()
                                                  //     : latitudeDestino ==
                                                  //                 null ||
                                                  //             latitudeDestino ==
                                                  //                 0.0
                                                  //         ? Container()
                                                  //         : OpenMapApp(
                                                  //             acceptDriverBottomSheetOffset:
                                                  //                 acceptDriverBottomSheetOffset,
                                                  //             media: media),

                                                  if (mostrarAlertaConfirmacion ==
                                                      true)
                                                    Alertas(
                                                      titulo:
                                                          '¡El pasajero acaba de confirmar!',
                                                      contenido:
                                                          'El pasajero ya está en camino, preparate para recibirlo.',
                                                      textoBoton: 'Aceptar',
                                                      botonOnTapAceptar: () {
                                                        setState(() {
                                                          mostrarAlertaConfirmacion =
                                                              false;
                                                        });
                                                      },
                                                      botonOnTapSalir: () {
                                                        mostrarAlertaConfirmacion =
                                                            false;
                                                      },
                                                    ),

                                                  //*Cuando se acpeta el viaje
                                                  isAvailable == false
                                                      ? Positioned(
                                                          bottom: 0,
                                                          child:
                                                              BottomCardSheetDriverAccept(
                                                            bottomSheetOffset:
                                                                acceptDriverBottomSheetOffset,
                                                            driverOtp:
                                                                driverOtp,
                                                            errorOtp: _errorOtp,
                                                            navigationtype:
                                                                navigationtype,
                                                            isLoading:
                                                                _isLoading,
                                                            getStartOtp:
                                                                getStartOtp,
                                                            navigateLogout:
                                                                navigateLogout,
                                                            onTapCancelar:
                                                                () async {
                                                              setState(() {
                                                                _isLoading =
                                                                    true;
                                                              });
                                                              var val = await cancelReason(
                                                                  (driverReq['is_driver_arrived'] ==
                                                                          0)
                                                                      ? 'before'
                                                                      : 'after');
                                                              if (val == true) {
                                                                setState(() {
                                                                  cancelRequest =
                                                                      true;
                                                                  _cancelReason =
                                                                      '';
                                                                  _cancellingError =
                                                                      '';
                                                                });
                                                                //   Future.delayed(const Duration(seconds: 1), (){
                                                                //   Navigator.pop(context);
                                                                // });
                                                              }
                                                              setState(() {
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            },
                                                            // bottomSheetOffset: bottomSheetOffset,
                                                          ),
                                                        )
                                                      : Container()
                                                  // on ride bottom sheet
                                                  // (driverReq['accepted_at'] != null)
                                                  //     ? AnimatedPositioned(
                                                  //         duration:
                                                  //             const Duration(
                                                  //                 milliseconds:
                                                  //                     250),
                                                  //         bottom: addressBottom !=
                                                  //                 null
                                                  //             ? -addressBottom
                                                  //             : -(media
                                                  //                     .height -
                                                  //                 (media
                                                  //                     .width)),
                                                  //         child:
                                                  //             GestureDetector(
                                                  //           onVerticalDragStart:
                                                  //               (v) {
                                                  //             _cont.jumpTo(
                                                  //                 0.0);
                                                  //             start = v
                                                  //                 .globalPosition
                                                  //                 .dy;
                                                  //             if (addressBottom !=
                                                  //                 null) {
                                                  //               _addressBottom =
                                                  //                   addressBottom;
                                                  //             } else {
                                                  //               addressBottom =
                                                  //                   (media.height -
                                                  //                       media.width);
                                                  //               _addressBottom =
                                                  //                   addressBottom;
                                                  //             }
                                                  //             gesture
                                                  //                 .clear();
                                                  //           },
                                                  //           onVerticalDragUpdate:
                                                  //               (v) {
                                                  //             // if (v.globalPosition.dy < (media.width * 0.8)) {
                                                  //             //   _addressBottom = media.height -
                                                  //             //       (media.height - v.globalPosition.dy);
                                                  //             //   // print('comingg ${v.globalPosition.dy} $_addressBottom');
                                                  //             // } else {
                                                  //             //   _addressBottom = media.width * 0.8;
                                                  //             // }
                                                  //             if ((_addressBottom +
                                                  //                         (v.globalPosition.dy -
                                                  //                             start)) >
                                                  //                     media.height *
                                                  //                         0.2 &&
                                                  //                 (_addressBottom +
                                                  //                         (v.globalPosition.dy -
                                                  //                             start)) <
                                                  //                     ((media.height * 1.25) -
                                                  //                         media.width)) {
                                                  //               addressBottom =
                                                  //                   _addressBottom +
                                                  //                       (v.globalPosition.dy -
                                                  //                           start);
                                                  //             }
                                                  //             setState(
                                                  //                 () {});
                                                  //           },
                                                  //           onVerticalDragEnd:
                                                  //               (v) {},
                                                  //           child: Column(
                                                  //             children: [
                                                  //               // (driverReq['is_trip_start'] ==
                                                  //               //         0)
                                                  //               //     ? Column(
                                                  //               //         children: [
                                                  //               //           (driverReq['is_later'] == 1 && driverReq['is_rental'] != true)
                                                  //               //               ? Container(
                                                  //               //                   alignment: Alignment.center,
                                                  //               //                   margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                  //               //                   padding: EdgeInsets.all(media.width * 0.025),
                                                  //               //                   decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                  //               //                   width: media.width * 1,
                                                  //               //                   child: MyText(
                                                  //               //                     text: '${languages[choosenLanguage]['text_rideLaterTime']} ${driverReq['cv_trip_start_time']}',
                                                  //               //                     size: media.width * sixteen,
                                                  //               //                     color: topBar,
                                                  //               //                   ),
                                                  //               //                 )
                                                  //               //               : (driverReq['is_rental'] == true && driverReq['is_later'] != 1)
                                                  //               //                   ? Container(
                                                  //               //                       alignment: Alignment.center,
                                                  //               //                       margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                  //               //                       padding: EdgeInsets.all(media.width * 0.025),
                                                  //               //                       decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                  //               //                       width: media.width * 1,
                                                  //               //                       child: MyText(
                                                  //               //                         text: '${languages[choosenLanguage]['text_rental_ride']} - ${driverReq['rental_package_name']}',
                                                  //               //                         size: media.width * sixteen,
                                                  //               //                         color: Colors.black,
                                                  //               //                       ),
                                                  //               //                     )
                                                  //               //                   : (driverReq['is_rental'] == true && driverReq['is_later'] == 1)
                                                  //               //                       ? Container(
                                                  //               //                           alignment: Alignment.center,
                                                  //               //                           margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                  //               //                           padding: EdgeInsets.all(media.width * 0.025),
                                                  //               //                           decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                  //               //                           width: media.width * 1,
                                                  //               //                           child: Column(
                                                  //               //                             children: [
                                                  //               //                               MyText(
                                                  //               //                                 text: '${languages[choosenLanguage]['text_rideLaterTime']}  ${driverReq['cv_trip_start_time']}',
                                                  //               //                                 size: media.width * sixteen,
                                                  //               //                                 color: Colors.black,
                                                  //               //                               ),
                                                  //               //                               SizedBox(height: media.width * 0.02),
                                                  //               //                               MyText(
                                                  //               //                                 text: '${languages[choosenLanguage]['text_rental_ride']} ${driverReq['rental_package_name']}',
                                                  //               //                                 size: media.width * sixteen,
                                                  //               //                                 color: Colors.black,
                                                  //               //                               ),
                                                  //               //                             ],
                                                  //               //                           ),
                                                  //               //                         )
                                                  //               //                       : Container(),
                                                  //               //         ],
                                                  //               //       )
                                                  //               //     : Container(),

                                                  //               //*Contenedor que contiene cuando el chofer acepta el viaje
                                                  //               Container(
                                                  //                 padding: EdgeInsets.all(
                                                  //                     media.width *
                                                  //                         0.05),
                                                  //                 width:
                                                  //                     media.width *
                                                  //                         1,
                                                  //                 height:
                                                  //                     media.height *
                                                  //                         1.2,
                                                  //                 decoration: BoxDecoration(
                                                  //                     borderRadius: const BorderRadius
                                                  //                         .only(
                                                  //                         topLeft: Radius.circular(10),
                                                  //                         topRight: Radius.circular(10)),
                                                  //                     color: Colors.amber),
                                                  //                 child:
                                                  //                     Column(
                                                  //                   children: [
                                                  //                     Container(
                                                  //                       width:
                                                  //                           media.width * 0.13,
                                                  //                       height:
                                                  //                           media.width * 0.012,
                                                  //                       decoration: BoxDecoration(
                                                  //                           borderRadius: const BorderRadius.all(
                                                  //                             Radius.circular(10),
                                                  //                           ),
                                                  //                           color: Colors.grey.withOpacity(0.5)),
                                                  //                     ),
                                                  //                     SizedBox(
                                                  //                         height: media.width * 0.02),
                                                  //                     Row(
                                                  //                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //                       children: [
                                                  //                         Expanded(
                                                  //                           child: Row(
                                                  //                             children: [
                                                  //                               Image.asset(
                                                  //                                   (driverReq['is_driver_arrived'] == 0)
                                                  //                                       ? 'assets/images/ontheway.png'
                                                  //                                       : (driverReq['is_trip_start'] == 1)
                                                  //                                           ? 'assets/images/ontheway_icon.png'
                                                  //                                           : 'assets/images/startonthe.png',
                                                  //                                   width: media.width * 0.075,
                                                  //                                   color: textColor),
                                                  //                               SizedBox(
                                                  //                                 width: media.width * 0.02,
                                                  //                               ),
                                                  //                               Expanded(
                                                  //                                 child: MyText(
                                                  //                                   text: (driverReq['is_driver_arrived'] == 0)
                                                  //                                       ? languages[choosenLanguage]['text_in_the_way']
                                                  //                                       : (driverReq['is_trip_start'] == 1)
                                                  //                                           ? (driverReq['drop_address'] == null || distTime == null)
                                                  //                                               ? languages[choosenLanguage]['text_wat_to_drop']
                                                  //                                               : '${languages[choosenLanguage]['text_onride']} ${double.parse(((distTime * 2)).toString()).round()} ${languages[choosenLanguage]['text_mins']}'
                                                  //                                           : languages[choosenLanguage]['text_waiting_rider'],
                                                  //                                   size: media.width * fourteen,
                                                  //                                   fontweight: FontWeight.w700,
                                                  //                                 ),
                                                  //                               ),
                                                  //                             ],
                                                  //                           ),
                                                  //                         ),
                                                  //                         (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                  //                             ? (waitingTime / 60 >= 1)
                                                  //                                 ? Container(
                                                  //                                     padding: EdgeInsets.all(media.width * 0.03),
                                                  //                                     decoration: BoxDecoration(color: topBar, borderRadius: BorderRadius.circular(media.width * 0.02), border: Border.all(color: Colors.grey.withOpacity(0.5))),
                                                  //                                     child: (driverReq['accepted_at'] == null && driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                  //                                         ? MyText(
                                                  //                                             text: userDetails['currency_symbol'] + driverReq['request_eta_amount'].toString(),
                                                  //                                             size: media.width * fourteen,
                                                  //                                             color: isDarkTheme == true ? Colors.black : textColor,
                                                  //                                           )
                                                  //                                         : (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                  //                                             ? (waitingTime / 60 >= 1)
                                                  //                                                 ? Column(
                                                  //                                                     children: [
                                                  //                                                       MyText(text: 'Waiting Time', size: media.width * twelve),
                                                  //                                                       SizedBox(
                                                  //                                                         height: media.width * 0.015,
                                                  //                                                       ),
                                                  //                                                       Row(
                                                  //                                                         children: [
                                                  //                                                           Icon(
                                                  //                                                             Icons.alarm_outlined,
                                                  //                                                             size: media.width * fourteen,
                                                  //                                                           ),
                                                  //                                                           MyText(
                                                  //                                                             text: '${(waitingTime / 60).toInt()} ${languages[choosenLanguage]['text_mins']}',
                                                  //                                                             size: media.width * twelve,
                                                  //                                                             color: isDarkTheme == true ? Colors.black : textColor,
                                                  //                                                           ),
                                                  //                                                         ],
                                                  //                                                       ),
                                                  //                                                     ],
                                                  //                                                   )
                                                  //                                                 : Container()
                                                  //                                             : Container(),
                                                  //                                   )
                                                  //                                 : Container()
                                                  //                             : (distTime != null && (driverReq['drop_address'] != null && driverReq['is_trip_start'] == 1))
                                                  //                                 ? Container(
                                                  //                                     margin: EdgeInsets.only(left: media.width * 0.02),
                                                  //                                     padding: EdgeInsets.only(left: media.width * 0.02, right: media.width * 0.02),
                                                  //                                     decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(media.width * 0.04)),
                                                  //                                     child: MyText(color: online, text: '${double.parse(((distTime * 2)).toString()).round()} ${languages[choosenLanguage]['text_mins']}', size: media.width * twelve),
                                                  //                                   )
                                                  //                                 : Container(),
                                                  //                       ],
                                                  //                     ),
                                                  //                     SizedBox(
                                                  //                       height:
                                                  //                           media.width * 0.05,
                                                  //                     ),
                                                  //                     Column(
                                                  //                         children: [
                                                  //                           Container(
                                                  //                             padding: EdgeInsets.all(media.width * 0.025),
                                                  //                             width: media.width * 0.9,
                                                  //                             color: borderLines.withOpacity(0.1),
                                                  //                             child: Column(
                                                  //                               crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                               children: [
                                                  //                                 Column(
                                                  //                                   crossAxisAlignment: CrossAxisAlignment.end,
                                                  //                                   children: [
                                                  //                                     SizedBox(
                                                  //                                       height: media.width * 0.02,
                                                  //                                     ),
                                                  //                                     Row(
                                                  //                                       children: [
                                                  //                                         if (driverReq['userDetail']['data']['profile_picture'] != null)
                                                  //                                           Container(
                                                  //                                             height: media.width * 0.15,
                                                  //                                             width: media.width * 0.15,
                                                  //                                             decoration: BoxDecoration(
                                                  //                                               shape: BoxShape.circle,
                                                  //                                               image: DecorationImage(
                                                  //                                                   image: NetworkImage(
                                                  //                                                     driverReq['userDetail']['data']['profile_picture'].toString(),
                                                  //                                                   ),
                                                  //                                                   fit: BoxFit.cover),
                                                  //                                             ),
                                                  //                                           ),
                                                  //                                         SizedBox(
                                                  //                                           width: media.width * 0.03,
                                                  //                                         ),
                                                  //                                         SizedBox(
                                                  //                                           height: media.width * 0.01,
                                                  //                                         ),
                                                  //                                         Expanded(
                                                  //                                           child: Column(
                                                  //                                             crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                             children: [
                                                  //                                               MyText(text: driverReq['userDetail']['data']['name'], size: media.width * sixteen, fontweight: FontWeight.w500),
                                                  //                                               SizedBox(
                                                  //                                                 height: media.width * 0.01,
                                                  //                                               ),
                                                  //                                               Row(
                                                  //                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                 children: [
                                                  //                                                   Icon(
                                                  //                                                     Icons.star,
                                                  //                                                     color: theme,
                                                  //                                                     size: media.width * 0.05,
                                                  //                                                   ),
                                                  //                                                   SizedBox(
                                                  //                                                     width: media.width * 0.005,
                                                  //                                                   ),
                                                  //                                                   Expanded(
                                                  //                                                     child: MyText(
                                                  //                                                       color: Colors.grey,
                                                  //                                                       text: (driverReq['userDetail']['data']['rating'] == 0) ? '0.0' : driverReq['userDetail']['data']['rating'].toString(),
                                                  //                                                       size: media.width * fourteen,
                                                  //                                                       fontweight: FontWeight.w600,
                                                  //                                                       maxLines: 1,
                                                  //                                                     ),
                                                  //                                                   ),
                                                  //                                                 ],
                                                  //                                               ),
                                                  //                                             ],
                                                  //                                           ),
                                                  //                                         ),
                                                  //                                       ],
                                                  //                                     ),
                                                  //                                   ],
                                                  //                                 ),
                                                  //                                 SizedBox(
                                                  //                                   height: media.width * 0.03,
                                                  //                                 ),
                                                  //                                 if (driverReq['is_trip_start'] != 1)
                                                  //                                   Row(
                                                  //                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  //                                     children: [
                                                  //                                       InkWell(
                                                  //                                         onTap: () async {
                                                  //                                           Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
                                                  //                                         },
                                                  //                                         child: Container(
                                                  //                                           // width: 275,
                                                  //                                           // height: 49,
                                                  //                                           width: media.width * 0.725,
                                                  //                                           height: media.width * 0.125,
                                                  //                                           decoration: BoxDecoration(color: boxColors, borderRadius: BorderRadius.circular(44)),
                                                  //                                           child: StreamBuilder(
                                                  //                                               stream: null,
                                                  //                                               builder: (context, snapshot) {
                                                  //                                                 return Row(
                                                  //                                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  //                                                   children: [
                                                  //                                                     SizedBox(
                                                  //                                                       width: media.width * 0.05,
                                                  //                                                     ),
                                                  //                                                     const Icon(
                                                  //                                                       Icons.message,
                                                  //                                                       color: Colors.grey,
                                                  //                                                     ),
                                                  //                                                     SizedBox(
                                                  //                                                       width: media.width * 0.025,
                                                  //                                                     ),
                                                  //                                                     Expanded(
                                                  //                                                       child: MyText(
                                                  //                                                         color: (chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).isNotEmpty) ? theme : Colors.grey,
                                                  //                                                         text: languages[choosenLanguage]['text_chatwithuser'],
                                                  //                                                         size: media.width * fourteen,
                                                  //                                                         fontweight: FontWeight.w400,
                                                  //                                                       ),
                                                  //                                                     ),
                                                  //                                                     if (chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).isNotEmpty)
                                                  //                                                       Row(
                                                  //                                                         children: [
                                                  //                                                           SizedBox(
                                                  //                                                             width: media.width * 0.025,
                                                  //                                                           ),
                                                  //                                                           MyText(
                                                  //                                                             text: chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).length.toString(),
                                                  //                                                             size: media.width * sixteen,
                                                  //                                                             fontweight: FontWeight.w500,
                                                  //                                                             color: theme,
                                                  //                                                           )
                                                  //                                                         ],
                                                  //                                                       ),
                                                  //                                                     SizedBox(
                                                  //                                                       width: media.width * 0.05,
                                                  //                                                     ),
                                                  //                                                   ],
                                                  //                                                 );
                                                  //                                               }),
                                                  //                                         ),
                                                  //                                       ),
                                                  //                                       // InkWell(
                                                  //                                       //   onTap: () {
                                                  //                                       //     makingPhoneCall(driverReq['userDetail']['data']['mobile']);
                                                  //                                       //   },
                                                  //                                       //   child: Container(
                                                  //                                       //     height: media.width * 0.096,
                                                  //                                       //     width: media.width * 0.096,
                                                  //                                       //     decoration: BoxDecoration(border: Border.all(color: const Color(0xff5BDD0A), width: 1), shape: BoxShape.circle),
                                                  //                                       //     alignment: Alignment.center,
                                                  //                                       //     child: Image.asset(
                                                  //                                       //       'assets/images/Call.png',
                                                  //                                       //       color: const Color(0xff5BDD0A),
                                                  //                                       //       height: media.width * 0.05,
                                                  //                                       //       width: media.width * 0.05,
                                                  //                                       //       fit: BoxFit.contain,
                                                  //                                       //     ),
                                                  //                                       //   ),
                                                  //                                       // ),
                                                  //                                     ],
                                                  //                                   ),

                                                  //                                 SizedBox(
                                                  //                                   height: media.width * 0.02,
                                                  //                                 ),
                                                  //                               ],
                                                  //                             ),
                                                  //                           ),
                                                  //                           SizedBox(
                                                  //                             height: media.width * 0.03,
                                                  //                           ),
                                                  //                           (driverReq['is_trip_start'] == 1)
                                                  //                               ? Container()
                                                  //                               : Row(
                                                  //                                   mainAxisAlignment: MainAxisAlignment.center,
                                                  //                                   children: [
                                                  //                                     InkWell(
                                                  //                                       onTap: () async {
                                                  //                                         setState(() {
                                                  //                                           _isLoading = true;
                                                  //                                         });
                                                  //                                         var val = await cancelReason((driverReq['is_driver_arrived'] == 0) ? 'before' : 'after');
                                                  //                                         if (val == true) {
                                                  //                                           setState(() {
                                                  //                                             cancelRequest = true;
                                                  //                                             _cancelReason = '';
                                                  //                                             _cancellingError = '';
                                                  //                                           });
                                                  //                                         }
                                                  //                                         setState(() {
                                                  //                                           _isLoading = false;
                                                  //                                         });
                                                  //                                       },
                                                  //                                       child: Row(
                                                  //                                         children: [
                                                  //                                           Image.asset(
                                                  //                                             'assets/images/cancelride.png',
                                                  //                                             height: media.width * 0.064,
                                                  //                                             width: media.width * 0.064,
                                                  //                                             fit: BoxFit.contain,
                                                  //                                             color: verifyDeclined,
                                                  //                                           ),
                                                  //                                           MyText(
                                                  //                                             text: languages[choosenLanguage]['text_cancel_booking'],
                                                  //                                             size: media.width * twelve,
                                                  //                                             color: verifyDeclined,
                                                  //                                           ),
                                                  //                                         ],
                                                  //                                       ),
                                                  //                                     ),
                                                  //                                   ],
                                                  //                                 ),

                                                  //                         ]),
                                                  //                     SizedBox(
                                                  //                       height:
                                                  //                           media.width * 0.03,
                                                  //                     ),
                                                  //                     (driverReq['transport_type'] == 'taxi')
                                                  //                         ? Button(
                                                  //                             onTap: () async {
                                                  //                               navigationtype = false;
                                                  //                               setState(() {
                                                  //                                 _isLoading = true;
                                                  //                               });
                                                  //                               if ((driverReq['is_driver_arrived'] == 0)) {
                                                  //                                 var val = await driverArrived();
                                                  //                                 if (val == 'logout') {
                                                  //                                   navigateLogout();
                                                  //                                 }
                                                  //                               } else if (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0) {
                                                  //                                 if (driverReq['show_otp_feature'] == true) {
                                                  //                                   setState(() {
                                                  //                                     _errorOtp = false;
                                                  //                                     getStartOtp = true;
                                                  //                                   });
                                                  //                                 } else {
                                                  //                                   var val = await tripStartDispatcher();
                                                  //                                   if (val == 'logout') {
                                                  //                                     navigateLogout();
                                                  //                                   }
                                                  //                                 }
                                                  //                               } else {
                                                  //                                 driverOtp = '';
                                                  //                                 var val = await endTrip();
                                                  //                                 if (val == 'logout') {
                                                  //                                   navigateLogout();
                                                  //                                 }
                                                  //                               }

                                                  //                               _isLoading = false;
                                                  //                             },
                                                  //                             text: (driverReq['is_driver_arrived'] == 0)
                                                  //                                 ? languages[choosenLanguage]['text_arrived']
                                                  //                                 : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                  //                                     ? languages[choosenLanguage]['text_startride']
                                                  //                                     : languages[choosenLanguage]['text_endtrip'])
                                                  //                         : Button(
                                                  //                             onTap: () async {
                                                  //                               navigationtype = false;
                                                  //                               setState(() {
                                                  //                                 _isLoading = true;
                                                  //                               });
                                                  //                               if ((driverReq['is_driver_arrived'] == 0)) {
                                                  //                                 var val = await driverArrived();
                                                  //                                 if (val == 'logout') {
                                                  //                                   navigateLogout();
                                                  //                                 }
                                                  //                               } else if (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0) {
                                                  //                                 if (driverReq['show_otp_feature'] == false && driverReq['enable_shipment_load_feature'].toString() == '0') {
                                                  //                                   var val = await tripStartDispatcher();
                                                  //                                   if (val == 'logout') {
                                                  //                                     navigateLogout();
                                                  //                                   }
                                                  //                                 } else {
                                                  //                                   setState(() {
                                                  //                                     shipLoadImage = null;
                                                  //                                     _errorOtp = false;
                                                  //                                     getStartOtp = true;
                                                  //                                   });
                                                  //                                 }
                                                  //                               } else {
                                                  //                                 if (driverReq['enable_shipment_unload_feature'].toString() == '1') {
                                                  //                                   setState(() {
                                                  //                                     unloadImage = true;
                                                  //                                   });
                                                  //                                 } else if (driverReq['enable_shipment_unload_feature'].toString() == '0' && driverReq['enable_digital_signature'].toString() == '1') {
                                                  //                                   Navigator.push(context, MaterialPageRoute(builder: (context) => const DigitalSignature()));
                                                  //                                 } else {
                                                  //                                   var val = await endTrip();
                                                  //                                   if (val == 'logout') {
                                                  //                                     navigateLogout();
                                                  //                                   }
                                                  //                                 }
                                                  //                               }

                                                  //                               _isLoading = false;
                                                  //                             },
                                                  //                             text: (driverReq['is_driver_arrived'] == 0)
                                                  //                                 ? languages[choosenLanguage]['text_arrived']
                                                  //                                 : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                  //                                     ? languages[choosenLanguage]['text_shipment_load']
                                                  //                                     : languages[choosenLanguage]['text_shipment_unload']),

                                                  //                     SizedBox(
                                                  //                       height:
                                                  //                           media.width * 0.05,
                                                  //                     ),
                                                  //                     Expanded(
                                                  //                       child:
                                                  //                           SingleChildScrollView(
                                                  //                         controller: _cont,
                                                  //                         physics: (addressBottom != null && addressBottom <= (media.height * 0.25)) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                                                  //                         child: Column(
                                                  //                           children: [
                                                  //                             if (driverReq['transport_type'] == 'delivery')
                                                  //                               Column(
                                                  //                                 children: [
                                                  //                                   SizedBox(
                                                  //                                     height: media.width * 0.02,
                                                  //                                   ),
                                                  //                                   SizedBox(
                                                  //                                     width: media.width * 0.9,
                                                  //                                     child: Text(
                                                  //                                       '${driverReq['goods_type']} - ${driverReq['goods_type_quantity']}',
                                                  //                                       style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: buttonColor),
                                                  //                                       textAlign: TextAlign.center,
                                                  //                                       maxLines: 2,
                                                  //                                       overflow: TextOverflow.ellipsis,
                                                  //                                     ),
                                                  //                                   ),
                                                  //                                   SizedBox(
                                                  //                                     height: media.width * 0.02,
                                                  //                                   ),
                                                  //                                 ],
                                                  //                               ),
                                                  //                             Column(
                                                  //                               children: addressList
                                                  //                                   .asMap()
                                                  //                                   .map((k, value) => MapEntry(
                                                  //                                       k,
                                                  //                                       (addressList[k].type == 'pickup')
                                                  //                                           ? Column(
                                                  //                                               crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                               children: [
                                                  //                                                 Container(
                                                  //                                                   width: media.width * 0.9,
                                                  //                                                   padding: EdgeInsets.all(media.width * 0.03),
                                                  //                                                   margin: EdgeInsets.only(bottom: media.width * 0.02),
                                                  //                                                   decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                  //                                                   child: Column(
                                                  //                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                     mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                     children: [
                                                  //                                                       Row(
                                                  //                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                         children: [
                                                  //                                                           Padding(
                                                  //                                                             padding: const EdgeInsets.all(4.0),
                                                  //                                                             child: Container(
                                                  //                                                               width: media.width * 0.05,
                                                  //                                                               height: media.width * 0.05,
                                                  //                                                               decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.4)),
                                                  //                                                               alignment: Alignment.center,
                                                  //                                                               child: Container(
                                                  //                                                                 width: media.width * 0.025,
                                                  //                                                                 height: media.width * 0.025,
                                                  //                                                                 decoration: const BoxDecoration(
                                                  //                                                                   shape: BoxShape.circle,
                                                  //                                                                   color: Colors.green,
                                                  //                                                                 ),
                                                  //                                                               ),
                                                  //                                                             ),
                                                  //                                                           ),
                                                  //                                                           SizedBox(
                                                  //                                                             width: media.width * 0.02,
                                                  //                                                           ),
                                                  //                                                           Expanded(
                                                  //                                                             child: Column(
                                                  //                                                               crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                               children: [
                                                  //                                                                 Row(
                                                  //                                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                                   children: [
                                                  //                                                                     MyText(
                                                  //                                                                       text: languages[choosenLanguage]['text_pick_up_location'],
                                                  //                                                                       size: media.width * fourteen,
                                                  //                                                                       fontweight: FontWeight.w600,
                                                  //                                                                       color: textColor,
                                                  //                                                                     ),
                                                  //                                                                   ],
                                                  //                                                                 ),
                                                  //                                                                 MyText(
                                                  //                                                                   color: greyText,
                                                  //                                                                   text: (addressList[k].type == 'pickup') ? addressList[k].address : 'nil',
                                                  //                                                                   size: media.width * twelve,
                                                  //                                                                   fontweight: FontWeight.normal,
                                                  //                                                                   maxLines: 5,
                                                  //                                                                 ),
                                                  //                                                               ],
                                                  //                                                             ),
                                                  //                                                           ),
                                                  //                                                         ],
                                                  //                                                       ),
                                                  //                                                     ],
                                                  //                                                   ),
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             )
                                                  //                                           : Container()))
                                                  //                                   .values
                                                  //                                   .toList(),
                                                  //                             ),
                                                  //                             Column(
                                                  //                                 children: addressList
                                                  //                                     .asMap()
                                                  //                                     .map((k, value) => MapEntry(
                                                  //                                         k,
                                                  //                                         (addressList[k].type == 'drop')
                                                  //                                             ? Column(
                                                  //                                                 children: [
                                                  //                                                   (k == addressList.length - 1)
                                                  //                                                       ? Container(
                                                  //                                                           width: media.width * 0.9,
                                                  //                                                           padding: EdgeInsets.all(media.width * 0.03),
                                                  //                                                           margin: EdgeInsets.only(bottom: media.width * 0.02),
                                                  //                                                           decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                  //                                                           child: Column(
                                                  //                                                             children: [
                                                  //                                                               Row(
                                                  //                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                                 children: [
                                                  //                                                                   Padding(
                                                  //                                                                     padding: const EdgeInsets.all(4.0),
                                                  //                                                                     child: Icon(
                                                  //                                                                       Icons.location_on,
                                                  //                                                                       size: media.width * 0.05,
                                                  //                                                                       color: const Color(0xffF52D56),
                                                  //                                                                     ),
                                                  //                                                                   ),
                                                  //                                                                   SizedBox(
                                                  //                                                                     width: media.width * 0.02,
                                                  //                                                                   ),
                                                  //                                                                   Expanded(
                                                  //                                                                     child: Column(
                                                  //                                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                                       children: [
                                                  //                                                                         Row(
                                                  //                                                                           mainAxisAlignment: MainAxisAlignment.start,
                                                  //                                                                           children: [
                                                  //                                                                             MyText(
                                                  //                                                                               text: languages[choosenLanguage]['text_droppoint'],
                                                  //                                                                               size: media.width * fourteen,
                                                  //                                                                               fontweight: FontWeight.w600,
                                                  //                                                                               color: textColor,
                                                  //                                                                             ),
                                                  //                                                                             // SizedBox(
                                                  //                                                                             //   width:
                                                  //                                                                             //       media.width * 0.53,
                                                  //                                                                             // ),
                                                  //                                                                             // Icon(
                                                  //                                                                             //   CupertinoIcons.heart_fill,
                                                  //                                                                             //   color:
                                                  //                                                                             //       Colors.white,
                                                  //                                                                             // )
                                                  //                                                                             // )
                                                  //                                                                           ],
                                                  //                                                                         ),
                                                  //                                                                         MyText(
                                                  //                                                                           color: greyText,
                                                  //                                                                           text: (addressList[k].type == 'drop') ? addressList[k].address : 'nil',
                                                  //                                                                           size: media.width * twelve,
                                                  //                                                                           fontweight: FontWeight.normal,
                                                  //                                                                           maxLines: 5,
                                                  //                                                                         ),
                                                  //                                                                       ],
                                                  //                                                                     ),
                                                  //                                                                   ),
                                                  //                                                                   if (driverReq['transport_type'] == 'delivery' && driverReq['is_trip_start'] == 1)
                                                  //                                                                     IconButton(
                                                  //                                                                         onPressed: () {
                                                  //                                                                           makingPhoneCall(addressList[k].number);
                                                  //                                                                         },
                                                  //                                                                         icon: const Icon(Icons.call))
                                                  //                                                                 ],
                                                  //                                                               ),
                                                  //                                                               if (driverReq['transport_type'] == 'delivery' && driverReq['is_trip_start'] == 0)
                                                  //                                                                 SizedBox(
                                                  //                                                                   height: media.width * 0.025,
                                                  //                                                                 ),
                                                  //                                                               if (addressList[k].instructions != null)
                                                  //                                                                 Column(
                                                  //                                                                   children: [
                                                  //                                                                     Row(
                                                  //                                                                       children: [
                                                  //                                                                         for (var i = 0; i < 50; i++)
                                                  //                                                                           Container(
                                                  //                                                                             margin: EdgeInsets.only(right: (i < 49) ? 2 : 0),
                                                  //                                                                             width: (media.width * 0.8 - 98) / 50,
                                                  //                                                                             height: 1,
                                                  //                                                                             color: borderColor,
                                                  //                                                                           )
                                                  //                                                                       ],
                                                  //                                                                     ),
                                                  //                                                                     SizedBox(
                                                  //                                                                       height: media.width * 0.015,
                                                  //                                                                     ),
                                                  //                                                                     Row(
                                                  //                                                                       children: [
                                                  //                                                                         MyText(
                                                  //                                                                           color: Colors.red,
                                                  //                                                                           text: languages[choosenLanguage]['text_instructions'] + ' :- ',
                                                  //                                                                           size: media.width * twelve,
                                                  //                                                                           fontweight: FontWeight.w600,
                                                  //                                                                           maxLines: 1,
                                                  //                                                                         ),
                                                  //                                                                       ],
                                                  //                                                                     ),
                                                  //                                                                     SizedBox(
                                                  //                                                                       height: media.width * 0.015,
                                                  //                                                                     ),
                                                  //                                                                     Row(
                                                  //                                                                       children: [
                                                  //                                                                         SizedBox(
                                                  //                                                                           width: media.width * 0.1,
                                                  //                                                                         ),
                                                  //                                                                         Expanded(
                                                  //                                                                           child: MyText(
                                                  //                                                                             color: greyText,
                                                  //                                                                             text: (addressList[k].type == 'drop') ? addressList[k].instructions : 'nil',
                                                  //                                                                             size: media.width * twelve,
                                                  //                                                                             fontweight: FontWeight.normal,
                                                  //                                                                             maxLines: 5,
                                                  //                                                                           ),
                                                  //                                                                         ),
                                                  //                                                                       ],
                                                  //                                                                     )
                                                  //                                                                   ],
                                                  //                                                                 ),
                                                  //                                                             ],
                                                  //                                                           ),
                                                  //                                                         )
                                                  //                                                       : Container(
                                                  //                                                           width: media.width * 0.9,
                                                  //                                                           padding: EdgeInsets.all(media.width * 0.03),
                                                  //                                                           margin: EdgeInsets.only(bottom: media.width * 0.02),
                                                  //                                                           decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                  //                                                           child: Column(
                                                  //                                                             children: [
                                                  //                                                               Row(
                                                  //                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                                 children: [
                                                  //                                                                   Container(
                                                  //                                                                     height: media.width * 0.05,
                                                  //                                                                     width: media.width * 0.05,
                                                  //                                                                     alignment: Alignment.center,
                                                  //                                                                     child: MyText(
                                                  //                                                                       text: (k).toString(),
                                                  //                                                                       size: media.width * fourteen,
                                                  //                                                                       color: verifyDeclined,
                                                  //                                                                       fontweight: FontWeight.w600,
                                                  //                                                                     ),
                                                  //                                                                   ),
                                                  //                                                                   SizedBox(
                                                  //                                                                     width: media.width * 0.02,
                                                  //                                                                   ),
                                                  //                                                                   Expanded(
                                                  //                                                                     child: Column(
                                                  //                                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                                                       children: [
                                                  //                                                                         MyText(
                                                  //                                                                           color: greyText,
                                                  //                                                                           text: (addressList[k].type == 'drop') ? addressList[k].address : 'nil',
                                                  //                                                                           size: media.width * twelve,
                                                  //                                                                           fontweight: FontWeight.normal,
                                                  //                                                                           maxLines: 5,
                                                  //                                                                         ),
                                                  //                                                                       ],
                                                  //                                                                     ),
                                                  //                                                                   ),
                                                  //                                                                   if (driverReq['transport_type'] == 'delivery' && driverReq['is_trip_start'] == 1)
                                                  //                                                                     IconButton(
                                                  //                                                                         onPressed: () {
                                                  //                                                                           makingPhoneCall(addressList[k].number);
                                                  //                                                                         },
                                                  //                                                                         icon: const Icon(Icons.call))
                                                  //                                                                 ],
                                                  //                                                               ),
                                                  //                                                               if (addressList[k].instructions != null)
                                                  //                                                                 Column(
                                                  //                                                                   children: [
                                                  //                                                                     Row(
                                                  //                                                                       children: [
                                                  //                                                                         for (var i = 0; i < 50; i++)
                                                  //                                                                           Container(
                                                  //                                                                             margin: EdgeInsets.only(right: (i < 49) ? 2 : 0),
                                                  //                                                                             width: (media.width * 0.8 - 98) / 50,
                                                  //                                                                             height: 1,
                                                  //                                                                             color: borderColor,
                                                  //                                                                           )
                                                  //                                                                       ],
                                                  //                                                                     ),
                                                  //                                                                     SizedBox(
                                                  //                                                                       height: media.width * 0.015,
                                                  //                                                                     ),
                                                  //                                                                     Row(
                                                  //                                                                       children: [
                                                  //                                                                         MyText(
                                                  //                                                                           color: Colors.red,
                                                  //                                                                           text: languages[choosenLanguage]['text_instructions'] + ' :- ',
                                                  //                                                                           size: media.width * twelve,
                                                  //                                                                           fontweight: FontWeight.w600,
                                                  //                                                                           maxLines: 1,
                                                  //                                                                         ),
                                                  //                                                                       ],
                                                  //                                                                     ),
                                                  //                                                                     SizedBox(
                                                  //                                                                       height: media.width * 0.015,
                                                  //                                                                     ),
                                                  //                                                                     Row(
                                                  //                                                                       children: [
                                                  //                                                                         SizedBox(
                                                  //                                                                           width: media.width * 0.1,
                                                  //                                                                         ),
                                                  //                                                                         Expanded(
                                                  //                                                                           child: MyText(
                                                  //                                                                             color: greyText,
                                                  //                                                                             text: (addressList[k].type == 'drop') ? addressList[k].instructions : 'nil',
                                                  //                                                                             size: media.width * twelve,
                                                  //                                                                             fontweight: FontWeight.normal,
                                                  //                                                                             maxLines: 5,
                                                  //                                                                           ),
                                                  //                                                                         ),
                                                  //                                                                       ],
                                                  //                                                                     )
                                                  //                                                                   ],
                                                  //                                                                 ),
                                                  //                                                             ],
                                                  //                                                           ),
                                                  //                                                         ),
                                                  //                                                 ],
                                                  //                                               )
                                                  //                                             : Container()))
                                                  //                                     .values
                                                  //                                     .toList()),
                                                  //                             SizedBox(
                                                  //                               height: media.width * 0.025,
                                                  //                             ),
                                                  //                             (driverReq['is_luggage_available'] == 1 || driverReq['is_pet_available'] == 1)
                                                  //                                 ? Column(
                                                  //                                     children: [
                                                  //                                       Row(
                                                  //                                         children: [
                                                  //                                           MyText(
                                                  //                                             text: languages[choosenLanguage]['text_ride_preference'] + ' :- ',
                                                  //                                             size: media.width * fourteen,
                                                  //                                             fontweight: FontWeight.w600,
                                                  //                                           ),
                                                  //                                           SizedBox(
                                                  //                                             width: media.width * 0.025,
                                                  //                                           ),
                                                  //                                           if (driverReq['is_pet_available'] == 1)
                                                  //                                             Row(
                                                  //                                               children: [
                                                  //                                                 Icon(Icons.pets, size: media.width * 0.05, color: theme),
                                                  //                                                 SizedBox(
                                                  //                                                   width: media.width * 0.01,
                                                  //                                                 ),
                                                  //                                                 MyText(
                                                  //                                                   text: languages[choosenLanguage]['text_pets'],
                                                  //                                                   size: media.width * fourteen,
                                                  //                                                   fontweight: FontWeight.w600,
                                                  //                                                   color: theme,
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             ),
                                                  //                                           if (driverReq['is_luggage_available'] == 1 && driverReq['is_pet_available'] == 1)
                                                  //                                             MyText(
                                                  //                                               text: ', ',
                                                  //                                               size: media.width * fourteen,
                                                  //                                               fontweight: FontWeight.w600,
                                                  //                                               color: theme,
                                                  //                                             ),
                                                  //                                           if (driverReq['is_luggage_available'] == 1)
                                                  //                                             Row(
                                                  //                                               children: [
                                                  //                                                 // Icon(Icons.luggage, size: media.width * 0.05, color: theme),
                                                  //                                                 SizedBox(
                                                  //                                                   height: media.width * 0.05,
                                                  //                                                   width: media.width * 0.075,
                                                  //                                                   child: Image.asset(
                                                  //                                                     'assets/images/luggages.png',
                                                  //                                                     color: theme,
                                                  //                                                   ),
                                                  //                                                 ),
                                                  //                                                 SizedBox(
                                                  //                                                   width: media.width * 0.01,
                                                  //                                                 ),
                                                  //                                                 MyText(
                                                  //                                                   text: languages[choosenLanguage]['text_luggages'],
                                                  //                                                   size: media.width * fourteen,
                                                  //                                                   fontweight: FontWeight.w600,
                                                  //                                                   color: theme,
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             ),
                                                  //                                         ],
                                                  //                                       ),
                                                  //                                       SizedBox(
                                                  //                                         height: media.width * 0.025,
                                                  //                                       ),
                                                  //                                     ],
                                                  //                                   )
                                                  //                                 : Container(),
                                                  //                             (driverReq['is_rental'] == false && driverReq['drop_address'] == null)
                                                  //                                 ? Container()
                                                  //                                 : Container(
                                                  //                                     width: media.width * 0.9,
                                                  //                                     padding: EdgeInsets.all(media.width * 0.05),
                                                  //                                     color: borderColor.withOpacity(0.1),
                                                  //                                     child: Column(
                                                  //                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                  //                                       children: [
                                                  //                                         MyText(
                                                  //                                           text: languages[choosenLanguage]['text_payingvia'],
                                                  //                                           size: media.width * sixteen,
                                                  //                                           fontweight: FontWeight.w600,
                                                  //                                           color: textColor,
                                                  //                                         ),
                                                  //                                         SizedBox(
                                                  //                                           height: media.width * 0.025,
                                                  //                                         ),
                                                  //                                         Row(
                                                  //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //                                           children: [
                                                  //                                             Expanded(
                                                  //                                               child: Row(
                                                  //                                                 children: [
                                                  //                                                   Image.asset(
                                                  //                                                     (driverReq['payment_opt'].toString() == '1')
                                                  //                                                         ? 'assets/images/cash.png'
                                                  //                                                         : (driverReq['payment_opt'].toString() == '2')
                                                  //                                                             ? 'assets/images/Wallet.png'
                                                  //                                                             : 'assets/images/card.png',
                                                  //                                                     width: media.width * 0.06,
                                                  //                                                   ),
                                                  //                                                   SizedBox(
                                                  //                                                     width: media.width * 0.02,
                                                  //                                                   ),
                                                  //                                                   MyText(
                                                  //                                                       text: (driverReq['payment_opt'].toString() == '1')
                                                  //                                                           ? languages[choosenLanguage]['text_cash']
                                                  //                                                           : (driverReq['payment_opt'].toString() == '2')
                                                  //                                                               ? languages[choosenLanguage]['text_wallet']
                                                  //                                                               : languages[choosenLanguage]['text_card'],
                                                  //                                                       size: media.width * fourteen,
                                                  //                                                       fontweight: FontWeight.w500)
                                                  //                                                 ],
                                                  //                                               ),
                                                  //                                             ),
                                                  //                                             SizedBox(
                                                  //                                               width: media.width * 0.02,
                                                  //                                             ),
                                                  //                                             Row(
                                                  //                                               mainAxisAlignment: MainAxisAlignment.end,
                                                  //                                               children: [
                                                  //                                                 SizedBox(
                                                  //                                                   width: media.width * 0.02,
                                                  //                                                 ),
                                                  //                                                 MyText(
                                                  //                                                   text: ((driverReq['is_bid_ride'] == 1)) ? '${driverReq['requested_currency_symbol']}${driverReq['accepted_ride_fare'].toStringAsFixed(0)}' : '${driverReq['requested_currency_symbol']}${driverReq['request_eta_amount'].toStringAsFixed(0)}',
                                                  //                                                   size: media.width * sixteen,
                                                  //                                                   fontweight: FontWeight.w600,
                                                  //                                                   color: textColor,
                                                  //                                                 ),
                                                  //                                               ],
                                                  //                                             ),
                                                  //                                           ],
                                                  //                                         ),
                                                  //                                       ],
                                                  //                                     ),
                                                  //                                   ),
                                                  //                             SizedBox(
                                                  //                               height: media.height * 0.25,
                                                  //                             ),
                                                  //                           ],
                                                  //                         ),
                                                  //                       ),
                                                  //                     )

                                                  //                   ],
                                                  //                 ),
                                                  //               ),

                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       )
                                                  //     : Container(),
                                                ],
                                              )
                                            : Container(),
                              ],
                            ),
                          ),
                          (_locationDenied == true)
                              ? Positioned(
                                  child: Container(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  color: Colors.transparent.withOpacity(0.6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: media.width * 0.9,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _locationDenied = false;
                                                });
                                              },
                                              child: Container(
                                                height: media.height * 0.05,
                                                width: media.height * 0.05,
                                                decoration: BoxDecoration(
                                                  color: page,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.cancel,
                                                    color: buttonColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: media.width * 0.025),
                                      Container(
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        width: media.width * 0.9,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: page,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 2.0,
                                                  spreadRadius: 2.0,
                                                  color: Colors.black
                                                      .withOpacity(0.2))
                                            ]),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                width: media.width * 0.8,
                                                child: Text(
                                                  languages[choosenLanguage][
                                                      'text_open_loc_settings'],
                                                  style: GoogleFonts.notoSans(
                                                      fontSize:
                                                          media.width * sixteen,
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )),
                                            SizedBox(
                                                height: media.width * 0.05),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                    onTap: () async {
                                                      await perm
                                                          .openAppSettings();
                                                    },
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_open_settings'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  buttonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    )),
                                                InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        _locationDenied = false;
                                                        _isLoading = true;
                                                      });

                                                      getLocs();
                                                    },
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          ['text_done'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  buttonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ))
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                              : Container(),
                          //enter otp
                          (getStartOtp == true &&
                                  driverReq.isNotEmpty &&
                                  driverReq['enable_shipment_load_feature']
                                          .toString() !=
                                      '1')
                              ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color: Colors.transparent.withOpacity(0.5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.8,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    getStartOtp = false;
                                                  });
                                                },
                                                child: Container(
                                                  height: media.height * 0.05,
                                                  width: media.height * 0.05,
                                                  decoration: BoxDecoration(
                                                    color: page,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.cancel,
                                                      color: buttonColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: media.width * 0.025),
                                        Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.05),
                                          width: media.width * 0.8,
                                          // height: media.width * 0.7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: page,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 2)
                                              ]),
                                          child: Column(
                                            children: [
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_driver_otp'],
                                                style: GoogleFonts.notoSans(
                                                    fontSize:
                                                        media.width * eighteen,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor),
                                              ),
                                              SizedBox(
                                                  height: media.width * 0.05),
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_enterdriverotp'],
                                                style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * twelve,
                                                  color: textColor
                                                      .withOpacity(0.7),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: media.width * 0.12,
                                                    color: page,
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length == 1) {
                                                          setState(() {
                                                            _otp1 = val;
                                                            driverOtp = _otp1 +
                                                                _otp2 +
                                                                _otp3 +
                                                                _otp4;
                                                            FocusScope.of(
                                                                    context)
                                                                .nextFocus();
                                                          });
                                                        }
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      maxLength: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: textColor),
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: media.width * 0.12,
                                                    color: page,
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length == 1) {
                                                          setState(() {
                                                            _otp2 = val;
                                                            driverOtp = _otp1 +
                                                                _otp2 +
                                                                _otp3 +
                                                                _otp4;
                                                            FocusScope.of(
                                                                    context)
                                                                .nextFocus();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            FocusScope.of(
                                                                    context)
                                                                .previousFocus();
                                                          });
                                                        }
                                                      },
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: textColor),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      maxLength: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: media.width * 0.12,
                                                    color: page,
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length == 1) {
                                                          setState(() {
                                                            _otp3 = val;
                                                            driverOtp = _otp1 +
                                                                _otp2 +
                                                                _otp3 +
                                                                _otp4;
                                                            FocusScope.of(
                                                                    context)
                                                                .nextFocus();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            FocusScope.of(
                                                                    context)
                                                                .previousFocus();
                                                          });
                                                        }
                                                      },
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: textColor),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      maxLength: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: media.width * 0.12,
                                                    color: page,
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length == 1) {
                                                          setState(() {
                                                            _otp4 = val;
                                                            driverOtp = _otp1 +
                                                                _otp2 +
                                                                _otp3 +
                                                                _otp4;
                                                            FocusScope.of(
                                                                    context)
                                                                .nextFocus();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            FocusScope.of(
                                                                    context)
                                                                .previousFocus();
                                                          });
                                                        }
                                                      },
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: textColor),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      maxLength: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: media.width * 0.04,
                                              ),
                                              (_errorOtp == true)
                                                  ? Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_error_trip_otp'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  media.width *
                                                                      twelve),
                                                    )
                                                  : Container(),
                                              SizedBox(
                                                  height: media.width * 0.02),
                                              Button(
                                                onTap: () async {
                                                  if (driverOtp.length != 4) {
                                                    setState(() {});
                                                  } else {
                                                    setState(() {
                                                      _errorOtp = false;
                                                      _isLoading = true;
                                                    });
                                                    var val = await tripStart();
                                                    if (val == 'logout') {
                                                      navigateLogout();
                                                    } else if (val !=
                                                        'success') {
                                                      setState(() {
                                                        _errorOtp = true;
                                                        _isLoading = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _isLoading = false;
                                                        getStartOtp = false;
                                                      });
                                                    }
                                                  }
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_confirm'],
                                                // color:
                                                //     (driverOtp.length != 4)
                                                //         ? Colors.grey
                                                //         : buttonColor,
                                                // borcolor:
                                                //     (driverOtp.length != 4)
                                                //         ? Colors.grey
                                                //         : buttonColor,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : (getStartOtp == true && driverReq.isNotEmpty)
                                  ? Positioned(
                                      top: 0,
                                      child: Container(
                                        height: media.height * 1,
                                        width: media.width * 1,
                                        padding: EdgeInsets.fromLTRB(
                                            media.width * 0.1,
                                            MediaQuery.of(context).padding.top +
                                                media.width * 0.05,
                                            media.width * 0.1,
                                            media.width * 0.05),
                                        color: page,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.8,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        getStartOtp = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      height:
                                                          media.height * 0.05,
                                                      width:
                                                          media.height * 0.05,
                                                      decoration: BoxDecoration(
                                                        color: page,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(Icons.cancel,
                                                          color: buttonColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: media.width * 0.025),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    (driverReq['show_otp_feature'] ==
                                                            true)
                                                        ? Column(children: [
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_driver_otp'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      eighteen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                            SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.05),
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_enterdriverotp'],
                                                              style: GoogleFonts
                                                                  .notoSans(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve,
                                                                color: textColor
                                                                    .withOpacity(
                                                                        0.7),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: media
                                                                          .width *
                                                                      0.12,
                                                                  color: page,
                                                                  child:
                                                                      TextFormField(
                                                                    onChanged:
                                                                        (val) {
                                                                      if (val.length ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          _otp1 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .nextFocus();
                                                                        });
                                                                      }
                                                                    },
                                                                    style: GoogleFonts.notoSans(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    maxLength:
                                                                        1,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    decoration: InputDecoration(
                                                                        counterText:
                                                                            '',
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: textColor,
                                                                                width: 1.5,
                                                                                style: BorderStyle.solid))),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: media
                                                                          .width *
                                                                      0.12,
                                                                  color: page,
                                                                  child:
                                                                      TextFormField(
                                                                    onChanged:
                                                                        (val) {
                                                                      if (val.length ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          _otp2 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .nextFocus();
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          _otp2 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .previousFocus();
                                                                        });
                                                                      }
                                                                    },
                                                                    style: GoogleFonts.notoSans(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    maxLength:
                                                                        1,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    decoration: InputDecoration(
                                                                        counterText:
                                                                            '',
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: textColor,
                                                                                width: 1.5,
                                                                                style: BorderStyle.solid))),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: media
                                                                          .width *
                                                                      0.12,
                                                                  color: page,
                                                                  child:
                                                                      TextFormField(
                                                                    onChanged:
                                                                        (val) {
                                                                      if (val.length ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          _otp3 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .nextFocus();
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          _otp3 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .previousFocus();
                                                                        });
                                                                      }
                                                                    },
                                                                    style: GoogleFonts.notoSans(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    maxLength:
                                                                        1,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    decoration: InputDecoration(
                                                                        counterText:
                                                                            '',
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: textColor,
                                                                                width: 1.5,
                                                                                style: BorderStyle.solid))),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: media
                                                                          .width *
                                                                      0.12,
                                                                  color: page,
                                                                  child:
                                                                      TextFormField(
                                                                    onChanged:
                                                                        (val) {
                                                                      if (val.length ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          _otp4 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .nextFocus();
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          _otp4 =
                                                                              val;
                                                                          driverOtp = _otp1 +
                                                                              _otp2 +
                                                                              _otp3 +
                                                                              _otp4;
                                                                          FocusScope.of(context)
                                                                              .previousFocus();
                                                                        });
                                                                      }
                                                                    },
                                                                    style: GoogleFonts.notoSans(
                                                                        color:
                                                                            textColor,
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    maxLength:
                                                                        1,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    decoration: InputDecoration(
                                                                        counterText:
                                                                            '',
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: textColor,
                                                                                width: 1.5,
                                                                                style: BorderStyle.solid))),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.04,
                                                            ),
                                                            (_errorOtp == true)
                                                                ? Text(
                                                                    languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_error_trip_otp'],
                                                                    style: GoogleFonts.notoSans(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve),
                                                                  )
                                                                : Container(),
                                                            SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.02),
                                                          ])
                                                        : Container(),
                                                    SizedBox(
                                                      width: media.width * 0.8,
                                                      child: Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_shipment_title'],
                                                        style: GoogleFonts
                                                            .notoSans(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: textColor,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            media.width * 0.02),
                                                    Container(
                                                        height:
                                                            media.width * 0.5,
                                                        width:
                                                            media.width * 0.5,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  borderLines,
                                                              width: 1.1),
                                                        ),
                                                        child:
                                                            (shipLoadImage ==
                                                                    null)
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      pickImageFromCamera(
                                                                          1);
                                                                    },
                                                                    child:
                                                                        Center(
                                                                      child: Text(
                                                                          languages[choosenLanguage]
                                                                              [
                                                                              'text_add_shipmentimage'],
                                                                          style: GoogleFonts.notoSans(
                                                                              fontSize: media.width *
                                                                                  twelve,
                                                                              color:
                                                                                  hintColor),
                                                                          textAlign:
                                                                              TextAlign.center),
                                                                    ),
                                                                  )
                                                                : InkWell(
                                                                    onTap: () {
                                                                      pickImageFromCamera(
                                                                          1);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          media.width *
                                                                              0.5,
                                                                      width: media
                                                                              .width *
                                                                          0.5,
                                                                      decoration: BoxDecoration(
                                                                          image: DecorationImage(
                                                                              image: FileImage(File(shipLoadImage)),
                                                                              fit: BoxFit.contain,
                                                                              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.dstATop))),
                                                                      child: Center(
                                                                          child: Text(
                                                                              languages[choosenLanguage]['text_edit_shipmentimage'],
                                                                              style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: textColor),
                                                                              textAlign: TextAlign.center)),
                                                                    ),
                                                                  )),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    (beforeImageUploadError !=
                                                            '')
                                                        ? SizedBox(
                                                            width: media.width *
                                                                0.9,
                                                            child: Text(
                                                                beforeImageUploadError,
                                                                style: GoogleFonts.notoSans(
                                                                    fontSize: media
                                                                            .width *
                                                                        sixteen,
                                                                    color: Colors
                                                                        .red),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: media.width * 0.02),
                                            Button(
                                              onTap: () async {
                                                if (driverReq[
                                                        'show_otp_feature'] ==
                                                    true) {
                                                  if (driverOtp.length != 4 ||
                                                      shipLoadImage == null) {
                                                    setState(() {});
                                                  } else {
                                                    setState(() {
                                                      _errorOtp = false;
                                                      beforeImageUploadError =
                                                          '';
                                                      _isLoading = true;
                                                    });
                                                    var upload =
                                                        await uploadLoadingImage(
                                                            shipLoadImage);
                                                    if (upload == 'success') {
                                                      var val =
                                                          await tripStart();
                                                      if (val == 'logout') {
                                                        navigateLogout();
                                                      } else if (val !=
                                                          'success') {
                                                        setState(() {
                                                          _errorOtp = true;
                                                          _isLoading = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _isLoading = false;
                                                          getStartOtp = false;
                                                        });
                                                      }
                                                    } else if (upload ==
                                                        'logout') {
                                                      navigateLogout();
                                                    } else {
                                                      setState(() {
                                                        beforeImageUploadError =
                                                            languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_somethingwentwrong'];
                                                        _isLoading = false;
                                                      });
                                                    }
                                                  }
                                                } else {
                                                  if (shipLoadImage == null) {
                                                    setState(() {});
                                                  } else {
                                                    setState(() {
                                                      _errorOtp = false;
                                                      beforeImageUploadError =
                                                          '';
                                                      _isLoading = true;
                                                    });
                                                    var upload =
                                                        await uploadLoadingImage(
                                                            shipLoadImage);
                                                    if (upload == 'success') {
                                                      var val =
                                                          await tripStartDispatcher();
                                                      if (val == 'logout') {
                                                        navigateLogout();
                                                      } else if (val !=
                                                          'success') {
                                                        setState(() {
                                                          _errorOtp = true;
                                                          _isLoading = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _isLoading = false;
                                                          getStartOtp = false;
                                                        });
                                                      }
                                                    } else if (upload ==
                                                        'logout') {
                                                      navigateLogout();
                                                    } else {
                                                      setState(() {
                                                        beforeImageUploadError =
                                                            languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_somethingwentwrong'];
                                                        _isLoading = false;
                                                      });
                                                    }
                                                  }
                                                }
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_confirm'],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),

                          //shipment unload image
                          (unloadImage == true)
                              ? Positioned(
                                  child: Container(
                                  height: media.height,
                                  width: media.width * 1,
                                  color: page,
                                  padding: EdgeInsets.fromLTRB(
                                      media.width * 0.05,
                                      MediaQuery.of(context).padding.top +
                                          media.width * 0.05,
                                      media.width * 0.05,
                                      media.width * 0.05),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: media.width * 0.8,
                                        child: Stack(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: media.width * 0.05,
                                                    right: media.width * 0.05),
                                                alignment: Alignment.center,
                                                // color:Colors.red,
                                                height: media.width * 0.15,
                                                width: media.width * 0.9,
                                                child: Text(
                                                  languages[choosenLanguage]
                                                      ['text_unload_title'],
                                                  style: GoogleFonts.notoSans(
                                                      color: textColor,
                                                      fontSize: media.width *
                                                          eighteen),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                )),
                                            Positioned(
                                              right: 0,
                                              top: media.width * 0.025,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    unloadImage = false;
                                                  });
                                                },
                                                child: Container(
                                                  height: media.width * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                    color: page,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.cancel,
                                                      color: buttonColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Container(
                                                height: media.width * 0.5,
                                                width: media.width * 0.5,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.1),
                                                ),
                                                child: (shipUnloadImage == null)
                                                    ? InkWell(
                                                        onTap: () {
                                                          pickImageFromCamera(
                                                              2);
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                              languages[choosenLanguage]
                                                                  [
                                                                  'text_add_unloadImage'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  color:
                                                                      hintColor),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () {
                                                          pickImageFromCamera(
                                                              2);
                                                        },
                                                        child: Container(
                                                          height:
                                                              media.width * 0.5,
                                                          width:
                                                              media.width * 0.5,
                                                          decoration:
                                                              BoxDecoration(

                                                                  // color: Colors.transparent.withOpacity(0.4),
                                                                  image: DecorationImage(
                                                                      image: FileImage(
                                                                          File(
                                                                              shipUnloadImage)),
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      colorFilter: ColorFilter.mode(
                                                                          Colors
                                                                              .white
                                                                              .withOpacity(0.5),
                                                                          BlendMode.dstATop))),
                                                          child: Center(
                                                              child: Text(
                                                                  languages[choosenLanguage]
                                                                      [
                                                                      'text_edit_unloadimage'],
                                                                  style: GoogleFonts.notoSans(
                                                                      fontSize:
                                                                          media.width *
                                                                              twelve,
                                                                      color:
                                                                          textColor),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center)),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                  height: media.width * 0.05),
                                              (afterImageUploadError != '')
                                                  ? SizedBox(
                                                      width: media.width * 0.9,
                                                      child: Text(
                                                          afterImageUploadError,
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color: Colors
                                                                      .red),
                                                          textAlign:
                                                              TextAlign.center),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      ),
                                      (shipUnloadImage != null)
                                          ? Button(
                                              onTap: () async {
                                                setState(() {
                                                  _isLoading = true;
                                                  afterImageUploadError = '';
                                                });
                                                var val =
                                                    await uploadUnloadingImage(
                                                        shipUnloadImage);
                                                if (val == 'success') {
                                                  if (driverReq[
                                                              'enable_digital_signature']
                                                          .toString() ==
                                                      '1') {
                                                    navigate();
                                                  } else {
                                                    var val = await endTrip();
                                                    if (val == 'logout') {
                                                      navigateLogout();
                                                    }
                                                  }
                                                } else if (val == 'logout') {
                                                  navigateLogout();
                                                } else {
                                                  setState(() {
                                                    afterImageUploadError =
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_somethingwentwrong'];
                                                  });
                                                }
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              },
                                              text: 'Upload')
                                          : Container()
                                    ],
                                  ),
                                ))
                              : Container(),

                          //permission denied popup
                          (_permission != '')
                              ? Positioned(
                                  child: Container(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  color: Colors.transparent.withOpacity(0.6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: media.width * 0.9,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _permission = '';
                                                });
                                              },
                                              child: Container(
                                                height: media.width * 0.1,
                                                width: media.width * 0.1,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: page),
                                                child: Icon(
                                                    Icons.cancel_outlined,
                                                    color: textColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        width: media.width * 0.9,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: page,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 2.0,
                                                  spreadRadius: 2.0,
                                                  color: Colors.black
                                                      .withOpacity(0.2))
                                            ]),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                width: media.width * 0.8,
                                                child: Text(
                                                  languages[choosenLanguage][
                                                      'text_open_camera_setting'],
                                                  style: GoogleFonts.notoSans(
                                                      fontSize:
                                                          media.width * sixteen,
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )),
                                            SizedBox(
                                                height: media.width * 0.05),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                    onTap: () async {
                                                      await perm
                                                          .openAppSettings();
                                                    },
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_open_settings'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  buttonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    )),
                                                InkWell(
                                                    onTap: () async {
                                                      // pickImageFromCamera();
                                                      setState(() {
                                                        _permission = '';
                                                      });
                                                    },
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          ['text_done'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  buttonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ))
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                              : Container(),

                          //popup for cancel request
                          (cancelRequest == true && driverReq.isNotEmpty)
                              ? Positioned(
                                  child: Container(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  color: Colors.transparent.withOpacity(0.6),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        width: media.width * 0.9,
                                        decoration: BoxDecoration(
                                            color: page,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Column(children: [
                                          //CAMBIAR IDIOMA
                                          Text(
                                            'Cancelar llamada',
                                            style: GoogleFonts.montserrat(
                                                color: newRedColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Column(
                                            children: cancelReasonsList
                                                .asMap()
                                                .map((i, value) {
                                                  return MapEntry(
                                                      i,
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _cancelReason =
                                                                cancelReasonsList[
                                                                        i]
                                                                    ['reason'];
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.01),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: media
                                                                        .height *
                                                                    0.05,
                                                                width: media
                                                                        .width *
                                                                    0.05,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color:
                                                                            newRedColor,
                                                                        width:
                                                                            1.2)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: (_cancelReason ==
                                                                        cancelReasonsList[i]
                                                                            [
                                                                            'reason'])
                                                                    ? Container(
                                                                        height: media.width *
                                                                            0.03,
                                                                        width: media.width *
                                                                            0.03,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          color:
                                                                              newRedColor,
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    0.65,
                                                                child: MyText(
                                                                  fontweight:
                                                                      FontWeight
                                                                          .bold,
                                                                  text: cancelReasonsList[
                                                                          i][
                                                                      'reason'],
                                                                  size: media
                                                                          .width *
                                                                      twelve,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                                })
                                                .values
                                                .toList(),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _cancelReason = 'others';
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.01),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: media.height * 0.05,
                                                    width: media.width * 0.05,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: newRedColor,
                                                            width: 1.2)),
                                                    alignment: Alignment.center,
                                                    child: (_cancelReason ==
                                                            'others')
                                                        ? Container(
                                                            height:
                                                                media.width *
                                                                    0.03,
                                                            width: media.width *
                                                                0.03,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  newRedColor,
                                                            ),
                                                          )
                                                        : Container(),
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.05,
                                                  ),
                                                  MyText(
                                                    fontweight: FontWeight.bold,
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_others'],
                                                    size: media.width * twelve,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),

                                          (_cancelReason == 'others')
                                              ? Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0,
                                                      media.width * 0.025,
                                                      0,
                                                      media.width * 0.025),
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  width: media.width * 0.9,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: borderLines,
                                                          width: 1.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_cancelRideReason'],
                                                        hintStyle: GoogleFonts
                                                            .notoSans(
                                                                fontSize: media
                                                                        .width *
                                                                    twelve)),
                                                    maxLines: 4,
                                                    minLines: 2,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        cancelReasonText = val;
                                                      });
                                                    },
                                                  ),
                                                )
                                              : Container(),
                                          (_cancellingError != '')
                                              ? Container(
                                                  padding: EdgeInsets.only(
                                                      top: media.width * 0.02,
                                                      bottom: media.width *
                                                          0.02),
                                                  width: media.width * 0.9,
                                                  child: Text(_cancellingError,
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      twelve,
                                                              color:
                                                                  Colors.red)))
                                              : Container(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Button(
                                                  height: media.height * 0.045,
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  textcolor: Colors.white,
                                                  borcolor: Colors.grey
                                                      .withOpacity(0.5),
                                                  width: media.width * 0.39,
                                                  onTap: () async {
                                                    setState(() {
                                                      cancelRequest = false;
                                                    });
                                                  },
                                                  text: 'Atras'),
                                              Button(
                                                  height: media.height * 0.045,
                                                  color: newRedColor,
                                                  textcolor: Colors.white,
                                                  borcolor: newRedColor,
                                                  width: media.width * 0.39,
                                                  onTap: () async {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    if (_cancelReason != '') {
                                                      if (_cancelReason ==
                                                          'others') {
                                                        if (cancelReasonText !=
                                                                '' &&
                                                            cancelReasonText
                                                                .isNotEmpty) {
                                                          _cancellingError = '';
                                                          var val =
                                                              await cancelRequestDriver(
                                                                  cancelReasonText);
                                                          if (val == 'logout') {
                                                            navigateLogout();
                                                          }
                                                          setState(() {
                                                            cancelRequest =
                                                                false;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            _cancellingError =
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_add_cancel_reason'];
                                                          });
                                                        }
                                                      } else {
                                                        var val =
                                                            await cancelRequestDriver(
                                                                _cancelReason);
                                                        if (val == 'logout') {
                                                          navigateLogout();
                                                        }
                                                        setState(() {
                                                          cancelRequest = false;
                                                        });
                                                      }
                                                    }
                                                    setState(() {
                                                      _isLoading = false;
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
                                                    });
                                                  },
                                                  text: 'Confirmar')
                                            ],
                                          )
                                        ]),
                                      ),
                                    ],
                                  ),
                                ))
                              : Container(),

                          //loader
                          (state == '')
                              ? const Positioned(top: 0, child: Loading())
                              : Container(),

                          //logout popup
                          (logout == true)
                              ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color: Colors.transparent.withOpacity(0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  height: media.height * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: page),
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          logout = false;
                                                        });
                                                      },
                                                      child: const Icon(Icons
                                                          .cancel_outlined))),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.05),
                                          width: media.width * 0.9,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: page),
                                          child: Column(
                                            children: [
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_confirmlogout'],
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.notoSans(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: textColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Button(
                                                  onTap: () async {
                                                    if (userDetails['active'] ==
                                                        true) {
                                                      var val =
                                                          await driverStatus();
                                                      if (val == 'logout') {
                                                        navigateLogout();
                                                      }
                                                    }
                                                    setState(() {
                                                      _isLoading = true;
                                                      logout = false;
                                                    });
                                                    var result =
                                                        await userLogout();
                                                    if (result == 'success') {
                                                      setState(() {
                                                        navigateLogout();
                                                        userDetails.clear();
                                                      });
                                                    } else if (result ==
                                                        'logout') {
                                                      navigateLogout();
                                                    } else {
                                                      setState(() {
                                                        logout = true;
                                                      });
                                                    }
                                                  },
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_confirm'])
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                              : Container(),

                          //waiting time popup
                          (_showWaitingInfo == true)
                              ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color: Colors.transparent.withOpacity(0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  height: media.height * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: page),
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _showWaitingInfo =
                                                              false;
                                                        });
                                                      },
                                                      child: const Icon(Icons
                                                          .cancel_outlined))),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.05),
                                          width: media.width * 0.9,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: page),
                                          child: Column(
                                            children: [
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_waiting_time_1'],
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.notoSans(
                                                    fontSize:
                                                        media.width * sixteen,
                                                    color: textColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_waiting_time_2'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  textColor)),
                                                  Text(
                                                      '${driverReq['free_waiting_time_in_mins_before_trip_start']} ${languages[choosenLanguage]['text_mins']}',
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      languages[choosenLanguage]
                                                          [
                                                          'text_waiting_time_3'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  textColor)),
                                                  Text(
                                                      '${driverReq['free_waiting_time_in_mins_after_trip_start']} ${languages[choosenLanguage]['text_mins']}',
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                              : Container(),

                          //no internet
                          (internet == false)
                              ? Positioned(
                                  top: 0,
                                  child: NoInternet(
                                    onTap: () {
                                      setState(() {
                                        internetTrue();
                                        getUserDetails();
                                      });
                                    },
                                  ))
                              : Container(),

                          //sos popup
                          (showSos == true)
                              ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color: Colors.transparent.withOpacity(0.6),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.7,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      notifyCompleted = false;
                                                      showSos = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: media.width * 0.1,
                                                    width: media.width * 0.1,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: page),
                                                    child: const Icon(
                                                        Icons.cancel_outlined),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            height: media.height * 0.5,
                                            width: media.width * 0.7,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: page),
                                            child: SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          notifyCompleted =
                                                              false;
                                                        });
                                                        var val =
                                                            await notifyAdmin();
                                                        if (val == true) {
                                                          setState(() {
                                                            notifyCompleted =
                                                                true;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width * 0.05),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_notifyadmin'],
                                                                  style: GoogleFonts.notoSans(
                                                                      fontSize:
                                                                          media.width *
                                                                              sixteen,
                                                                      color:
                                                                          textColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                (notifyCompleted ==
                                                                        true)
                                                                    ? Container(
                                                                        padding:
                                                                            EdgeInsets.only(top: media.width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          languages[choosenLanguage]
                                                                              [
                                                                              'text_notifysuccess'],
                                                                          style:
                                                                              GoogleFonts.notoSans(
                                                                            fontSize:
                                                                                media.width * twelve,
                                                                            color:
                                                                                const Color(0xff319900),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container()
                                                              ],
                                                            ),
                                                            const Icon(Icons
                                                                .notification_add)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    (sosData.isNotEmpty)
                                                        ? Column(
                                                            children: sosData
                                                                .asMap()
                                                                .map(
                                                                    (i, value) {
                                                                  return MapEntry(
                                                                      i,
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          makingPhoneCall(sosData[i]['number'].toString().replaceAll(
                                                                              ' ',
                                                                              ''));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              EdgeInsets.all(media.width * 0.05),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: media.width * 0.4,
                                                                                    child: Text(
                                                                                      sosData[i]['name'],
                                                                                      style: GoogleFonts.notoSans(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.01,
                                                                                  ),
                                                                                  Text(
                                                                                    sosData[i]['number'],
                                                                                    style: GoogleFonts.notoSans(
                                                                                      fontSize: media.width * twelve,
                                                                                      color: textColor,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                              const Icon(Icons.call)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ));
                                                                })
                                                                .values
                                                                .toList(),
                                                          )
                                                        : Container(
                                                            width: media.width *
                                                                0.7,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_noDataFound'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      eighteen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                          )
                                                  ],
                                                )),
                                          )
                                        ]),
                                  ))
                              : Container(),

                          //choose option for seeing location on map while having multiple stops
                          (_tripOpenMap == true)
                              ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color: Colors.transparent.withOpacity(0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _tripOpenMap = false;
                                                  });
                                                },
                                                child: Container(
                                                  height: media.width * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: page),
                                                  child: Icon(
                                                    Icons.cancel_outlined,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Container(
                                            width: media.width * 0.9,
                                            padding: EdgeInsets.fromLTRB(
                                                media.width * 0.02,
                                                media.width * 0.05,
                                                media.width * 0.02,
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: page),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: media.width * 0.8,
                                                  child: Text(
                                                    languages[choosenLanguage][
                                                        'text_choose_address_nav'],
                                                    style: GoogleFonts.notoSans(
                                                        fontSize: media.width *
                                                            sixteen,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.03,
                                                ),
                                                SizedBox(
                                                  height: media.height * 0.2,
                                                  child: SingleChildScrollView(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    child: Column(
                                                      children: tripStops
                                                          .asMap()
                                                          .map((i, value) {
                                                            return MapEntry(
                                                                i,
                                                                Container(
                                                                  // width: media.width*0.5,
                                                                  padding: EdgeInsets
                                                                      .all(media
                                                                              .width *
                                                                          0.025),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          tripStops[i]
                                                                              [
                                                                              'address'],
                                                                          style: GoogleFonts.notoSans(
                                                                              fontSize: media.width * fourteen,
                                                                              color: textColor,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.01,
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          openMap(
                                                                              tripStops[i]['latitude'],
                                                                              tripStops[i]['longitude']);
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              media.width * 00.08,
                                                                          child: Image.asset(
                                                                              'assets/images/googlemaps.png',
                                                                              width: media.width * 0.05,
                                                                              fit: BoxFit.contain),
                                                                        ),
                                                                      ),
                                                                      (userDetails['enable_vase_map'] ==
                                                                              '1')
                                                                          ? SizedBox(
                                                                              width: media.width * 0.02,
                                                                            )
                                                                          : Container(),
                                                                      (userDetails['enable_vase_map'] ==
                                                                              '1')
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                openWazeMap(tripStops[i]['latitude'], tripStops[i]['longitude']);
                                                                              },
                                                                              child: SizedBox(
                                                                                width: media.width * 00.1,
                                                                                child: Image.asset('assets/images/waze.png', width: media.width * 0.05, fit: BoxFit.contain),
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                    ],
                                                                  ),
                                                                ));
                                                          })
                                                          .values
                                                          .toList(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ))
                              : Container(),
                          (_showToast == true)
                              ? Positioned(
                                  top: media.height * 0.2,
                                  child: Container(
                                    width: media.width * 0.9,
                                    margin: EdgeInsets.all(media.width * 0.05),
                                    padding:
                                        EdgeInsets.all(media.width * 0.025),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: page),
                                    child: Text(
                                      'Route Poly line is not available in demo',
                                      style: GoogleFonts.poppins(
                                          fontSize: media.width * twelve,
                                          color: textColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ))
                              : Container(),
                          //loader
                          (_isLoading == true)
                              ? const Positioned(top: 0, child: Loading())
                              : Container(),
                          //pickup marker
                          Positioned(
                            top: media.height * 1.5,
                            left: 100,
                            child: RepaintBoundary(
                                key: iconKey,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                (isDarkTheme == true)
                                                    ? const Color(0xff000000)
                                                    : const Color(0xffFFFFFF),
                                                (isDarkTheme == true)
                                                    ? const Color(0xff808080)
                                                    : const Color(0xffEFEFEF),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      width: media.width * 0.5,
                                      padding: const EdgeInsets.all(5),
                                      child: (driverReq.isNotEmpty &&
                                              driverReq['pick_address'] != null)
                                          ? MyText(
                                              text: driverReq['pick_address'],
                                              size: media.width * twelve,
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                            )
                                          : (choosenRide.isNotEmpty)
                                              ? MyText(
                                                  text: choosenRide[0]
                                                      ['pick_address'],
                                                  size: media.width * twelve,
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 1,
                                                )
                                              : Container(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/pick_icon.png'),
                                              fit: BoxFit.contain)),
                                      height: media.width * 0.07,
                                      width: media.width * 0.08,
                                    )
                                  ],
                                )),
                          ),
                          //drop marker
                          Positioned(
                              top: media.height * 2.5,
                              left: 100,
                              child: Column(
                                children: [
                                  (tripStops.isNotEmpty)
                                      ? Column(
                                          children: tripStops
                                              .asMap()
                                              .map((i, value) {
                                                iconDropKeys[i] = GlobalKey();
                                                return MapEntry(
                                                  i,
                                                  RepaintBoundary(
                                                      key: iconDropKeys[i],
                                                      child: Column(
                                                        children: [
                                                          (i <=
                                                                  tripStops
                                                                          .length -
                                                                      2)
                                                              ? Column(
                                                                  children: [
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Text(
                                                                        (i + 1)
                                                                            .toString(),
                                                                        style: GoogleFonts.notoSans(
                                                                            fontSize: media.width *
                                                                                sixteen,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.red),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  ],
                                                                )
                                                              : (i ==
                                                                      tripStops
                                                                              .length -
                                                                          1)
                                                                  ? Column(
                                                                      children: [
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                              gradient: LinearGradient(colors: [
                                                                                (isDarkTheme == true) ? const Color(0xff000000) : const Color(0xffFFFFFF),
                                                                                (isDarkTheme == true) ? const Color(0xff808080) : const Color(0xffEFEFEF),
                                                                              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                                                              borderRadius: BorderRadius.circular(5)),
                                                                          width:
                                                                              media.width * 0.5,
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              5),
                                                                          child: (driverReq.isNotEmpty && driverReq['drop_address'] != null)
                                                                              ? Text(driverReq['drop_address'],
                                                                                  maxLines: 1,
                                                                                  style: GoogleFonts.notoSans(
                                                                                    fontSize: media.width * ten,
                                                                                  ))
                                                                              : (choosenRide.isNotEmpty && choosenRide[0]['drop_address'] != null)
                                                                                  ? Text(
                                                                                      choosenRide[choosenRide.length - 1]['drop_address'],
                                                                                      maxLines: 1,
                                                                                      style: GoogleFonts.notoSans(
                                                                                        fontSize: media.width * ten,
                                                                                      ),
                                                                                      overflow: TextOverflow.fade,
                                                                                    )
                                                                                  : Container(),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              image: DecorationImage(image: AssetImage('assets/images/drop_icon.png'), fit: BoxFit.contain)),
                                                                          height:
                                                                              media.width * 0.07,
                                                                          width:
                                                                              media.width * 0.08,
                                                                        )
                                                                      ],
                                                                    )
                                                                  : Container(),
                                                        ],
                                                      )),
                                                );
                                              })
                                              .values
                                              .toList(),
                                        )
                                      : Container(),
                                ],
                              )),

                          //drop marker
                          Positioned(
                            top: media.height * 2.5,
                            left: 100,
                            child: Column(
                              children: [
                                RepaintBoundary(
                                    key: iconDropKey,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    (isDarkTheme == true)
                                                        ? const Color(
                                                            0xff000000)
                                                        : const Color(
                                                            0xffFFFFFF),
                                                    (isDarkTheme == true)
                                                        ? const Color(
                                                            0xff808080)
                                                        : const Color(
                                                            0xffEFEFEF),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          width: media.width * 0.5,
                                          padding: const EdgeInsets.all(5),
                                          child: (driverReq.isNotEmpty &&
                                                  driverReq['drop_address'] !=
                                                      null)
                                              ? MyText(
                                                  text:
                                                      driverReq['drop_address'],
                                                  size: media.width * ten,
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 1,
                                                )
                                              : (choosenRide.isNotEmpty &&
                                                      choosenRide[0][
                                                              'drop_address'] !=
                                                          null)
                                                  ? MyText(
                                                      text: choosenRide[0]
                                                          ['drop_address'],
                                                      size: media.width * ten,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      maxLines: 1,
                                                    )
                                                  : Container(),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/drop_icon.png'),
                                                  fit: BoxFit.contain)),
                                          height: media.width * 0.07,
                                          width: media.width * 0.08,
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          (isOverLayPermission &&
                                  Theme.of(context).platform ==
                                      TargetPlatform.android)
                              ? Positioned(
                                  child: Container(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  color: Colors.black.withOpacity(0.2),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        // height: media.width * 0.5,
                                        width: media.width * 0.9,
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              media.width * 0.05),
                                          color: page,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            MyText(
                                              text:
                                                  "Permitir la superposicion para aparecer encima de otras aplicaciones",
                                              // "Please Allow Overlay Permisson for Appear on the Other Apps",
                                              size: media.width * sixteen,
                                              textAlign: TextAlign.center,
                                              fontweight: FontWeight.bold,
                                            ),
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isOverLayPermission =
                                                          false;
                                                    });
                                                    pref.setBool(
                                                        'isOverlaypermission',
                                                        isOverLayPermission);
                                                  },
                                                  child: SizedBox(
                                                    width: media.width * 0.3,
                                                    child: MyText(
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_decline'],
                                                      size:
                                                          media.width * sixteen,
                                                      color: verifyDeclined,
                                                      fontweight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        isOverLayPermission =
                                                            false;
                                                      });
                                                      log('TODO: FM - Activando Buble');
                                                      // DashBubble.instance.requestOverlayPermission();
                                                    },
                                                    child: MyText(
                                                      text: languages[
                                                              choosenLanguage][
                                                          'text_open_settings'],
                                                      textAlign: TextAlign.end,
                                                      size:
                                                          media.width * sixteen,
                                                      color: online,
                                                      fontweight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                              : Container(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double getBearing(LatLng begin, LatLng end) {
    // double lat = (begin.latitude - end.latitude).abs();

    // double lng = (begin.longitude - end.longitude).abs();

    // if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
    //   return vector.degrees(atan(lng / lat));
    // } else if (begin.latitude >= end.latitude &&
    //     begin.longitude < end.longitude) {
    //   return (90 - vector.degrees(atan(lng / lat))) + 90;
    // } else if (begin.latitude >= end.latitude &&
    //     begin.longitude >= end.longitude) {
    //   return vector.degrees(atan(lng / lat)) + 180;
    // } else if (begin.latitude < end.latitude &&
    //     begin.longitude >= end.longitude) {
    //   return (90 - vector.degrees(atan(lng / lat))) + 270;
    // }

    return -1;
  }

  animateCar(
      double fromLat, //Starting latitude

      double fromLong, //Starting longitude

      double toLat, //Ending latitude

      double toLong, //Ending longitude

      StreamSink<List<Marker>>
          mapMarkerSink, //Stream build of map to update the UI

      TickerProvider
          provider, //Ticker provider of the widget. This is used for animation

      GoogleMapController controller, //Google map controller of our widget

      markerid,
      icon,
      name,
      number) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    dynamic carMarker;
    if (name == '' && number == '') {
      carMarker = Marker(
          markerId: MarkerId(markerid),
          position: LatLng(fromLat, fromLong),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          draggable: false);
    } else {
      carMarker = Marker(
          markerId: MarkerId(markerid),
          position: LatLng(fromLat, fromLong),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: number, snippet: name),
          flat: true,
          draggable: false);
    }

    myMarkers.add(carMarker);

    mapMarkerSink.add(Set<Marker>.from(myMarkers).toList());

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        myMarkers
            .removeWhere((element) => element.markerId == MarkerId(markerid));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location

        if (name == '' && number == '') {
          carMarker = Marker(
              markerId: MarkerId(markerid),
              position: newPos,
              icon: icon,
              anchor: const Offset(0.5, 0.5),
              flat: true,
              rotation: bearing,
              draggable: false);
        } else {
          carMarker = Marker(
              markerId: MarkerId(markerid),
              position: newPos,
              icon: icon,
              infoWindow: InfoWindow(title: number, snippet: name),
              anchor: const Offset(0.5, 0.5),
              flat: true,
              rotation: bearing,
              draggable: false);
        }

        //Adding new marker to our list and updating the google map UI.

        myMarkers.add(carMarker);

        mapMarkerSink.add(Set<Marker>.from(myMarkers).toList());
      });

    //Starting the animation

    animationController.forward();

    if (driverReq.isEmpty || driverReq['is_trip_start'] == 1) {
      controller.getVisibleRegion().then((value) {
        if (value.contains(myMarkers
            .firstWhere((element) => element.markerId == MarkerId(markerid))
            .position)) {
        } else {
          controller.animateCamera(CameraUpdate.newLatLng(centerPosition!));
        }
      });
    }
    animationController = null;
  }
}

dynamic distTime;

class OwnerCarImagecontainer extends StatelessWidget {
  final String imgurl;
  final String text;
  final Color color;
  final void Function()? ontap;
  const OwnerCarImagecontainer(
      {Key? key,
      required this.imgurl,
      required this.text,
      required this.ontap,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return InkWell(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(
          media.width * 0.01,
        ),
        width: media.width * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage(imgurl), fit: BoxFit.contain)),
              height: media.width * 0.07,
              width: media.width * 0.15,
            ),
            Container(
              height: media.width * 0.03,
              width: media.width * 0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }
}

List decodeEncodedPolyline(String encoded) {
  // List poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    fmpoly.add(
      fmlt.LatLng(p.latitude, p.longitude),
    );
  }
  return fmpoly;
}
