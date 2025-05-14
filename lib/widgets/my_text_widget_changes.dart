import 'package:flutter/material.dart';
import 'package:abril_driver_app/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextWidget extends StatefulWidget {
  final Map<String, dynamic> driverReq;
  final Map<String, dynamic> languages;
  final String choosenLanguage;

  MyTextWidget({
    required this.driverReq,
    required this.languages,
    required this.choosenLanguage,
  });

  @override
  _MyTextWidgetState createState() => _MyTextWidgetState();
}

class _MyTextWidgetState extends State<MyTextWidget> {
  bool isLoading = false;
  String displayText = '';

  @override
  void initState() {
    super.initState();
    _updateTextWithLoader();
  }

  @override
  void didUpdateWidget(covariant MyTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverReq != widget.driverReq) {
      _updateTextWithLoader();
    }
  }

  Future<void> _updateTextWithLoader() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    // Simulate a short delay to show the loader
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    setState(() {
      if (widget.driverReq['is_driver_arrived'] == 0) {
        displayText = 'Llegué al lugar';
      } else if (widget.driverReq['is_driver_arrived'] == 1 &&
          widget.driverReq['is_trip_start'] == 0) {
        displayText = widget.languages[widget.choosenLanguage]['text_startride'];
      } else {
        displayText = widget.languages[widget.choosenLanguage]['text_endtrip'];
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
            displayText,
            style: GoogleFonts.montserrat(
              color: page,
              fontWeight: FontWeight.bold,
            ),
          );}
}
