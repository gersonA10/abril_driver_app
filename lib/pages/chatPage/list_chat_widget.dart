import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'audio_message_widget.dart';
import 'image_view_screen.dart';

class ListChatWidget extends StatefulWidget {
  const ListChatWidget({
    super.key,
    required this.controller,
    required this.requestID,
  });

  final ScrollController controller;
  final String requestID;

  @override
  State<ListChatWidget> createState() => _ListChatWidgetState();
}

class _ListChatWidgetState extends State<ListChatWidget> {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref();
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

void _listenToMessages() {
  _messagesSubscription = _messagesRef
      .child('requests/${widget.requestID}/array_mensajes')
      .orderByKey()
      .limitToLast(20)
      .onChildAdded
      .listen((event) {
    if (!mounted || event.snapshot.value == null) return;

    Map<String, dynamic> msg = Map<String, dynamic>.from(event.snapshot.value as Map);

    if (msg["estado"] == "enviado" && msg["origen"] == "cliente") {
      _messagesRef
          .child('requests/${widget.requestID}/array_mensajes/${event.snapshot.key}')
          .update({"estado": "visto"});
    }
  });
}


   @override
  void dispose() {
    _messagesSubscription?.cancel(); 
    super.dispose();
  }

  Widget getMessageStatusIcon(String estado) {
    switch (estado) {
      case "enviado":
        return Icon(Icons.done_all, color: Colors.grey, size: 16); // ✅ Gris
      case "recibido":
        return Icon(Icons.done_all, color: Colors.grey, size: 16); // ✅✅ Gris
      case "visto":
        return Icon(Icons.done_all, color: Colors.blue, size: 16); // ✅✅ Azul
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return StreamBuilder(
      stream: _messagesRef.child('requests/${widget.requestID}/array_mensajes').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Center(child: Text(''));
        }

        List<dynamic> messages = snapshot.data!.snapshot.value as List<dynamic>;
        messages = messages.where((msg) => msg != null).toList(); 

        return SingleChildScrollView(
          controller: widget.controller,
          child: Column(
            children: messages.map((message) {
              bool isClientMessage = message['origen'] == "cliente";

              return Container(
                padding: EdgeInsets.only(top: media.width * 0.025),
                width: media.width * 0.9,
                alignment: isClientMessage ? Alignment.centerLeft : Alignment.centerRight,
                child: Column(
                  crossAxisAlignment:
                      isClientMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (message['tipo'] == 'imagen') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewScreen(
                                imageUrl: message['contenido'],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: (message['tipo'] == 'imagen') ? 0 : 14,
                            horizontal: (message['tipo'] == 'imagen') ? 0 : 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: isClientMessage ? Radius.zero : Radius.circular(20),
                            topRight: isClientMessage ? Radius.circular(20) : Radius.zero,
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: isClientMessage ? Colors.white.withOpacity(0.3) : Colors.white,
                        ),
                        child: message['tipo'] == 'audio'
                            ? AudioMessageWidget(url: message['contenido'])
                            : message['tipo'] == 'imagen'
                                ? Container(
                                    width: 250,
                                    height: 250,
                                    padding: EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(message['contenido'], fit: BoxFit.cover),
                                    ),
                                  )
                                : Text(
                                    message['contenido'],
                                    style: TextStyle(
                                      fontSize: media.width * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: isClientMessage ? Colors.white : theme,
                                    ),
                                  ),
                      ),
                    ),
                    SizedBox(height: media.width * 0.015),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (message['hora_envio'] ?? '').split(":").take(2).join(":"),
                          style: TextStyle(fontSize: media.width * 0.03, color: Color.fromARGB(255, 169, 169, 169)),
                        ),
                        SizedBox(width: 5),
                        if (!isClientMessage) getMessageStatusIcon(message['estado']),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
