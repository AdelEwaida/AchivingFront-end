import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class NoteTextFiled extends StatefulWidget {
  final TextEditingController controller;
  FocusNode? foucas;
  double? height;
  double? width;
  bool? readOnly;

  NoteTextFiled(
      {this.height,
      this.width,
      this.foucas,
      this.readOnly,
      required this.controller,
      super.key});

  @override
  State<NoteTextFiled> createState() => _NoteTextFiledState();
}

class _NoteTextFiledState extends State<NoteTextFiled>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AppLocalizations _local;
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    _local = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter &&
              event.isShiftPressed) {
            widget.controller.text += '\n';
            widget.controller.selection = TextSelection.collapsed(
              offset: widget.controller.text.length,
            );
          } else if (event.logicalKey == LogicalKeyboardKey.enter &&
              !event.isShiftPressed) {}
        }
      },
      child: CustomTextField2(
        focusNode: widget.foucas ?? FocusNode(),
        // textInputAction: TextInputAction.none,
        keyboardType: TextInputType.none,
        width: widget.width ?? screenWidth * 0.2,
        height: widget.height ?? screenHeight * 0.15,
        // autofocus: false,
        controller: widget.controller,
        isReport: true,

        // maxLines: 7,
        readOnly: widget.readOnly ?? false,
        decoration: InputDecoration(
          // floatingLabelAlignment: FloatingLabelAlignment.center,

          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          // labelText: widget.text!.data!,
          label: Text(_local.notes),
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 68, 67, 67),
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 1.0,
          ),
          errorStyle: const TextStyle(
              height: 0, color: Color.fromARGB(255, 207, 95, 4)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          errorMaxLines: 1,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: primary2,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(1.0),
          ),
        ),
        // decoration: InputDecoration(
        //   hintText: _local.notes,
        //   hintStyle: TextStyle(fontSize: screenHeight * 0.025),
        // ),
      ),
    );
  }
}
