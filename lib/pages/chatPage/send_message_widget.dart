// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:abril_driver_app/functions/chat_audio_service.dart';
// import 'package:abril_driver_app/functions/functions.dart';
// import 'package:abril_driver_app/styles/styles.dart';
// import 'package:abril_driver_app/translation/translation.dart';
// import 'package:abril_driver_app/utils/my_logger.dart';
// import 'package:abril_driver_app/widgets/widgets.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:record/record.dart';

// import 'audio_icon_widget.dart';

// class SendMessageWidget extends StatefulWidget {
//   const SendMessageWidget({
//     super.key,
//     required this.onLogout,
//   });

//   final VoidCallback onLogout;

//   @override
//   State<SendMessageWidget> createState() => _SendMessageWidgetState();
// }

// class _SendMessageWidgetState extends State<SendMessageWidget> {
//   final ImagePicker _picker = ImagePicker();
//   TextEditingController chatText = TextEditingController();
//   final audioService = ChatAudioService();
//   bool showSendTextButton = false;
//   late AudioRecorder record;
//   bool isRecording = false;
//   bool isLoading = false; // Nuevo estado para el loader

//   Future<void> selectImage() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Galería'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   await _pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Cámara'),
//                 onTap: () async {
//                   Navigator.of(context).pop();
//                   await _pickImage(ImageSource.camera);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         isLoading = true; // Mostrar el loader
//       });

//       final result = await audioService.sendImageMessage(pickedFile.path);

//       setState(() {
//         isLoading = false; // Ocultar el loader
//       });

//       if (result == 'logout') {
//         widget.onLogout();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.sizeOf(context);

//     return Stack(
//       children: [
//         Container(
//           margin: EdgeInsets.only(top: media.width * 0.025),
//           width: media.width * 0.9,
//           child: Stack(
//             clipBehavior: Clip.antiAlias,
//             children: [
//               SizedBox(
//                 width: media.width * (showSendTextButton ? 1 : 0.7),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: borderLines, width: 1.2),
//                           color: page,
//                         ),
//                         child: MyTextField(
//                           hinttext: languages[choosenLanguage]['text_entermessage'],
//                           textController: chatText,
//                           fontsize: media.width * twelve,
//                           maxline: null,
//                           contentpadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                           ),
//                           onTap: (val) {
//                             showSendTextButton = val is String && val.isNotEmpty;
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Visibility(
//                       visible: showSendTextButton,
//                       child: GestureDetector(
//                         onTap: () async {
//                           setState(() {
//                             isLoading = true; // Mostrar el loader
//                           });

//                           String messageText = chatText.text;
//                           chatText.clear();
//                           final val = await sendMessage(messageText);

//                           setState(() {
//                             isLoading = false; // Ocultar el loader
//                           });

//                           if (val == 'logout') {
//                             widget.onLogout();
//                           }
//                           showSendTextButton = false;
//                           setState(() {});
//                         },
//                         child: CircleAvatar(
//                           radius: 24,
//                           backgroundColor: const Color(0xff484848),
//                           child: Transform.rotate(
//                             angle: -pi / 4,
//                             child: Image.asset(
//                               'assets/images/send.png',
//                               color: Colors.white,
//                               width: media.width * 0.090,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.image),
//                       onPressed: selectImage,
//                     ),
//                   ],
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomRight,
//                 child: SizedBox(
//                   width: media.width * 0.8,
//                   child: Visibility(
//                     visible: !showSendTextButton,
//                     child: AudioIconWidget(
//                       onStart: () => startRecording(),
//                       onEnd: () => stopRecording(),
//                       onCancel: () => cancelRecording(),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (isLoading)
//           Positioned.fill(
//             child: Container(
//               height: 300,
//               width: 200,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//               color: Colors.black.withOpacity(0.5),

//               ),
//               child: const Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text('Enviando...', style: TextStyle(color: Colors.white),),
//                     SizedBox(width: 30,),
//                     CircularProgressIndicator(
//                       color: Colors.white,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Future<void> startRecording() async {
//     record = AudioRecorder();
//     final hasPermission = await record.hasPermission();
//     final dirPath = await downloadPath();
//     final path = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.m4a';
//     Mylogger.print('Path recording $path');
//     if (hasPermission) {
//       await record.start(
//         const RecordConfig(),
//         path: path,
//       );
//       isRecording = true;
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error permission')),
//         );
//       }
//     }
//   }

//   Future<void> stopRecording() async {
//     if (isRecording) {
//       chatText.clear();
//       final path = await record.stop();
//       isRecording = false;
//       Mylogger.print('Path recorded $path');
//       final resp = await audioService.sendAudioMessage(path!);
//       if (resp == 'logout') {
//         widget.onLogout();
//       }
//       await record.dispose();
//     }
//   }

//   Future<void> cancelRecording() async {
//     if (isRecording) {
//       chatText.clear();
//       await record.cancel();
//       isRecording = false;
//       await record.dispose();
//     }
//   }

//   Future<String> downloadPath() async {
//     return '/storage/emulated/0/Download';
//   }
// }
