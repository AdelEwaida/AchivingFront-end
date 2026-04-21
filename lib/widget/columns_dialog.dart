import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../dialogs/app_dialog.dart';

class ColumnAttributesDialog extends StatefulWidget {
  final TextEditingController searchController;
  // final ValueNotifier<bool> isLoading;
  final ValueNotifier<List<PlutoRow>> displayedItems;
  final ScrollController scrollController;
  final ValueNotifier<bool> isLoadingMore;
  final PlutoColumn column;
  final double width;
  final double height;
  final Function initializeData;
  final Function toggleAttributeVisibility;
  final Map<PlutoRow, ValueNotifier<bool>> isDisplayed;
  final PlutoGridStateManager stateManager;
  final List<PlutoRow> filterRows;
  final List<PlutoRow> Function(
      PlutoColumn column, PlutoGridStateManager stateManager) getColumns;

  const ColumnAttributesDialog({
    Key? key,
    required this.searchController,
    // required this.isLoading,
    required this.displayedItems,
    required this.scrollController,
    required this.isLoadingMore,
    required this.column,
    required this.width,
    required this.height,
    required this.initializeData,
    required this.toggleAttributeVisibility,
    required this.isDisplayed,
    required this.stateManager,
    required this.getColumns,
    required this.filterRows,
  }) : super(key: key);

  @override
  _ColumnAttributesDialogState createState() => _ColumnAttributesDialogState();
}

class _ColumnAttributesDialogState extends State<ColumnAttributesDialog> {
  ValueNotifier<bool> isloading = ValueNotifier<bool>(true);
  late AppLocalizations _locale;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      isloading.value = true;
      await Future.delayed(Duration.zero);
      widget.getColumns(widget.column, widget.stateManager);
      widget.initializeData();
    } catch (e) {
    } finally {
      isloading.value = false;
    }
  }

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.searchController.dispose();
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Row(
        children: [
          Text(
            _locale.setFilter,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 220,
            height: 38,
            child: TextField(
              controller: widget.searchController,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: _locale.search,
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
              onChanged: (query) {
                if (query.isEmpty) {
                  widget.initializeData();
                } else {
                  final filteredList = widget.isDisplayed.keys
                      .where((row) => row.cells[widget.column.field]!.value
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                  widget.displayedItems.value = filteredList;
                }
              },
            ),
          ),
        ],
      ),
      content: ValueListenableBuilder<bool>(
        valueListenable: isloading,
        builder: (context, isLoadingValue, child) {
          return Container(
            height: widget.height * 0.5,
            width: widget.width * 0.28,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: isLoadingValue
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Stack(
                    children: [
                      ValueListenableBuilder<List<PlutoRow>>(
                        valueListenable: widget.displayedItems,
                        builder: (context, items, child) {
                          return ListView.separated(
                            controller: widget.scrollController,
                            padding: const EdgeInsets.all(10),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final row = items[index];
                              return ValueListenableBuilder<bool>(
                                valueListenable: widget.isDisplayed[row]!,
                                builder: (context, isChecked, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? const Color(0xFFE0F2FE)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isChecked
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: CheckboxListTile(
                                      dense: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      activeColor: const Color(0xFF2563EB),
                                      checkColor: Colors.white,
                                      title: Text(
                                        '${row.cells[widget.column.field]!.value ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isChecked
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      value: isChecked,
                                      onChanged: (value) {
                                        widget.toggleAttributeVisibility(
                                            row, value, widget.column);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.isLoadingMore,
                        builder: (context, isLoadingMoreValue, child) {
                          return isLoadingMoreValue
                              ? const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
          );
        },
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Clear all rows in the stateManager
                widget.stateManager.removeAllRows();

                // Ensure unique rows in filterRows
                final Set<PlutoRow> uniqueValues = {};
                uniqueValues.addAll(widget.filterRows);
                widget.filterRows.clear();
                widget.filterRows.addAll(uniqueValues);

                // Remove the "All" row if present
                widget.filterRows.removeWhere((row) => row
                    .cells[widget.column.field]!.value
                    .toString()
                    .contains(AppLocalizations.of(context)!.all));

                // Find the column field for the numbering column (e.g., "#")
                // Try to find the numbering column (#), or return null if not found
                // Check for the numbering column (#)
                final numberingColumn = widget.stateManager.columns.firstWhere(
                  (col) => col.title == "#",
                  orElse: () => PlutoColumn(
                      title: "",
                      field: "",
                      type: PlutoColumnType
                          .text()), // Return null if the column does not exist
                );

                if (numberingColumn != null) {
                  // Proceed with renumbering if the numbering column exists
                  final numberingColumnField = numberingColumn.field;

                  for (int i = 0; i < widget.filterRows.length; i++) {
                    if (widget.filterRows[i].cells
                        .containsKey(numberingColumnField)) {
                      widget.filterRows[i].cells[numberingColumnField]!.value =
                          (i + 1).toString();
                    }
                  }
                } else {
                  // Handle the case where the # column does not exist (optional)
                  debugPrint("Numbering column '#' not found.");
                }

                widget.stateManager.appendRows(widget.filterRows);

                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
            const SizedBox(
              width: 15,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      ],
    );
  }
}
