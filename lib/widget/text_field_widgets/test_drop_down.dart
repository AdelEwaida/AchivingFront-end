// ignore_for_file: must_be_immutable

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/func/responsive.dart';

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

  TestDropdown(
      {super.key,
      this.list,
      this.selectedList,
      required this.onChanged,
      required this.cleanPrevSelectedItem,
      this.alwaysShownBorderText,
      this.onClearIconPressed,
      this.stringValue,
      this.icon,
      this.height,
      this.isEnabled,
      this.onPressed,
      this.onBeforePopupOpening,
      this.onBeforeChange,
      required this.borderText,
      this.showSearchBox,
      this.onSelectAll,
      this.isSelectAll,
      this.onSearch});

  @override
  State createState() => _TestDropdownState();
}

class _TestDropdownState extends State<TestDropdown> {
  List<dynamic> items = [];
  List<dynamic> selectedStrings = [];

  bool isDesktop = false;
  bool isMobile = false;
  final GlobalKey _fieldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  List<dynamic> selectedItem = [];
  List<dynamic> list = [];
  String specialItem = "";
  @override
  void didChangeDependencies() {
    if (widget.selectedList != null) {
      for (int i = 0; i < widget.selectedList!.length; i++) {
        items.add(widget.selectedList![i]);
      }
    }
    super.didChangeDependencies();
  }

