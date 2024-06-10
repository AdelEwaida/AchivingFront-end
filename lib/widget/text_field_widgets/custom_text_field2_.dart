import 'package:archiving_flutter_project/widget/text_field_widgets/text_field_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';

/* This TextField Component,
    Supports Email, Password, and defualt TextFields
    Example:
    TextFieldCustom(
      text: Text(_locale.userName), -> this is the hint for the Text Field
      obscureText: false, -> if the text is shown or not in the Text Field
      controller: username, -> The controller of the Text Field
    ),
    */
class CustomTextField2 extends StatefulWidget {
  double? padding;
  // String label;
  double? width;
  TextEditingController? controller;
  String? initialValue;
  Function(String value)? onSubmitted;
  Function(String)? onValidator;
  Key? customKey;
  bool? readOnly;
  bool? autoFocus;
  Function(String value)? onChanged;
  FocusNode? focusNode;
  Text? text;
  double? height;
  Function? onSaved;
  Icon? customIcon;
  dynamic customIconSuffix;
  bool? notefield;
  Color? color;
  Function()? onTap;
  TextInputType? keyboardType;
  List<TextInputFormatter>? inputFormatters;
  bool? obscureText;
  int? maxLength;
  InputDecoration? decoration;
  bool? showText;
  bool? enabled;
  bool? isMandetory;
  bool? isReport;
  CustomTextField2(
      {Key? key,
      this.onValidator,
      this.height,
      this.isMandetory,
      // required this.label,
      this.controller,
      this.initialValue,
      this.padding,
      this.onSubmitted,
      this.customKey,
      this.width,
      this.readOnly,
      this.autoFocus,
      this.onChanged,
      this.focusNode,
      this.customIcon,
      this.customIconSuffix,
      this.color,
      this.onTap,
      this.onSaved,
      this.keyboardType,
      this.inputFormatters,
      this.text,
      this.notefield,
      this.maxLength,
      this.decoration,
      this.showText,
      this.obscureText,
      this.isReport = false,
      this.enabled})
      : super(key: key);
  @override
  State createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField2> {
  @override
  Widget build(BuildContext context) {
    // _setCursorToEnd();
    // _setCursorToBeginning();

    return SizedBox(
      // height: widget.isReport!
      //     ? MediaQuery.of(context).size.height * 0.045
      //     : MediaQuery.of(context).size.height * 0.03,
      // width: MediaQuery.of(context).size.width * 0.18,
      child: TextFieldCustom(
        focusNode: widget.focusNode,
        width: widget.width,
        height: widget.height,
        controller: widget.controller,
        onTap: () {
          // _setCursorToBeginning();
          // setState(() {});
        },
        onChanged: widget.onChanged,
        decoration: widget.isMandetory != null && widget.isMandetory!
            ? inputDecorationMandatory(widget.text!.data!)
            : widget.decoration ??
                // InputDecoration(
                //   label: Text(
                //     widget.text!.data!,
                //     style: TextStyle(
                //       fontSize: MediaQuery.of(context).size.height * 0.015,
                //       color:
                //           widget.color ?? const Color.fromARGB(255, 114, 119, 123),
                //     ),
                //   ),
                //   labelStyle: TextStyle(
                //     color: widget.color ?? const Color.fromARGB(255, 114, 119, 123),
                //   ),
                //   floatingLabelAlignment: FloatingLabelAlignment.start,
                //   prefixIcon: widget.showText == false ? null : widget.customIcon,
                //   suffixIcon:
                //       widget.showText == true ? null : widget.customIconSuffix,
                //   border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   constraints: BoxConstraints.tightFor(
                //     width: MediaQuery.of(context).size.width * 0.007,
                //   ),
                // ),
                InputDecoration(
                  // floatingLabelAlignment: FloatingLabelAlignment.center,

                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  labelText: widget.text!.data!,
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
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 131, 128, 128))),
                  errorMaxLines: 1,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: primary2,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                ),
        inputFormatters: widget.inputFormatters,
        onSaved: (value) => widget.onSaved,
        obscureText: widget.obscureText ?? false,
        initialValue: widget.initialValue,
        maxLength: widget.maxLength,
        readOnly: widget.readOnly ?? false,
        keyboardType: widget.keyboardType,
        onFieldSubmitted: widget.onSubmitted,
        // enabled: widget.enabled ?? true,
      ),
    );
  }

  void _setCursorToEnd() {
    final textLength = widget.controller?.text.length ?? 0;
    widget.controller?.selection = TextSelection.fromPosition(
      TextPosition(offset: textLength),
    );
  }

  void _setCursorToBeginning() {
    widget.controller?.selection = TextSelection.fromPosition(
      TextPosition(offset: 0),
    );
    setState(() {});
  }

  InputDecoration inputDecorationMandatory(String hint) {
    return (InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hint),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
          ),
          const Text('*', style: TextStyle(color: Colors.red)),
        ],
      ),
      //   labelText: hint,
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
      errorStyle:
          const TextStyle(height: 0, color: Color.fromARGB(255, 207, 95, 4)),
      enabledBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      errorMaxLines: 1,
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: primary2,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(1.0),
      ),
    ));
  }
}
