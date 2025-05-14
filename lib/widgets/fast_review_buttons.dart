import 'package:flutter/material.dart';
import 'package:abril_driver_app/styles/styles.dart';

class FastButtonsReview extends StatefulWidget {
  List<String> options;
  List<bool> selectedOptions;

  FastButtonsReview({
    super.key, required this.options, required this.selectedOptions
  });
  @override
  _FastButtonsReviewState createState() => _FastButtonsReviewState();
}

class _FastButtonsReviewState extends State<FastButtonsReview> {


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Wrap(
        spacing: 8.0,
        children: List<Widget>.generate(
          widget.options.length,
          (int index) {
            return ChoiceChip(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                labelStyle: TextStyle(
                color: widget.selectedOptions[index] ? Colors.white : Colors.black,
              ), 
                label: Text(
                  widget.options[index],
                ),
                selected: widget.selectedOptions[index],
                onSelected: (bool selected) {
                  setState(() {
                    widget.selectedOptions[index] = selected;
                  });
                },
                checkmarkColor: page,
                selectedColor: newRedColor,
                backgroundColor: page,
              );
          },
        ).toList(),
      ),
    );
  }
}
