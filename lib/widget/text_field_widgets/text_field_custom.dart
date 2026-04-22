// ignore_for_file: must_be_immutable

import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCustom extends StatefulWidget {
  Text? text;
  ValueChanged<String>? onChanged;
  Function? onSaved;
  TextEditingController? controller;
  Icon? customIcon;
  dynamic customIconSuffix;
  bool? notefield;
  FocusNode? focusNode;
  Color? color;
  Function()? onTap;
  TextInputType? keyboardType;
  List<TextInputFormatter>? inputFormatters;
  Function(String)? onValidator;
  bool? obscureText;
  String? initialValue;
  bool? readOnly;
  double? width;
  double? height;
  int? maxLength;
  InputDecoration? decoration;
  IconButton? testButton;
  bool? showText;
  Function(String)? onFieldSubmitted;
  TextStyle? style;
  int? maxLines;
  // dynamic? pre;
  TextFieldCustom(
      {Key? key,
      this.focusNode,
      this.width,
      this.height,
      this.customIcon,
      this.customIconSuffix,
      this.color,
      this.onValidator,
      this.onTap,
      this.onSaved,
      this.keyboardType,
      this.testButton,
      this.inputFormatters,
      this.text,
      this.onChanged,
      this.controller,
      this.initialValue,
      this.notefield,
      this.readOnly,
      this.maxLength,
      this.decoration,
      this.showText,
      this.style,
      this.onFieldSubmitted,
      this.maxLines,
      this.obscureText})
      : super(key: key);

  @override
  State createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDesktop = Responsive.isDesktop(context);

    return Container(
      // ← remove the Padding wrapper and the white Container
      // ← color: transparent so parent CustomTextField2 shows through
      color: Colors.transparent,
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        textDirection: TextDirection.rtl,
        onTap: () {
          if (widget.onTap != null) widget.onTap!();
        },
        focusNode: widget.focusNode ?? FocusNode(),
        onFieldSubmitted: (value) {
          if (widget.onFieldSubmitted != null) widget.onFieldSubmitted!(value);
        },
        style: widget.style,
        controller: widget.controller,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines ?? 1,
        validator: (text) =>
            widget.onValidator == null ? null : widget.onValidator!(text!),
        decoration: widget.decoration ??
            InputDecoration(
              label: Text(
                widget.text!.data!,
                style: TextStyle(
                  fontSize: isDesktop ? height * 0.016 : height * 0.014,
                ),
              ),
              prefixIcon: widget.showText == false ? null : widget.customIcon,
              suffixIcon:
                  widget.showText == true ? null : widget.customIconSuffix,
              border: InputBorder.none, // ← no underline
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
        inputFormatters: widget.inputFormatters,
        onSaved: (value) => widget.onSaved,
        obscureText: widget.obscureText ?? false,
        initialValue: widget.initialValue,
        maxLength: widget.maxLength,
        readOnly: widget.readOnly ?? false,
        keyboardType: widget.keyboardType,
      ),
    );
  }

  void _setCursorToEnd() {
    final textLength = widget.controller?.text.length ?? 0;
    widget.controller?.selection = TextSelection.fromPosition(
      TextPosition(offset: textLength),
    );
  }
}
