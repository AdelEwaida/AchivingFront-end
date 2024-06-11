import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TitleDialogWidget extends StatefulWidget {
  String title;
  double width;
  double height;
  TitleDialogWidget(
      {super.key,
      required this.title,
      required this.width,
      required this.height});

  @override
  State<TitleDialogWidget> createState() => _TitleDialogWidgetState();
}

class _TitleDialogWidgetState extends State<TitleDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: dBar,
        // borderRadius:
        //     BorderRadius.circular(5.0), // Adjust the value as needed
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              widget.title,
              style: const TextStyle(
                  color: whiteColor, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0), color: redColor),
              child: IconButton(
                  alignment: Alignment.center,
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
