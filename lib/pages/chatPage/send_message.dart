import 'dart:io';

import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/chat_audio_service.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'dart:async';

class SendMessage extends StatefulWidget {
  const SendMessage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  bool hasRecordPermission = false;

  bool isLoadingMessage = false;
  final TextEditingController chatText = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _recorder = AudioRecorder();
  bool isRecording = false;
   final audioService = ChatAudioService();
  bool showSendButton = false;
  Timer? _recordingTimer;

@override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    final granted = await _recorder.hasPermission();
    setState(() {
      hasRecordPermission = granted;
    });
  }

    Future<void> selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

    Future<void> _pickImage(ImageSource source) async {

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        isLoadingMessage = true; // Mostrar el loader
      });

      final result = await audioService.sendImageMessage(pickedFile.path);

      setState(() {
        isLoadingMessage = false; // Ocultar el loader
      });

      if (result == 'logout') {
        widget.onLogout();
      }
    }
  }

Future<void> startRecording() async {
    if (!hasRecordPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se otorgó permiso para grabar audio')),
      );
      return;
    }

    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(),
      path: filePath,
    );

    setState(() => isRecording = true);

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }



  Future<void> stopRecording() async {
    if (isRecording) {
      final path = await _recorder.stop();
      _recordingTimer?.cancel();
      setState(() => isRecording = false);
      // Llamar al servicio para enviar audio
      final resp = await audioService.sendAudioMessage(path!);
      if (resp == 'logout') {
        widget.onLogout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Text('data'),
        if (isLoadingMessage == true) const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enviando...', style: TextStyle(color: Colors.white),),
            SizedBox(width: 10,),
            CircularProgressIndicator(color: Colors.white,)
          ],
        ),
        Container(
          margin: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo_library, color: theme),
                onPressed: selectImage,
              ),
              SizedBox(
                width: showSendButton ? size.width * 0.52 : size.width * 0.65,
                child: TextField(
                  controller: chatText,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    hintStyle: const TextStyle(color: Colors.black),
                    hintText: isRecording ? "Grabando audio..." : "Escribe un mensaje",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (text) {
                    setState(() => showSendButton = text.isNotEmpty);
                  },
                ),
              ),
              // SizedBox(width: showSendButton ? 50 : 20,),
              const Spacer(),
              !showSendButton 
               ? GestureDetector(
                    onLongPress: startRecording,
                    onLongPressUp: stopRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isRecording ? 60 : 40,
                      height: isRecording ? 60 : 40,
                      decoration: BoxDecoration(
                        color: isRecording ? Colors.green : theme,
                        shape: BoxShape.circle,
                        boxShadow: isRecording
                            ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 24),
                    ),
                  )
                : const SizedBox.shrink(),
              showSendButton
                  ? GestureDetector(
                      onTap: () async {
                        String message = chatText.text;
                        setState(() => isLoadingMessage = true);
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            chatText.clear();
                            isLoadingMessage = false;
                            showSendButton = false;
                          });
                        });
                         final val = await sendMessage(message);
                         
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: theme,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    )
                  : const SizedBox.shrink(),
               const SizedBox(
                width: 5,
              )
            ],
          ),
        ),
      ],
    );
  }
}
