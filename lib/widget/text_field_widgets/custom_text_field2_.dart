import 'package:archiving_flutter_project/widget/text_field_widgets/text_field_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';

// ── Design tokens ─────────────────────────────────────────────────
const Color _tfPrimary = Color(0xFF185FA5);
const Color _tfBorder = Color(0xFFDDE3EE);
const Color _tfBorderHover = Color(0xFF185FA5);
const Color _tfBg = Color(0xFFF6F8FC);
const Color _tfBgFocus = Colors.white;
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

class _CustomTextField2State extends State<CustomTextField2>
    with SingleTickerProviderStateMixin {
  late FocusNode _internalFocus;
  bool _isFocused = false;
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _borderAnim;

  @override
  void initState() {
    super.initState();
    _internalFocus = widget.focusNode ?? FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _borderAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _internalFocus.addListener(() {
      setState(() => _isFocused = _internalFocus.hasFocus);
      if (_internalFocus.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.focusNode == null) _internalFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _isReadOnly => widget.readOnly ?? false;
  bool get _isEnabled => widget.enabled ?? true;

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: !_isEnabled
              ? const Color(0xFFF0F2F5)
              : Colors.white, // ← always white, focused or not
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _currentBorderColor,
            width: _currentBorderWidth,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: _tfPrimary.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
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
    // If a custom decoration is passed, use it
    if (widget.decoration != null) return widget.decoration!;

    return InputDecoration(
      // ── No double border — container handles it ──────────
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder:
          InputBorder.none, // In _buildDecoration, add these two lines:
      filled: true,
      fillColor: Colors.transparent, // ← TextFieldCustom bg = transparent

      // ── Padding ──────────────────────────────────────────
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      // ── Label ────────────────────────────────────────────
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
                Text(
                  '*',
                  style: TextStyle(
                    color: _tfError,
                    fontSize: 13,
                  ),
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

      floatingLabelStyle: TextStyle(
        fontSize: 11,
        color: _isFocused ? _tfPrimary : _tfLabel,
        fontWeight: FontWeight.w500,
        backgroundColor: _isFocused ? Colors.white : _tfBg,
      ),

      floatingLabelBehavior: FloatingLabelBehavior.auto,

      // ── Prefix icon ──────────────────────────────────────
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

      // ── Suffix icon ──────────────────────────────────────
      suffixIcon: _isReadOnly
          ? Icon(Icons.lock_outline_rounded, size: 14, color: _tfLabel)
          : widget.customIconSuffix != null
              ? widget.customIconSuffix
              : null,

      // ── Error style ──────────────────────────────────────
      errorStyle: const TextStyle(
        height: 0.8,
        fontSize: 10,
        color: _tfError,
      ),
      errorMaxLines: 1,

      // ── Hint style ───────────────────────────────────────
      hintStyle: TextStyle(
        fontSize: 13,
        color: _tfLabel.withOpacity(0.6),
      ),

      // ── Fill ─────────────────────────────────────────────
    );
  }
}
