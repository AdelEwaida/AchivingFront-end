// ignore_for_file: must_be_immutable

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants/colors.dart';
import '../../utils/func/responsive.dart';

const Color _primary = Color(0xFF185FA5);
const Color _textPrimary = Color(0xFF1A2340);
const Color _textSecondary = Color(0xFF8A94A6);
const Color _cardColor = Colors.white;
const Color _bgColor = Color(0xFFF6F8FC);

class TestDropdown extends StatefulWidget {
  final List<dynamic>? list;
  final List<dynamic>? selectedList;
  String? stringValue;
  bool? alwaysShownBorderText;
  final Function()? onPressed;
  final ValueChanged<dynamic> onChanged;
  final Future<List<dynamic>> Function(String)? onSearch;
  final Future<bool?> Function(List<dynamic>)? onBeforePopupOpening;
  final Function()? onClearIconPressed;
  Future<bool?> Function(List<dynamic>, List<dynamic>)? onBeforeChange;
  final double? height;
  final String borderText;
  final bool? showSearchBox;
  final Icon? icon;
  final bool cleanPrevSelectedItem;
  final bool? isEnabled;
  final Function(List<dynamic>)? onSelectAll;
  final bool? isSelectAll;
  final double? width;
  final bool Function(dynamic a, dynamic b)? compareFn;

  TestDropdown({
    super.key,
    this.list,
    this.selectedList,
    required this.onChanged,
    required this.cleanPrevSelectedItem,
    this.alwaysShownBorderText,
    this.onClearIconPressed,
    this.stringValue,
    this.icon,
    this.height,
    this.width,
    this.isEnabled,
    this.onPressed,
    this.onBeforePopupOpening,
    this.onBeforeChange,
    required this.borderText,
    this.showSearchBox,
    this.onSelectAll,
    this.isSelectAll,
    this.onSearch,
    this.compareFn,
  });

  @override
  State createState() => _TestDropdownState();
}

