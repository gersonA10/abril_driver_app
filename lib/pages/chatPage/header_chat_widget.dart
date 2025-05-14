import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderChatWidget extends StatefulWidget {
  const HeaderChatWidget(
      {super.key, required this.userName, required this.profilePicture});

  final String userName;
  final String profilePicture;

  @override
  State<HeaderChatWidget> createState() => _HeaderChatWidgetState();
}

class _HeaderChatWidgetState extends State<HeaderChatWidget> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return Container(
      margin: EdgeInsets.only(top: media.height * 0.055),
      height: media.height * 0.06,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.c,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isInChatPage = false;
              });
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.profilePicture),
            radius: 24,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.userName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    // Stack(
    //   children: [
    // Container(
    //   height: media.height * 0.14,
    // ),
    //     Positioned(
    //       left: 16,
    //       top: 60,
    //       child: Row(
    //         children: [
    //           GestureDetector(
    //             onTap: () {
    //               Navigator.pop(context);
    //               setState(() {
    //                 isInChatPage = false;
    //               });
    //             },
    //             child: Icon(
    //               Icons.arrow_back,
    //               color: Colors.white,
    //             ),
    //           ),
    //           CircleAvatar(
    //             backgroundImage: NetworkImage(widget.profilePicture),
    //             radius: 24,
    //           ),
    //           SizedBox(width: 10),
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 widget.userName,
    //                 style: GoogleFonts.poppins(
    //                   color: Colors.white,
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}
