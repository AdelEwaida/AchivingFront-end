import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

// ── Design tokens (matching CustomDropDownSearch) ────────────────
const Color _primary = Color(0xFF185FA5);
const Color _primaryLight = Color(0x1A185FA5);
const Color _primaryBorder = Color(0x33185FA5);
const Color _textPrimary = Color(0xFF1A2340);
const Color _textSecondary = Color(0xFF8A94A6);
const Color _cardColor = Colors.white;
const Color _bgColor = Color(0xFFF6F8FC);

// ignore: must_be_immutable
class DropDown extends StatefulWidget {
  double? width;
  double? padding;
  String? bordeText;
  double? height;
  Key? customKey;
  final List<dynamic>? items;
  final ValueChanged<dynamic> onChanged;
  final dynamic initialValue;
  final Function(String)? onValidator;
  final Future<bool?> Function(dynamic)? onBeforeOpening;
  double? heightVal;
  bool? searchBox;
  bool? valSelected;
  dynamic object;
  Color? color;
  String? selectedVal;
  bool? visiableClearIcon;
  Widget? suffixIcon;
  final Function()? onClearIconPressed;
  final Function()? onPressed;
  Icon? icon;
  final Future<List<dynamic>> Function(String)? onSearch;
  final bool? showBorder;
  bool? isEnabled;
  bool? isMandatory;
  String? noDataString;
  final Widget Function(BuildContext context, dynamic item, bool isSelected)?
      customItemBuilder;
  final Widget? popupTitle;

  DropDown({
    Key? key,
    this.onClearIconPressed,
    this.visiableClearIcon,
    this.width,
    this.height,
    this.initialValue,
    this.valSelected,
    this.onValidator,
    this.items,
    this.padding,
    this.searchBox,
    this.heightVal,
    this.bordeText,
    this.isMandatory = false,
    this.customKey,
    this.isEnabled,
    required this.onChanged,
    this.object,
    this.selectedVal,
    this.suffixIcon,
    this.onPressed,
    this.onSearch,
    this.icon,
    this.onBeforeOpening,
    this.showBorder,
    this.noDataString,
    this.color,
    this.customItemBuilder,
    this.popupTitle,
  }) : super(key: key);

  @override
  State<DropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<DropDown>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPopupOpen = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  String? get _labelText {
    final t = widget.bordeText?.trim();
    if (t == null || t.isEmpty) return null;
    return widget.isMandatory == true ? '$t *' : t;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.isEnabled ?? true;

  double get _fontSize {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 13.0;
    if (w >= 768) return 12.0;
    return 11.0;
  }

  double get _iconSize {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 20.0;
    if (w >= 768) return 18.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double popupHeight = widget.heightVal ?? screenHeight * 0.35;

    return FadeTransition(
      opacity: _fadeAnim,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // ← NO border here, let InputDecoration handle it
            boxShadow: _isHovered && _isEnabled
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
          child: DropdownSearch<dynamic>(
            clearButtonProps: ClearButtonProps(
              alignment: Alignment.center,
              isVisible: widget.visiableClearIcon ?? false,
              icon: Icon(Icons.close_rounded, color: redColor, size: 14),
            ),
            enabled: _isEnabled,
            validator: (value) =>
                widget.onValidator == null ? null : widget.onValidator!(value),
            items: widget.items ?? [],
            asyncItems: widget.onSearch,
            itemAsString: (item) {
              if (item == null) return '';
              final sv = widget.selectedVal?.trim();
              if (sv != null && sv.isNotEmpty) return sv;
              return item.toString();
            },
            dropdownButtonProps: DropdownButtonProps(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              icon: AnimatedRotation(
                turns: _isHovered ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon?.icon ?? Icons.keyboard_arrow_down_rounded,
                  color: _isEnabled ? _primary : _textSecondary,
                  size: _iconSize + 2,
                ),
              ),
              onPressed: widget.onPressed ?? () {},
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              baseStyle: TextStyle(fontSize: _fontSize, color: _textPrimary),
              dropdownSearchDecoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                labelText: _labelText,
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle:
                    TextStyle(fontSize: _fontSize, color: _textSecondary),
                floatingLabelStyle: const TextStyle(
                  fontSize: 14,
                  color: _primary,
                  fontWeight: FontWeight.w500,
                  backgroundColor: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFDDE3EE), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: (_isHovered || _isPopupOpen)
                        ? _primary.withOpacity(0.5)
                        : const Color(0xFFDDE3EE),
                    width: (_isHovered || _isPopupOpen) ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: _textSecondary.withOpacity(0.3), width: 1),
                ),
                filled: true,
                fillColor: _isEnabled ? Colors.white : _bgColor,
              ),
            ),
            popupProps: PopupProps.menu(
              fit: FlexFit.loose,
              title: widget.popupTitle,
              onDismissed: () => setState(() => _isPopupOpen = false),
              searchDelay: const Duration(milliseconds: 200),
              showSearchBox: widget.popupTitle != null
                  ? false
                  : (widget.searchBox ?? true),
              isFilterOnline: widget.onSearch != null,
              constraints: widget.popupTitle != null
                  ? BoxConstraints.tightFor(height: popupHeight)
                  : BoxConstraints(maxHeight: popupHeight),

              menuProps: MenuProps(
                backgroundColor: _cardColor,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _primary,
                    width: 0.5,
                  ),
                ),
              ),

              searchFieldProps: TextFieldProps(
                autofocus: true,
                style: TextStyle(fontSize: _fontSize),
                decoration: InputDecoration(
                  hintText: "بحث",
                  hintStyle:
                      TextStyle(fontSize: _fontSize - 1, color: _textSecondary),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: _iconSize, color: _textSecondary),
                  filled: true,
                  fillColor: _bgColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDE3EE), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDE3EE), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _primary, width: 1.5),
                  ),
                  constraints: const BoxConstraints(maxHeight: 44),
                ),
              ),

              itemBuilder: widget.customItemBuilder ??
                  (context, item, isSelected) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        leading: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: _primary, size: _iconSize)
                            : SizedBox(width: _iconSize),
                        title: Text(
                          item.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? _primary : _textPrimary,
                          ),
                        ),
                      ),
                    );
                  },

              // ── Empty state ──────────────────────────
              emptyBuilder: (context, searchEntry) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 32, color: _textSecondary.withOpacity(0.4)),
                    const SizedBox(height: 8),
                    Text(
                      widget.noDataString ?? '',
                      style:
                          TextStyle(fontSize: _fontSize, color: _textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            onBeforePopupOpening: (dynamic selected) async {
              setState(() => _isPopupOpen = true);
              if (widget.onBeforeOpening != null) {
                return widget.onBeforeOpening!(selected);
              }
              return true;
            },
            onChanged: widget.onChanged,
            selectedItem: widget.initialValue,
          ),
        ),
      ),
    );
  }
}
