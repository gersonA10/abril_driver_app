import 'package:flutter/material.dart';
import 'package:abril_driver_app/pages/login/login.dart';
import 'package:abril_driver_app/pages/onTripPage/map_page.dart';
import 'package:abril_driver_app/widgets/fast_review_buttons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/landingpage.dart';
import '../noInternet/nointernet.dart';
import 'rides.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

double review = 0.0;
String feedback = '';
String comments = '';
String fastTags = '';

class _ReviewState extends State<Review> {
    List<String> options = [
    'Muy amable',
    'Es Puntual',
    'Ensució el vehículo',
    'Descortés'
  ];

  List<bool> selectedOptions = [false, false, false, false];

  bool _loading = false;

  @override
  void initState() {
    review = 0.0;
    super.initState();
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

//navigate
  navigate() {
    if (userDetails['role'] != 'owner' &&
        userDetails['enable_bidding'] == true) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RidePage()),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Maps()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Stack(
                children: [
                  Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    padding: EdgeInsets.all(media.width * 0.05),
                    color: page,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: media.width * 0.1,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              (driverReq.isNotEmpty)
                                  ? Container(
                                      height: media.width * 0.2,
                                      width: media.width * 0.2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                driverReq['userDetail']['data']
                                                    ['profile_picture']),
                                            fit: BoxFit.cover),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: media.height * 0.03,
                              ),
                              MyText(
                                text: (driverReq.isNotEmpty)
                                    ? driverReq['userDetail']['data']['name']
                                    : '',
                                size: media.width * sixteen,
                              ),
                              SizedBox(
                                height: media.height * 0.02,
                              ),
                               Padding(
                                padding: EdgeInsets.symmetric(horizontal: media.width * 0.06 , vertical: media.height * 0.02),
                                child: const Divider(),
                              ),
                              //stars
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          review = 1.0;
                                        });
                                      },
                                      child: Icon(
                                        Icons.star,
                                        size: media.width * 0.1,
                                        color: (review >= 1)
                                            ? starsColor
                                            : Colors.grey,
                                      )),
                                  SizedBox(
                                    width: media.width * 0.02,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          review = 2.0;
                                        });
                                      },
                                      child: Icon(
                                        Icons.star,
                                        size: media.width * 0.1,
                                        color: (review >= 2)
                                            ? starsColor
                                            : Colors.grey,
                                      )),
                                  SizedBox(
                                    width: media.width * 0.02,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          review = 3.0;
                                        });
                                      },
                                      child: Icon(
                                        Icons.star,
                                        size: media.width * 0.1,
                                        color: (review >= 3)
                                            ? starsColor
                                            : Colors.grey,
                                      )),
                                  SizedBox(
                                    width: media.width * 0.02,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          review = 4.0;
                                        });
                                      },
                                      child: Icon(
                                        Icons.star,
                                        size: media.width * 0.1,
                                        color: (review >= 4)
                                            ? starsColor
                                            : Colors.grey,
                                      )),
                                  SizedBox(
                                    width: media.width * 0.02,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          review = 5.0;
                                        });
                                      },
                                      child: Icon(
                                        Icons.star,
                                        size: media.width * 0.1,
                                        color: (review == 5)
                                            ? starsColor
                                            : Colors.grey,
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: media.height * 0.05,
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: FastButtonsReview(options: options, selectedOptions: selectedOptions,),
                              ),
                              //feedbact textfield
                              Container(
                                height: media.height * 0.22,
                                padding: EdgeInsets.symmetric(horizontal: media.width * 0.06),
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1.5,
                                        color: isDarkTheme == true
                                            ? Colors.grey
                                            : Colors.grey.withOpacity(0.5),),),
                                child: TextField(
                                  maxLines: 4,
                                  onChanged: (val) {
                                    setState(() {
                                      feedback = val;
                                    });
                                  },
                                  style: GoogleFonts.notoSans(color: textColor),
                                  decoration: InputDecoration(
                                      hintText: languages[choosenLanguage]
                                          ['text_feedback'],
                                      hintStyle: GoogleFonts.notoSans(
                                          color: isDarkTheme == true
                                              ? textColor.withOpacity(0.4)
                                              : Colors.grey.withOpacity(0.6)),
                                      border: InputBorder.none),
                                ),
                              ),
                               SizedBox(
                                height: media.height * 0.05,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: media.width * 0.06 ),
                                child: const Divider(),
                              ),
                              SizedBox(
                                height: media.height * 0.05,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: (review >= 1.0)
                                  ? (isDarkTheme)
                                      ? Colors.white
                                      : newRedColor
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            fastTags = getSelectedOptions();

                            comments = '$feedback $fastTags';
                            
                            if (review >= 1.0) {
                              setState(() {
                                _loading = true;
                              });
                              // var result = await userRating(comments);

                              // if (result == true) {
                              //  pref.remove('requestId');
                              //   _loading = false;
                              //   navigate();
                              // } else if (result == 'logout') {
                              //   navigateLogout();
                              // } else {
                              //   setState(() {
                              //     _loading = false;
                              //   });
                              // }
                            }
                          },
                          child: Text(
                            languages[choosenLanguage]['text_submit'],
                            style: GoogleFonts.montserrat(color: page, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ),

                  //no internet
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(
                            onTap: () {
                              setState(() {
                                internetTrue();
                              });
                            },
                          ))
                      : Container(),

                  //loader
                  (_loading == true)
                      ? const Positioned(child: Loading())
                      : Container()
                ],
              ),
            );
          }),
    );
  }

  String getSelectedOptions() {
    List<String> selected = [];
    for (int i = 0; i < options.length; i++) {
      if (selectedOptions[i]) {
        selected.add(options[i]);
      }
    }
    return selected.join(', '); // Concatenamos las opciones seleccionadas
  }
}
