import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:abril_driver_app/functions/functions.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:abril_driver_app/translation/translation.dart';
import 'package:abril_driver_app/widgets/widgets.dart';

class OnlineOfflineWidget extends StatelessWidget {
  const OnlineOfflineWidget({
    super.key,
    required this.media,
  });

  final ui.Size media;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: media.width * 0.01, right: media.width * 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(media.width * 0.04),
        color: (userDetails['active'] == false)
            ? const Color(0xff707070).withOpacity(0.6)
            : const ui.Color.fromARGB(255, 184, 1, 1),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: media.height * 0.003),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(media.width * 0.04),
        ),
        child: (userDetails['active'] == false)
        ? Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration:  const BoxDecoration(
                    image: DecorationImage(
                      scale: 2,
                      image: AssetImage('assets/images/offline.png',)),
                  color: Colors.white,
                  shape: BoxShape.circle
                  ),
                  height: media.width * 0.05,
                  width: media.width * 0.05,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MyText(
                  text: languages[choosenLanguage]['text_on_duty'],
                  size:  media.width * 0.038,
                  color: (isDarkTheme == true)
                      ? textColor.withOpacity(0.7)
                      : Colors.white,
              ),
            ),
          ],
        ) 
        : Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MyText(
                  text: languages[choosenLanguage]['text_off_duty'],
                    size:  media.width * 0.038,
                  color: (isDarkTheme == true)
                      ? textColor.withOpacity(0.7)
                      : Colors.white,
              ),
            ),
            Container(
              height: media.width * 0.05,
              width: media.width * 0.05,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: onlineOfflineText),
              child: Image.asset('assets/images/offline.png',
                  color: const ui.Color.fromARGB(255, 184, 1, 1),
                ),
            ),
          ],
        ),
      )
    );
  }
}
