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
  
      child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const SizedBox(),
             Text(widget.title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Container(
                 decoration: const BoxDecoration(
                     shape: BoxShape.rectangle,
                     color: Color.fromARGB(255, 237, 34, 20)),
                 child: IconButton(
                     onPressed: () {
                       Navigator.pop(context);
                     },
                     icon: const Icon(
                      
                       Icons.close_rounded,
                       color: Colors.white,
                       size: 14,
                     )),
               ),
             ),
           ],
         ),
    );
  }
}
