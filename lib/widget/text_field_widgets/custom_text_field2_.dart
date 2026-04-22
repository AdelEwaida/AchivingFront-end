import 'package:archiving_flutter_project/widget/text_field_widgets/text_field_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';

const Color _tfPrimary = Color(0xFF185FA5);
const Color _tfBorder = Color(0xFFDDE3EE);
const Color _tfLabel = Color(0xFF8A94A6);
const Color _tfText = Color(0xFF1A2340);
const Color _tfError = Color(0xFFA32D2D);

class CustomTextField2 extends StatefulWidget {
  double? padding;
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

  CustomTextField2({
    Key? key,
    this.onValidator,
    this.height,
    this.isMandetory,
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
    this.enabled,
  }) : super(key: key);

  @override
  State createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField2> {
  late FocusNode _internalFocus;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _internalFocus = widget.focusNode ?? FocusNode();
    _internalFocus.addListener(() {
      setState(() => _isFocused = _internalFocus.hasFocus);
    });
    // Rebuild when controller text changes so label floats correctly
    widget.controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _internalFocus.dispose();
    super.dispose();
  }

  bool get _isReadOnly => widget.readOnly ?? false;
  bool get _isEnabled => widget.enabled ?? true;

  // ── True when field already has a value ──────────────────────────
  bool get _hasValue =>
      (widget.controller != null && widget.controller!.text.isNotEmpty) ||
      (widget.initialValue != null && widget.initialValue!.isNotEmpty);

  Color get _currentBorderColor {
    if (!_isEnabled) return _tfBorder.withOpacity(0.5);
    if (_isFocused) return _tfPrimary;
    if (_isHovered) return _tfPrimary.withOpacity(0.5);
    return _tfBorder;
  }

  double get _currentBorderWidth {
    if (_isFocused) return 1.8;
    if (_isHovered) return 1.2;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final String hint = widget.text?.data ?? '';
    final bool isMandatory = widget.isMandetory ?? false;
    final bool shouldFloat = _hasValue || _isFocused;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: widget.width,
        height: widget.height,
        // ← NO decoration here — OutlineInputBorder handles the border
        child: TextFieldCustom(
          focusNode: _internalFocus,
          width: widget.width,
          height: widget.height,
          controller: widget.controller,
          onTap: widget.onTap ?? () {},
          onChanged: widget.onChanged,
          decoration: _buildDecoration(hint, isMandatory),
          inputFormatters: widget.inputFormatters,
          onSaved: (value) => widget.onSaved,
          obscureText: widget.obscureText ?? false,
          initialValue: widget.initialValue,
          maxLength: widget.maxLength,
          readOnly: _isReadOnly,
          keyboardType: widget.keyboardType,
          onFieldSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }

  InputDecoration _buildDecoration(String hint, bool isMandatory) {
    if (widget.decoration != null) return widget.decoration!;

    final bool shouldFloat = _hasValue || _isFocused;

    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _tfBorder, width: 1),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _tfPrimary, width: 1.8),
    );

    final OutlineInputBorder hoveredBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _tfPrimary.withOpacity(0.5), width: 1.2),
    );

    final OutlineInputBorder disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _tfBorder.withOpacity(0.5), width: 1),
    );

    return InputDecoration(
      // ── OutlineInputBorder draws the border + label cutout ──
      border: defaultBorder,
      enabledBorder: _isHovered ? hoveredBorder : defaultBorder,
      focusedBorder: focusedBorder,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _tfError, width: 1),
      ),
      disabledBorder: disabledBorder,

      filled: true,
      fillColor: !_isEnabled ? const Color(0xFFF0F2F5) : Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      // ── Float label above border when value exists or focused ──
      floatingLabelBehavior: shouldFloat
          ? FloatingLabelBehavior.always
          : FloatingLabelBehavior.auto,

      label: isMandatory
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isFocused ? _tfPrimary : _tfLabel,
                  ),
                ),
                const SizedBox(width: 3),
                const Text(
                  '*',
                  style: TextStyle(color: _tfError, fontSize: 13),
                ),
              ],
            )
          : Text(
              hint,
              style: TextStyle(
                fontSize: 13,
                color: _isFocused ? _tfPrimary : _tfLabel,
              ),
            ),

      // ── Floating label — white bg cuts through the border ──
      floatingLabelStyle: TextStyle(
        fontSize: 11,
        color: _isFocused ? _tfPrimary : _tfLabel,
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.white,
      ),

      prefixIcon: widget.customIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: Icon(
                widget.customIcon!.icon,
                size: 16,
                color: _isFocused ? _tfPrimary : _tfLabel,
              ),
            )
          : null,

      suffixIcon: _isReadOnly
          ? const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: _tfLabel,
            )
          : widget.customIconSuffix != null
              ? widget.customIconSuffix
              : null,

      errorStyle: const TextStyle(
        height: 0.8,
        fontSize: 10,
        color: _tfError,
      ),
      errorMaxLines: 1,

      hintStyle: TextStyle(
        fontSize: 13,
        color: _tfLabel.withOpacity(0.6),
      ),
    );
  }
}