class _TestDropdownState extends State<TestDropdown>
    with SingleTickerProviderStateMixin {
  final GlobalKey<DropdownSearchState<dynamic>> _dropdownKey = GlobalKey();
  List<dynamic> items = [];
  List<dynamic> selectedStrings = [];
  List<dynamic> selectedItem = [];
  List<dynamic> list = [];
  String specialItem = "";

  bool isDesktop = false;
  bool isMobile = false;
  bool isChange = false;
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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _syncSelectedItems(widget.selectedList);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TestDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedList != oldWidget.selectedList) {
      _syncSelectedItems(widget.selectedList);
    }
  }

  void _syncSelectedItems(List<dynamic>? selected) {
    items = List<dynamic>.from(selected ?? const []);
  }

  String? _itemKey(dynamic item) {
    if (item == null) return null;
    if (item is Map) return item['txtKey']?.toString();
    try {
      final key = (item as dynamic).txtKey;
      if (key != null) return key.toString();
    } catch (_) {}
    return null;
  }

  bool _compareItems(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (widget.compareFn != null) return widget.compareFn!(a, b);
    final aKey = _itemKey(a);
    final bKey = _itemKey(b);
    if (aKey != null && bKey != null) return aKey == bKey;
    return a.toString() == b.toString();
  }

  List<dynamic> get _selectedItems =>
      widget.selectedList ?? List<dynamic>.from(items);

  String? get _labelText {
    final t = widget.borderText.trim();
    if (t.isEmpty) return null;
    return t;
  }

  bool get _hasValue =>
      widget.stringValue != null && widget.stringValue!.trim().isNotEmpty;

  Widget _buildValidationButton(
    BuildContext context,
    List<dynamic> selectedItems,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: whiteColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _dropdownKey.currentState?.popupOnValidate(),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ),
    );
  }

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

  InputDecoration _fieldDecoration() {
    final bool shouldFloat = _hasValue || _isPopupOpen || _isHovered;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelText: _labelText,
      alignLabelWithHint: true,
      floatingLabelBehavior: shouldFloat
          ? FloatingLabelBehavior.always
          : FloatingLabelBehavior.auto,
      labelStyle: TextStyle(fontSize: _fontSize, color: _textSecondary),
      floatingLabelStyle: const TextStyle(
        fontSize: 11,
        color: _primary,
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.white,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDE3EE), width: 1),
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
        borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: _textSecondary.withOpacity(0.3), width: 1),
      ),
      filled: true,
      fillColor: (widget.isEnabled ?? true) ? Colors.white : _bgColor,
    );
  }

  InputDecoration _searchDecoration(double popupHeight) {
    return InputDecoration(
      hintText: 'بحث',
      hintStyle: TextStyle(fontSize: _fontSize - 1, color: _textSecondary),
      prefixIcon:
          Icon(Icons.search_rounded, size: _iconSize, color: _textSecondary),
      filled: true,
      fillColor: _bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDE3EE), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDE3EE), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF185FA5), width: 1.5),
      ),
      constraints: BoxConstraints(maxHeight: popupHeight * .18),
    );
  }

  Widget _styledItem(BuildContext context, dynamic item, bool isSelected) {
    if (widget.isSelectAll == true &&
        (item == AppLocalizations.of(context)!.selectAll ||
            item == AppLocalizations.of(context)!.deselectAll)) {
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        title: Text(
          item.toString(),
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w700,
            color: isSelected ? _primary : _textPrimary,
          ),
        ),
        onTap: () {
          widget.onSelectAll?.call(widget.list ?? []);
          setState(() => selectedItem = widget.list ?? []);
          widget.onChanged(widget.list);
        },
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? _primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: isSelected
            ? Icon(Icons.check_circle_rounded, color: _primary, size: _iconSize)
            : SizedBox(width: _iconSize),
        title: Text(
          item.toString(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? _primary : _textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double popupHeight =
        widget.height ?? MediaQuery.of(context).size.height * 0.35;
    isDesktop = Responsive.isDesktop(context);
    isMobile = Responsive.isMobile(context);
    final bool isEnabled = widget.isEnabled ?? true;
    final List<dynamic> selectedItems = _selectedItems;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Tooltip(
        message: widget.stringValue ?? '',
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width ?? double.infinity,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isHovered && isEnabled
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
            child: DropdownSearch<dynamic>.multiSelection(
              key: _dropdownKey,
              asyncItems: widget.isSelectAll == true
                  ? (String filter) async {
                      final apiItems = await widget.onSearch!(filter);
                      specialItem = apiItems.isEmpty
                          ? AppLocalizations.of(context)!.deselectAll
                          : AppLocalizations.of(context)!.selectAll;
                      list = [specialItem, ...apiItems];
                      return list;
                    }
                  : widget.onSearch,
              enabled: isEnabled,
              compareFn: _compareItems,
              itemAsString: (item) => item?.toString() ?? '',
              dropdownDecoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(fontSize: _fontSize, color: _textPrimary),
                dropdownSearchDecoration: _fieldDecoration(),
              ),
              clearButtonProps: ClearButtonProps(
                alignment: Alignment.center,
                isVisible: _hasValue,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color.fromARGB(255, 237, 34, 20),
                  size: 14,
                ),
                onPressed: () {
                  items = [];
                  widget.stringValue = '';
                  widget.onClearIconPressed?.call();
                  setState(() {});
                },
              ),
              dropdownButtonProps: DropdownButtonProps(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                icon: AnimatedRotation(
                  turns: _isHovered ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon?.icon ?? Icons.keyboard_arrow_down_rounded,
                    color: isEnabled ? _primary : _textSecondary,
                    size: _iconSize + 2,
                  ),
                ),
                onPressed: widget.onPressed ?? () {},
              ),
              popupProps: PopupPropsMultiSelection.menu(
                searchDelay: const Duration(milliseconds: 200),
                showSelectedItems: true,
                onDismissed: () => setState(() => _isPopupOpen = false),
                onItemAdded: (selectedItems, addedItem) =>
                    items = selectedItems,
                onItemRemoved: (selectedItems, removedItem) =>
                    items = selectedItems,
                itemBuilder: widget.isSelectAll == true
                    ? _styledItem
                    : (context, item, isSelected) =>
                        _styledItem(context, item, isSelected),
                menuProps: MenuProps(
                  backgroundColor: _cardColor,
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.12),
                  animationDuration: const Duration(milliseconds: 150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        const BorderSide(color: Color(0xFF185FA5), width: 0.5),
                  ),
                ),
                showSearchBox: widget.showSearchBox ?? true,
                searchFieldProps: TextFieldProps(
                  autofocus: true,
                  style: TextStyle(fontSize: _fontSize),
                  decoration: _searchDecoration(popupHeight),
                ),
                isFilterOnline: true,
                constraints: BoxConstraints(maxHeight: popupHeight),
                validationWidgetBuilder: _buildValidationButton,
              ),
              dropdownBuilder: (context, selectedItems) {
                final displayText = _hasValue
                    ? widget.stringValue!
                    : selectedItems
                        .map((e) => e.toString())
                        .where((e) => e.isNotEmpty)
                        .join(', ');

                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color:
                          displayText.isEmpty ? _textSecondary : _textPrimary,
                      fontWeight: displayText.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                );
              },
              items: widget.list ?? [],
              selectedItems: selectedItems,
              onChanged: (value) {
                items = List<dynamic>.from(value);
                widget.onChanged(value);
              },
              onBeforeChange: (prevItems, nextItems) async {
                isChange = true;
                if (widget.cleanPrevSelectedItem) {
                  items.removeRange(0, selectedStrings.length);
                }
                if (widget.onBeforeChange != null) {
                  return widget.onBeforeChange!(prevItems, nextItems);
                }
                return true;
              },
              onBeforePopupOpening: (selected) async {
                setState(() => _isPopupOpen = true);

                if (_selectedItems.isNotEmpty) {
                  selected
                    ..clear()
                    ..addAll(_selectedItems);
                }

                if (widget.list != null) {
                  final available = List<dynamic>.from(widget.list!);
                  for (final picked in List<dynamic>.from(selected)) {
                    for (final option in available) {
                      if (_compareItems(picked, option)) {
                        widget.list!.remove(option);
                        break;
                      }
                    }
                  }
                  setState(() {});
                }

                if (widget.cleanPrevSelectedItem) {
                  setState(() => selectedStrings = List.from(selected));
                }
                if (widget.onBeforePopupOpening != null) {
                  return widget.onBeforePopupOpening!(selected);
                }
                return true;
              },
            ),
          ),
        ),
      ),
    );
  }
}
