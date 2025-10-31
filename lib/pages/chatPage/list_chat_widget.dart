import 'dart:async';
import 'dart:convert'; // Importar para json.decode
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:map_launcher/map_launcher.dart'; // Importar para abrir mapas
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

    // Desplazarse al fondo una vez que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.hasClients) {
        widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
      }
    });
  }

  void _listenToMessages() {
    _messagesSubscription = _messagesRef
        .child('requests/${widget.requestID}/array_mensajes')
        .orderByKey()
        .limitToLast(20)
        .onChildAdded
        .listen((event) {
      if (!mounted || event.snapshot.value == null) return;

      Map<String, dynamic> msg =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      if (msg["estado"] == "enviado" && msg["origen"] == "cliente") {
        _messagesRef
            .child(
                'requests/${widget.requestID}/array_mensajes/${event.snapshot.key}')
            .update({"estado": "visto"});
      }

      // Auto-scroll al fondo solo si se añade un nuevo mensaje
      // Se hace con un pequeño retraso para asegurar que el ListView se actualice
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.controller.hasClients) {
          widget.controller.animateTo(
            widget.controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
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

  Widget _buildLocationButton(
      BuildContext context, dynamic contenido, bool isClientMessage) {
    Map<String, dynamic> locationData;
    double lat;
    double lng;

    try {
      if (contenido is String) {
        locationData = json.decode(contenido);
      } else if (contenido is Map) {
        locationData = Map<String, dynamic>.from(contenido);
      } else {
        return Text("Error: Ubicación inválida",
            style: TextStyle(color: Colors.red));
      }

      lat = (locationData['lat'] as num).toDouble();
      lng = (locationData['lng'] as num).toDouble();
    } catch (e) {
      return Text("Error: Ubicación mal formada",
          style: TextStyle(color: Colors.red));
    }

    final coords = Coords(lat, lng);
    // Define colores basados en quién envía
    Color buttonColor = isClientMessage ? Colors.white : theme;
    Color iconColor = isClientMessage ? theme : Colors.white;

    return InkWell(
      onTap: () async {
        try {
          final availableMaps = await MapLauncher.installedMaps;
          if (availableMaps.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No hay aplicaciones de mapas instaladas.')),
            );
            return;
          }

          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Abrir ubicación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ...availableMaps.map((map) {
                      return ListTile(
                        title: Text(map.mapName),
                        onTap: () async {
                          Navigator.pop(context);
                          await map.showMarker(
                            coords: coords,
                            title: 'Ubicación compartida',
                            description: '',
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        } catch (e) {
          debugPrint('Error al abrir el mapa: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              "Ver Ubicación",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- FIN DEL NUEVO WIDGET ---

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return StreamBuilder(
      stream: _messagesRef
          .child('requests/${widget.requestID}/array_mensajes')
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text(''));
        }

        List<dynamic> messages = snapshot.data!.snapshot.value as List<dynamic>;
        messages = messages.where((msg) => msg != null).toList();

        // [FIX 1: Se eliminó el bloque `isNearBottom` que forzaba el scroll]

        // [FIX 2: Reemplazado SingleChildScrollView+Column por ListView.builder]
        return ListView.builder(
          controller: widget.controller,
          itemCount: messages.length, // Usar el conteo de mensajes
          itemBuilder: (context, index) {
            // Construir cada item por su índice
            final message = messages[index];
            bool isClientMessage = message['origen'] == "cliente";

            return Container(
              // padding: EdgeInsets.only(top: media.width * 0.025),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: media.width * 0.9,
              alignment:
                  isClientMessage ? Alignment.centerLeft : Alignment.centerRight,
              child: Column(
                crossAxisAlignment: isClientMessage
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
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
                          vertical: (message['tipo'] == 'imagen' ||
                                  message['tipo'] == 'ubicacion') // Añadido 'ubicacion'
                              ? 0
                              : 14,
                          horizontal: (message['tipo'] == 'imagen' ||
                                  message['tipo'] == 'ubicacion') // Añadido 'ubicacion'
                              ? 0
                              : 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: isClientMessage
                              ? Radius.zero
                              : Radius.circular(20),
                          topRight: isClientMessage
                              ? Radius.circular(20)
                              : Radius.zero,
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: isClientMessage
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white,
                      ),
                      // --- [INICIO DE CAMBIOS PARA TASK 2] ---
                      child: message['tipo'] == 'audio'
                          ? AudioMessageWidget(url: message['contenido'])
                          : message['tipo'] == 'imagen'
                              ? Container(
                                  width: 250,
                                  height: 250,
                                  padding: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(message['contenido'],
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : message['tipo'] == 'ubicacion' // NUEVO CASO
                                  ? _buildLocationButton(
                                      context,
                                      message['contenido'],
                                      isClientMessage)
                                  : Text(
                                      // CASO POR DEFECTO (TEXTO)
                                      message['contenido'],
                                      style: TextStyle(
                                        fontSize: media.width * 0.04,
                                        fontWeight: FontWeight.w600,
                                        color: isClientMessage
                                            ? Colors.white
                                            : theme,
                                      ),
                                    ),
                      // --- [FIN DE CAMBIOS PARA TASK 2] ---
                    ),
                  ),
                  SizedBox(height: media.width * 0.015),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (message['hora_envio'] ?? '').split(":").take(2).join(":"),
                        style: TextStyle(
                            fontSize: media.width * 0.03,
                            color: Color.fromARGB(255, 169, 169, 169)),
                      ),
                      SizedBox(width: 5),
                      if (!isClientMessage)
                        getMessageStatusIcon(message['estado']),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}