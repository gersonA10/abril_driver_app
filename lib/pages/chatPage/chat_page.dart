import 'dart:async';

import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/pages/chatPage/send_message.dart';
import 'package:abril_driver_app/pages/login/landingpage.dart';
import 'package:abril_driver_app/pages/login/login.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/utils/my_logger.dart';
import 'header_chat_widget.dart';
import 'list_chat_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController controller = ScrollController();
  Timer? _chatUpdateTimer;
  String? requestID; // Ahora es nullable
   @override
  void initState() {
    super.initState();
    
    // Validar si userDetails y onTripRequest existen antes de asignar requestID
    if (userDetails != null && userDetails['onTripRequest'] != null) {
      requestID = userDetails['onTripRequest']['data']['id'];
    }

    if (requestID != null) {
      _chatUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        // getCurrentMessages();
      });
    } else {
      Mylogger.printWithTime("❌ No hay requestID, no se inician actualizaciones del chat.");
    }
  }

  @override
  void dispose() {
    _chatUpdateTimer?.cancel();
    super.dispose();
  }


  // getMessages() async {
  //   var val = await getCurrentMessages();
  //   if (val == 'logout') {
  //     navigateLogout();
  //   }
  // }

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
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
     // 🔹 Si no hay requestID, mostrar un mensaje y evitar el error
    if (requestID == null) {
      Navigator.pop(context);
      return Scaffold(
        backgroundColor: theme,
        body: Center(
          child: Text(
            "Esta conversación ya no está disponible",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }
    return PopScope(
      canPop: true,
      child: Material(
        // rtl and ltr
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme,
            body: ValueListenableBuilder(
              valueListenable: valueNotifierHome.value,
              builder: (context, value, child) {
                Mylogger.printWithTime('Chatpage value notifier home $value');
                WidgetsBinding.instance.addPostFrameCallback((_) {
  if (controller.hasClients) {
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
});

                //api call for message seen
                // messageSeen();

                return Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  // color: theme,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                      // theme,
                      const Color.fromARGB(255, 195, 13, 0),
                      theme,
                      // theme.withOpacity(0.5)/s/s``
                    ],),
                    image: DecorationImage(image: AssetImage('assets/images/icon_new.png'), opacity: 0.3)
                  ),
                  child: Column(
                    children: [
                      HeaderChatWidget(
                        userName: driverReq['userDetail']['data']['name'],
                        profilePicture: driverReq['userDetail']['data']
                            ['profile_picture'],
                      ),
                      Expanded(
                        child: ListChatWidget(controller: controller, requestID: requestID!,),
                      ),
                      SendMessage(
                        onLogout: () => navigateLogout(),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
