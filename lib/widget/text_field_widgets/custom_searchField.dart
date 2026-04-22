import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _sfPrimary = Color(0xFF185FA5);
const Color _sfBorder = Color(0xFFDDE3EE);
const Color _sfLabel = Color(0xFF8A94A6);
const Color _sfText = Color(0xFF1A2340);

// ignore: must_be_immutable
class CustomSearchField extends StatefulWidget {
  String label;
  double? padding;
  double? horizontalPadding;
  List<TextInputFormatter>? inputFormatters;
  double? width;
  TextEditingController? controller;
  String? initialValue;
  Function(String value)? onSubmitted;
  Function(String)? onValidator;
  Key? customKey;
  bool? readOnly;
  bool? autoFocus;
  Function()? onSearchIconTap;
  Function(String value)? onChanged;
  FocusNode? focusNode;

  CustomSearchField({
    Key? key,
    this.onSearchIconTap,
    this.onValidator,
    this.controller,
    required this.label,
    this.initialValue,
    this.padding,
    this.onSubmitted,
    this.customKey,
    this.width,
    this.readOnly,
    this.autoFocus,
    this.onChanged,
    this.horizontalPadding,
    this.focusNode,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;
  bool _hasText = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });

    _controller.addListener(() {
      setState(() => _hasText = _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (_isFocused) return _sfPrimary;
    if (_isHovered) return _sfPrimary.withOpacity(0.5);
    return _sfBorder;
  }

  double get _borderWidth {
    if (_isFocused) return 1.8;
    if (_isHovered) return 1.2;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.padding ?? 0,
        horizontal: widget.horizontalPadding ?? 0,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _borderColor,
              width: _borderWidth,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: _sfPrimary.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: TextFormField(
            inputFormatters: widget.inputFormatters,
            autofocus: widget.autoFocus ?? false,
            textAlignVertical: TextAlignVertical.center,
            focusNode: _focusNode,
            controller: _controller,
            readOnly: widget.readOnly ?? false,
            validator: (text) =>
                widget.onValidator == null ? null : widget.onValidator!(text!),
            onFieldSubmitted: widget.onSubmitted,
            style: const TextStyle(
              fontSize: 13,
              color: _sfText,
            ),
            decoration: InputDecoration(
              // ── No border — container handles it ──────────
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 10,
              ),

              // ── Search icon prefix ─────────────────────────
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: _isFocused ? _sfPrimary : _sfLabel,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),

              // ── Clear button when text exists ──────────────
              suffixIcon: _hasText
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        if (widget.onChanged != null) widget.onChanged!('');
                        if (widget.onSubmitted != null) widget.onSubmitted!('');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: _sfLabel,
                        ),
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),

              // ── Hint ───────────────────────────────────────
              hintText: widget.label,
              hintStyle: TextStyle(
                fontSize: 13,
                color: _sfLabel.withOpacity(0.7),
              ),
            ),
            onChanged: (value) {
              if (widget.onChanged != null) widget.onChanged!(value);
            },
          ),
        ),
      ),
    );
  }
}