  bool isChange = false;
  @override
  Widget build(BuildContext context) {
    double height = widget.height ?? MediaQuery.of(context).size.height * 0.4;
    isDesktop = Responsive.isDesktop(context);
    isMobile = Responsive.isMobile(context);
    bool alwaysShownBorderText = widget.alwaysShownBorderText ?? false;
    if (widget.stringValue == null || widget.stringValue!.isEmpty) {
      items = []; // Ensure no pre-selected items are displayed
    }

    if (widget.stringValue != null && widget.stringValue!.isNotEmpty) {
      items = [''];
    } else if (widget.stringValue != null && widget.stringValue!.isEmpty) {
      items = [];
    }

    return Tooltip(
      message: widget.stringValue ?? "",
      child: SizedBox(
        child: DropdownSearch<dynamic>.multiSelection(
            key: _fieldKey,
            asyncItems: widget.isSelectAll == true
                ? (String filter) async {
                    final apiItems = await widget.onSearch!(filter);
                    if (apiItems.isEmpty) {
                      specialItem = AppLocalizations.of(context)!.deselectAll;
                    } else {
                      specialItem = AppLocalizations.of(context)!.selectAll;
                    }
                    list = [specialItem, ...apiItems];
                    return list;
                  }
                : widget.onSearch,
            enabled: widget.isEnabled ?? true,
            dropdownDecoratorProps: alwaysShownBorderText == false &&
                    (items.isNotEmpty ||
                        (widget.stringValue != null &&
                            widget.stringValue!.isNotEmpty))
                ? DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 68, 67, 67),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                      labelText: widget.borderText,
                      labelStyle: const TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(235, 158, 158, 158),
                      ),
                      alignLabelWithHint: true,
                    ),
                  )
                : const DropDownDecoratorProps(),
            dropdownButtonProps: widget.icon != null
                ? DropdownButtonProps(
                    padding: const EdgeInsets.only(bottom: 5, top: 3),
                    icon: widget.icon!,
                    onPressed: widget.onPressed ?? () {})
                : const DropdownButtonProps(
                    padding:
                        EdgeInsets.only(bottom: 5, top: 3, left: 0, right: 0),
                  ),
            popupProps: PopupPropsMultiSelection.menu(
              searchDelay: const Duration(milliseconds: 1),
              onItemAdded: (selectedItems, addedItem) {
                items = selectedItems;
              },
              onItemRemoved: (selectedItems, removedItem) {
                items = selectedItems;
              },
              itemBuilder: widget.isSelectAll == true
                  ? _customItemBuilder
                  : (context, item, isSelected) {
                      return ListTile(
                        title: Text(
                          item.toString(),
                          style: TextStyle(
                            fontSize: 12, // Set your desired font size here
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
              menuProps: const MenuProps(
                animationDuration: Duration(milliseconds: 100),
              ),
              showSearchBox: widget.showSearchBox ?? true,
              searchFieldProps: TextFieldProps(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(borderSide: BorderSide()),
                    constraints: BoxConstraints.tightFor(height: height * .18),
                  )),
              isFilterOnline: true,
              constraints: BoxConstraints.tightFor(height: height),
            ),
            dropdownBuilder: _customDropDownPrograms,
            items: widget.list ?? [],
            selectedItems: widget.selectedList ?? [],
            onChanged: widget.onChanged,
            onBeforeChange: (prevItems, nextItems) async {
              isChange = true;
              if (widget.cleanPrevSelectedItem) {
                items.removeRange(0, selectedStrings.length);
              }

              if (widget.onBeforeChange != null) {
                return widget.onBeforeChange!(prevItems, nextItems);
              } else {
                return true;
              }
            },
            onBeforePopupOpening: (s) async {
              if (widget.list != null) {
                if (items.isEmpty) {
                  s.clear();
                  setState(() {});
                }
                if (widget.selectedList != null) {
                  s.clear();
                  s.addAll(widget.selectedList!);
                }
                List<dynamic> n = widget.list!;
                for (int j = 0; j < s.length; j++) {
                  for (int i = 0; i < n.length; i++) {
                    if (s[j].toString().compareTo(n[i].toString()) == 0) {
                      widget.list!.remove(n[i]);
                      break;
                    }
                  }
                }
                setState(() {});
              }
              if (widget.cleanPrevSelectedItem) {
                setState(() {
                  selectedStrings = s;
                });
              }

              if (widget.onBeforePopupOpening != null) {
                return widget.onBeforePopupOpening!(s);
              } else {
                return true;
              }
            }),
      ),
    );
  }

  Widget _customItemBuilder(
      BuildContext context, dynamic item, bool isSelected) {
    if (item == AppLocalizations.of(context)!.selectAll ||
        item == AppLocalizations.of(context)!.deselectAll) {
      return ListTile(
        title: Text(
          item,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        onTap: () {
          if (widget.onSelectAll != null) {
            widget.onSelectAll!(widget.list!); // Trigger Select All callback
          }
          setState(() {
            selectedItem = widget.list ?? [];
          });
          widget.onChanged(widget.list); // Call onChanged with all items
        },
      );
    }
    return ListTile(
      title: Text(
        item.toString(),
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _customDropDownPrograms(BuildContext context, dynamic item) {
    double height = MediaQuery.of(context).size.height;
    bool alwaysShownBorderText = widget.alwaysShownBorderText ?? false;
    if (items.isEmpty) {
      item = [];
    }

    if (items.isNotEmpty && !isChange) {
      if (widget.selectedList != null && widget.selectedList!.isNotEmpty) {
        items = [];

        for (int i = 0; i < widget.selectedList!.length; i++) {
          items.add(widget.selectedList![i]);
        }
        isChange = false;
      } else {
        items = [];
        isChange = false;
      }
    } else {
      if (widget.selectedList != null && widget.selectedList!.isNotEmpty) {
        items = [];
        for (int i = 0; i < widget.selectedList!.length; i++) {
          items.add(widget.selectedList![i]);
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        alwaysShownBorderText == false &&
                (item.isNotEmpty ||
                    (widget.stringValue != null &&
                        widget.stringValue!.isNotEmpty))
            ? Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: SizedBox(
                  width: getWidth(false),
                  child: Text(
                      (widget.stringValue != null &&
                              widget.stringValue!.isNotEmpty)
                          ? widget.stringValue!
                          : item
                              .toString()
                              .replaceAll("[", "")
                              .replaceAll("]", ""),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: height * .018, color: Colors.black)),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: getWidth(true),
                  child: Text(widget.borderText,
                      // textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: height * .018,
                          color: const Color.fromARGB(235, 158, 158, 158))),
                ),
              ),
        Row(
          children: [
            (widget.list != null && items.isNotEmpty) ||
                    (widget.stringValue != null &&
                        widget.stringValue!.isNotEmpty)
                ? IconButton(
                    padding: const EdgeInsets.only(bottom: 2, top: 2),
                    icon: const Icon(Icons.close),
                    onPressed: (() {
                      if (widget.onClearIconPressed != null) {
                        items = [];

                        if (widget.stringValue != null) {
                          widget.stringValue = "";
                        }

                        widget.onClearIconPressed!();
                      }
                      setState(() {});
                    }),
                    color: const Color.fromARGB(235, 158, 158, 158),
                  )
                : Container(),
            widget.icon != null
                ? const Padding(
                    padding:
                        EdgeInsets.only(bottom: 8.0, top: 2, left: 0, right: 0),
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 15,
                      color: Color.fromARGB(235, 158, 158, 158),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        )
      ],
    );
  }

  getWidth(bool isBorder) {
    final RenderBox? renderBox =
        _fieldKey.currentContext!.findRenderObject() as RenderBox?;
    double width = 0;
    if (renderBox != null) {
      if (widget.icon != null) {
        width =
            isBorder ? renderBox.size.width - 75 : renderBox.size.width - 113;
      } else {
        width =
            isBorder ? renderBox.size.width - 50 : renderBox.size.width - 90;
      }
    }
    return width;
  }
}
