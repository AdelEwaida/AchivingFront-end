import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/key.dart';
import 'package:archiving_flutter_project/utils/func/text_and_number_inputFormater.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class TableComponent extends StatefulWidget {
  final List<PlutoColumn> plCols;
  final List<PlutoRow> polRows;
  final Widget Function(PlutoGridStateManager stateManager)? footerBuilder;
  final Function(PlutoGridOnSelectedEvent event)? onSelected;
  final Function(PlutoGridOnChangedEvent event)? onChange;
  final Function()? add;
  int? count;
  final Function(String)? search;
  final Function()? delete;
  final Function()? exportToExcel;
  final Function()? download;
  final Function()? chooseDep;
  final Function()? editPassword;
  final Function()? genranlEdit;
  final Function()? view;
  final Function()? advanceSearch;
  final Function()? viewLocation;
  final Function()? pollScreen;
  final Function()? addReminder;
  final Function()? upload;
  final Function()? explor;
  final Function()? copy;
  final Function()? generalDownload;

  final Function(PlutoGridOnLoadedEvent event)? onLoaded;
  final Function(PlutoGridOnRowDoubleTapEvent event)? doubleTab;
  final Function(PlutoGridOnRowSecondaryTapEvent event)? rightClickTap;
  final Function(PlutoGridStateManager event)? headerBuilder;
  final Function(PlutoGridOnRowCheckedEvent event)? handleOnRowChecked;
  bool? isWhiteText = false;
  PlutoGridMode? mode;
  Color? borderColor;
  double? rowsHeight;
  double? tableHeigt;
  double? tableWidth;
  double? columnHeight;
  PlutoGridEnterKeyAction? moveAfterEditng;
  Color Function(PlutoRowColorContext)? rowColor;
  // PlutoGridStateManager stateManger;
  Key? key;
  TableComponent(
      {this.key,
      this.viewLocation,
      this.download,
      this.explor,
      this.chooseDep,
      this.copy,
      this.tableHeigt,
      this.upload,
      this.tableWidth,
      this.pollScreen,
      this.addReminder,
      this.exportToExcel,
      this.advanceSearch,
      this.genranlEdit,
      this.view,
      this.editPassword,
      this.add,
      this.delete,
      this.count,
      this.search,
      required this.plCols,
      required this.polRows,
      this.onSelected,
      this.columnHeight,
      this.footerBuilder,
      this.isWhiteText,
      this.doubleTab,
      this.rightClickTap,
      this.headerBuilder,
      this.onLoaded,
      this.mode,
      this.onChange,
      this.handleOnRowChecked,
      this.borderColor,
      this.rowsHeight,
      this.moveAfterEditng,
      this.rowColor,
      this.generalDownload
      // required this.stateManger
      });
  @override
  State<TableComponent> createState() => _TableComponentState();
}

class _TableComponentState extends State<TableComponent> {
  double width = 0;
  double height = 0;
  double scrollThickness = 10;
  double scrollRadius = 10;
  late final PlutoGridStateManager stateManager;
  late AppLocalizations locale;
  List<PlutoRow> tempRow = [];
  late ScreenContentProvider screenContentProvider;
  @override
  void didChangeDependencies() {
    locale = AppLocalizations.of(context)!;
    screenContentProvider = context.read<ScreenContentProvider>();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ValueNotifier rowsLength = ValueNotifier(0);
  late PlutoGridConfiguration configuration;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    List<PlutoColumn> polCols = widget.plCols;
    List<PlutoRow> polRows = widget.polRows;

    int maxNumber = 1;
    configuration = PlutoGridConfiguration(
      localeText: PlutoGridLocaleText(
          freezeColumnToStart: locale.freezeColumnToStart,
          freezeColumnToEnd: locale.freezeColumnToEnd,
          autoFitColumn: locale.autoFit,
          hideColumn: locale.hideColumn,
          setColumns: locale.setColumns,
          setFilter: locale.setFilter,
          resetFilter: locale.resetFilter,
          filterColumn: locale.tableColumn,
          filterType: locale.type,
          filterValue: locale.value,
          filterContains: locale.contains,
          filterEquals: locale.equals,
          filterEndsWith: locale.endsWith,
          filterLessThan: locale.lessThan,
          filterGreaterThan: locale.greaterThan,
          filterGreaterThanOrEqualTo: locale.greaterThanOrEqual,
          filterStartsWith: locale.startsWith,
          filterLessThanOrEqualTo: locale.lessThanOrEqual),
      enableMoveHorizontalInEditing: true,
      enterKeyAction:
          widget.moveAfterEditng ?? PlutoGridEnterKeyAction.editingAndMoveDown,
      // tabKeyAction: PlutoGridTabKeyAction.normal,
      columnSize:
          const PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.none),
//localeText: PlutoGridLocaleText(filterContains: locale.contains),
      scrollbar: PlutoGridScrollbarConfig(
        onlyDraggingThumb: false,
        scrollbarThicknessWhileDragging: 20,
        draggableScrollbar: true,
        isAlwaysShown: true,
        scrollBarColor: primary2,
        scrollbarThickness: scrollThickness,
        scrollbarRadius: Radius.circular(scrollRadius),
      ),
      style: PlutoGridStyleConfig(
        evenRowColor: Colors.grey[100],
        oddRowColor: Colors.white,
        activatedBorderColor:
            const Color.fromARGB(255, 37, 171, 233).withOpacity(0.5),
        activatedColor:
            const Color.fromARGB(255, 37, 171, 233).withOpacity(0.5),
        enableCellBorderVertical: false,
        enableGridBorderShadow: true,
        gridBorderColor: widget.borderColor == null
            ? const Color(0xFFA1A5AE)
            : widget.borderColor!,
        menuBackgroundColor: Colors.white,
        // columnHeight: maxNumber == 2
        //     ? 40
        //     : maxNumber == 3
        //         ? 55
        //         : 70,
        columnHeight: widget.columnHeight ?? 45,
        columnFilterHeight: 30,

        columnTextStyle: TextStyle(
            fontSize: 10,
            color: widget.isWhiteText ?? false ? Colors.white : Colors.black,
            letterSpacing: 1),
        rowHeight: widget.rowsHeight ?? 25,
        cellTextStyle: const TextStyle(
          fontSize: 10,
          color: Colors.black,
        ),
      ),
    );
    for (int i = 0; i < polCols.length; i++) {
      int length = polCols[i].title.split(" ").length;
      if (length > maxNumber) {
        maxNumber = length;
      }
      // String title = specialColumnsWidth(polCols, i, locale)
      //     ? polCols[i].title
      //     : longSentenceWidth(polCols, i, locale)
      //         ? '${polCols[i].title.split(' ').take(2).join(' ')}\n${polCols[i].title.split(' ').skip(2).join(' ')}'
      //         : polCols[i].title.replaceAll(" ", "\n");
      // _locale.lastPricePurchase
      polCols[i].titleSpan = TextSpan(
        children: [
          WidgetSpan(
            child: Text(
              polCols[i].title,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      );
      polCols[i].titleTextAlign = PlutoColumnTextAlign.center;
      polCols[i].textAlign = PlutoColumnTextAlign.center;
    }
    return Column(
      children: [
        headerTable(),
        SizedBox(
            height: widget.tableHeigt,
            width: widget.tableWidth,
            child: PlutoGrid(
              // key: UniqueKey(),
              columnMenuDelegate: _CustomColumnMenu(rows: tempRow),
              // columnMenuDelegate: PlutoColumnMenuDelegateDefault(),
              configuration: configuration,
              createFooter: (stateManager) {
                if (widget.footerBuilder != null) {
                  return widget.footerBuilder!(stateManager);
                }
                return const SizedBox();
              },
              columns: polCols,
              rows: polRows,
              mode: widget.mode != null
                  ? widget.mode!
                  : PlutoGridMode.selectWithOneTap,
              onRowDoubleTap: widget.doubleTab != null
                  ? (event) {
                      widget.doubleTab!(event);
                    }
                  : null,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                if (widget.onLoaded != null) {
                  widget.onLoaded!(event);
                }
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                if (widget.onChange != null) {
                  widget.onChange!(event);
                }
              },
              onSelected: (event) {
                if (widget.onSelected != null) {
                  widget.onSelected!(event);
                }
              },
              rowColorCallback: widget.rowColor,
              // rowColorCallback: widget.rowColor,
              noRowsWidget: const Center(
                child: Text("No data available."),
              ),
              onRowSecondaryTap: (event) {
                if (widget.rightClickTap != null) {
                  widget.rightClickTap!(event);
                }
              },
              createHeader: (stateManager) {
                if (widget.headerBuilder != null) {
                  return widget.headerBuilder!(stateManager);
                }
                return const SizedBox();
              },
              onRowChecked: widget.handleOnRowChecked,
            )),
      ],
    );
  }

  Widget headerTable() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.search != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchField(
                      horizontalPadding: 0,
                      width: width * .35,
                      label: locale.search,
                      padding: 7,
                      inputFormatters: [MyInputFormatter()],
                      onChanged: (value) {
                        //If input is white-space
                        if (value.isNotEmpty &&
                            value[value.length - 1] == " ") {
                          // isSearching = true;
                          // isEnteredSearch = true;
                          // isLoadingData.value = true;
                          widget.search!(value);
                        }

                        /*If searched previously and delete the inputs in the search field will called
                          the search method  but if enter inputs in the search field and delete it without searching for,
                           there is no change in the table occur
                         */
                        // if (value.isEmpty && isEnteredSearch) {
                        //   isSearching = true;
                        //   isEnteredSearch = false;
                        //   isLoadingData.value = true;

                        //   searchItem().then((value) {
                        //     isSearching = false;
                        //   });
                        // }
                        // if (value == " " || value.trim().isEmpty) {
                        //   isFirstSpace = false;

                        //   stateManager!.removeAllRows();
                        //   stateManager!.appendRows(rowList);

                        //   itemsNumberDisplayed.value = stateManager!.rows.length;
                        // }
                        if (value == " " ||
                            value.trim().isEmpty ||
                            value.isEmpty) {
                          // if (isFirstSpace) {
                          //   isFirstSpace = false;
                          //   isSearching = true;
                          //   isEnteredSearch = true;
                          //   isLoadingData.value = true;

                          //   searchItem().then((value) {
                          //     isSearching = false;
                          //   });
                          // }
                          widget.search!(value);
                        } else if (value.isNotEmpty &&
                            value.length > 1 &&
                            value[value.length - 1] == " ") {
                          widget.search!(value);

                          // if (isFirstSpace) {
                          //   final arabicNumbers = [
                          //     '٠',
                          //     '١',
                          //     '٢',
                          //     '٣',
                          //     '٤',
                          //     '٥',
                          //     '٦',
                          //     '٧',
                          //     '٨',
                          //     '٩'
                          //   ];
                          //   if (value.isNotEmpty &&
                          //       arabicNumbers.any((numeral) => value.contains(numeral))) {
                          //     value = Converters.replaceArabicNumbers(value);
                          //     textEditingControllerSearch.value =
                          //         textEditingControllerSearch.value.copyWith(
                          //       text: value,
                          //       selection: TextSelection.collapsed(offset: value.length),
                          //       composing: TextRange.empty,
                          //     );
                          //   }
                          //   isFirstSpace = false;
                          //   isSearching = true;
                          //   isEnteredSearch = true;
                          //   isLoadingData.value = true;

                          //   searchItem().then((value) {
                          //     isSearching = false;
                          //   });
                          // }
                        } else if (value.isEmpty) {
                          widget.search!(value);

                          // isFirstSpace = true;
                        } else {
                          // isFirstSpace = true;
                        }
                      },
                      onSubmitted: ((value) {
                        // value = Converters.replaceArabicNumbers(value);
                        // textEditingControllerSearch.text = value;
                        // isSearching = true;
                        // isEnteredSearch = true;
                        // isLoadingData.value = true;

                        // searchItem().then((value) {
                        //   isSearching = false;
                        // });
                      }),
                      controller: TextEditingController(),
                    ),
                    // Text(rowsLength.value.toString()),
                  ],
                )
              : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tooltip(
              //   message: locale.refresh,
              //   child: IconButton(
              //       onPressed: () {
              //         setState(() {
              //           // screenContentProvider
              //           //     .setLastPage(screenContentProvider.getPage());
              //           // screenContentProvider.setPage1(0);
              //           widget.search!("");
              //           screenContentProvider
              //               .setPage1(screenContentProvider.getPage());
              //         });
              //       },
              //       icon: const Icon(Icons.refresh)),
              // ),

              widget.genranlEdit != null
                  ? Tooltip(
                      message: locale.edit,
                      child: IconButton(
                          onPressed: () {
                            // dealsProvider.clearProvider();
                            // dealsProvider.clearCampModel();
                            widget.genranlEdit!();
                            // dealsProvider.loadedList = rowList;
                            // dealsProvider.pageNum = pageLis.value;
                            // // screenProvider.setPage(32);
                            // tabsProvider.changeActiveWidget(32, locale);
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.generalDownload != null
                  ? Tooltip(
                      message: locale.download,
                      child: IconButton(
                          onPressed: () {
                            // dealsProvider.clearProvider();
                            // dealsProvider.clearCampModel();
                            widget.generalDownload!();
                            // dealsProvider.loadedList = rowList;
                            // dealsProvider.pageNum = pageLis.value;
                            // // screenProvider.setPage(32);
                            // tabsProvider.changeActiveWidget(32, locale);
                          },
                          icon: const Icon(
                            Icons.download,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.chooseDep != null
                  ? Tooltip(
                      message: locale.chooseListOfDepartment,
                      child: IconButton(
                          onPressed: () {
                            widget.chooseDep!();
                            // dealsProvider.clearProvider();
                            // dealsProvider.clearCampModel();

                            // dealsProvider.loadedList = rowList;
                            // dealsProvider.pageNum = pageLis.value;
                            // // screenProvider.setPage(32);
                            // tabsProvider.changeActiveWidget(32, locale);
                          },
                          icon: const Icon(
                            Icons.store_mall_directory_outlined,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.explor != null
                  ? Tooltip(
                      message: locale.documentExplorer,
                      child: IconButton(
                          onPressed: () {
                            widget.explor!();
                            // dealsProvider.clearProvider();
                            // dealsProvider.clearCampModel();

                            // dealsProvider.loadedList = rowList;
                            // dealsProvider.pageNum = pageLis.value;
                            // // screenProvider.setPage(32);
                            // tabsProvider.changeActiveWidget(32, locale);
                          },
                          icon: const Icon(
                            Icons.travel_explore_sharp,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.copy != null
                  ? Tooltip(
                      message: locale.copy,
                      child: IconButton(
                          onPressed: () {
                            widget.copy!();
                            // dealsProvider.clearProvider();
                            // dealsProvider.clearCampModel();

                            // dealsProvider.loadedList = rowList;
                            // dealsProvider.pageNum = pageLis.value;
                            // // screenProvider.setPage(32);
                            // tabsProvider.changeActiveWidget(32, locale);
                          },
                          icon: const Icon(
                            Icons.copy,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.view != null
                  ? Tooltip(
                      message: locale.view,
                      child: IconButton(
                          onPressed: () {
                            widget.view!();
                            // dealsProvider.clearProvider();
                            // dealsProvider.clearCampModel();

                            // dealsProvider.loadedList = rowList;
                            // dealsProvider.pageNum = pageLis.value;
                            // // screenProvider.setPage(32);
                            // tabsProvider.changeActiveWidget(32, locale);
                          },
                          icon: const Icon(
                            Icons.remove_red_eye,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.exportToExcel != null
                  ? Tooltip(
                      message: locale.exportToExcel,
                      child: IconButton(
                          onPressed: () async {
                            widget.exportToExcel!();
                            // dealsProvider.clearProvider();
                            // if (selectedCampLogsModel != null) {
                            //   dealsProvider.loadedList = rowList;
                            //   dealsProvider.pageNum = pageLis.value;

                            //   String key = selectedCampLogsModel!.txtKey!;
                            //   ModifiedItemSearchCriteria modifiedItemSearchCriteria =
                            //       ModifiedItemSearchCriteria(hdrKey: key);
                            //   CampSaveModel? campSaveModel;
                            //   stateManager!.setShowLoading(true);

                            //   await LogsController()
                            //       .getModifiedCampaign(modifiedItemSearchCriteria)
                            //       .then((value) {
                            //     campSaveModel = value;
                            //     campSaveModel!.setCampLogModel(selectedCampLogsModel!);

                            //     dealsProvider.setCampSaveModel(campSaveModel);

                            //     stateManager!.setShowLoading(false);
                            //     if (campSaveModel != null &&
                            //         campSaveModel!.discountLines!.isNotEmpty) {
                            //       tabsProvider.changeActiveWidget(32, locale);
                            //     }
                            //   });
                            // } else {
                            //   CoolAlert.show(
                            //     width: width * 0.4,
                            //     context: context,
                            //     type: CoolAlertType.warning,
                            //     title: locale.chooseTransaction,
                            //     text: locale
                            //         .chooseTransToEdit, // Customize the message as needed
                            //     confirmBtnText: locale.ok,
                            //     onConfirmBtnTap: () {
                            //       // Navigator.pop(context); // Close the alert
                            //     },
                            //   );
                            // }
                          },
                          icon: const Icon(
                            Icons.description,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.advanceSearch != null
                  ? Tooltip(
                      message: locale.advanceSearch,
                      child: IconButton(
                          onPressed: () {
                            widget.advanceSearch!();
                          },
                          icon: const Icon(
                            Icons.search,
                            size: 20,
                          )),
                    )
                  : SizedBox.shrink(),
              widget.add != null && widget.viewLocation == null
                  ? Tooltip(
                      message: locale.add,
                      child: IconButton(
                          onPressed: () {
                            widget.add!();
                          },
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                          )),
                    )
                  : const SizedBox.shrink(),
              widget.editPassword != null
                  ? Tooltip(
                      message: locale.editPassword,
                      child: IconButton(
                          onPressed: () {
                            widget.editPassword!();
                          },
                          icon: const Icon(
                            // color: redColor,
                            Icons.password_outlined,
                            size: 20,
                          )),
                    )
                  : const SizedBox.shrink(),
              widget.delete != null
                  ? Tooltip(
                      message: locale.delete,
                      child: IconButton(
                          onPressed: () {
                            widget.delete!();
                          },
                          icon: Icon(
                            color: redColor,
                            Icons.delete,
                            size: 20,
                          )),
                    )
                  : const SizedBox.shrink(),
              widget.upload != null
                  ? Tooltip(
                      message: locale.uploadFile,
                      child: IconButton(
                          onPressed: () {
                            widget.upload!();
                          },
                          icon: const Icon(
                            // color: redColor,
                            Icons.upload_rounded,
                            size: 20,
                          )),
                    )
                  : const SizedBox.shrink(),
              widget.addReminder != null
                  ? Tooltip(
                      message: locale.addReminder,
                      child: IconButton(
                          onPressed: () {
                            widget.addReminder!();
                          },
                          icon: const Icon(
                            Icons.remember_me_sharp,
                            size: 20,
                          )),
                    )
                  : const SizedBox.shrink(),
              widget.download != null
                  ? Tooltip(
                      message: locale.download,
                      child: IconButton(
                          onPressed: () {
                            widget.download!();
                          },
                          icon: const Icon(
                            Icons.download,
                            size: 20,
                          )),
                    )
                  : const SizedBox.shrink(),
              widget.viewLocation != null
                  ? IconButton(
                      onPressed: () {
                        widget.viewLocation!();
                      },
                      icon: const Icon(
                        Icons.location_on,
                        size: 20,
                      ))
                  : const SizedBox.shrink(),
              SizedBox(
                width: width * .01,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CustomColumnMenuItem {
  addAutoFitColumn,
  // unfreeze,
  freezeToStart,
  freezeToEnd,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
  cancelAutoFit
}

// ignore: must_be_immutable
class _CustomColumnMenu extends StatelessWidget
    implements PlutoColumnMenuDelegate<_CustomColumnMenuItem> {
  // late TabsProvider tabsProvider;

  final context = navigatorKey.currentState!.overlay!.context;

  // late PlutoGridConfiguration configuration;
  List<PlutoRow> rows;

  _CustomColumnMenu({required this.rows});
  @override
  List<PopupMenuEntry<_CustomColumnMenuItem>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  }) {
    return [
      if (column.key != stateManager.columns.first.key)
        PopupMenuItem<_CustomColumnMenuItem>(
          value: _CustomColumnMenuItem.addAutoFitColumn,
          height: 36,
          enabled: true,
          child: Text(AppLocalizations.of(context)!.autoFitAllColumns,
              style: TextStyle(fontSize: 13)),
        ),
      // const PopupMenuItem<_CustomColumnMenuItem>(
      //   value: _CustomColumnMenuItem.unfreeze,
      //   height: 36,
      //   enabled: true,
      //   child: Text('Unfreeze', style: TextStyle(fontSize: 13)),
      // ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.freezeToStart,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.freezeColumnToStart,
            style: TextStyle(fontSize: 13)),
      ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.freezeToEnd,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.freezeColumnToEnd,
            style: TextStyle(fontSize: 13)),
      ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.hideColumn,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.hideColumn,
            style: TextStyle(fontSize: 13)),
      ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.setColumns,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.setColumns,
            style: TextStyle(fontSize: 13)),
      ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.autoFit,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.autoFit,
            style: TextStyle(fontSize: 13)),
      ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.setFilter,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.setFilter,
            style: TextStyle(fontSize: 13)),
      ),
      PopupMenuItem<_CustomColumnMenuItem>(
        value: _CustomColumnMenuItem.resetFilter,
        height: 36,
        enabled: true,
        child: Text(AppLocalizations.of(context)!.resetFilter,
            style: TextStyle(fontSize: 13)),
      ),
      // PopupMenuItem<_CustomColumnMenuItem>(
      //   value: _CustomColumnMenuItem.resetFilter,
      //   height: 36,
      //   enabled: true,
      //   child: Text(AppLocalizations.of(context)!.cancelAutoFitAllColumns,
      //       style: TextStyle(fontSize: 13)),
      // ),
    ];
  }

  List<PlutoRow> filterRows = [];
  Map<PlutoRow, ValueNotifier<bool>> isDisplayed = {};

  @override
  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required _CustomColumnMenuItem? selected,
  }) {
    // tabsProvider = context.read<TabsProvider>();

    // ignore: unused_local_variable
    Map<PlutoColumn, double> originalColumnWidths = {};
    // List<PlutoRow> rows = [];
    // for (final row in this.rows) {
    //   rows.add(row);
    // }
    // ignore: unnecessary_null_comparison
    switch (selected) {
      case _CustomColumnMenuItem.addAutoFitColumn:
        for (final col in stateManager.columns) {
          stateManager.autoFitColumn(context, col);
        }

        stateManager.notifyResizingListeners();
        break;

      case _CustomColumnMenuItem.freezeToStart:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.start);
        break;
      case _CustomColumnMenuItem.freezeToEnd:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.end);
        break;
      case _CustomColumnMenuItem.hideColumn:
        stateManager.hideColumn(column, true);
        break;
      case _CustomColumnMenuItem.setColumns:
        if (!mounted) return;
        stateManager.showSetColumnsPopup(context);
        break;
      case _CustomColumnMenuItem.autoFit:
        if (!mounted) return;
        stateManager.autoFitColumn(context, column);
        stateManager.notifyResizingListeners();
        break;
      case _CustomColumnMenuItem.setFilter:
        if (!mounted) return;
        // FilterHelper.filterPopup(
        //   FilterPopupState(
        //     context: context,
        //     configuration: PlutoGridConfiguration(),
        //     handleAddNewFilter: (filterState) {
        //       filterState!.appendRows([FilterHelper.createFilterRow()]);
        //     },
        //     handleApplyFilter: (filterState) {
        //       setFilterWithFilterRows(filterState!.rows);
        //     },
        //     columns: stateManager.columns,
        //     filterRows: rows,
        //     focusFirstFilterValue: shouldProvideDefaultFilterRow,
        //     onClosed: onClosed,
        //   ),
        // );
        showColumnAttributesPopup(context, column, stateManager);
        // stateManager.showFilterPopup(context, calledColumn: column);
        // stateManager.setFilterRows(rows);
        break;
      case _CustomColumnMenuItem.resetFilter:

        // stateManager.removeAllRows();
        // tabsProvider.changeActiveWidget(pageNumber, name, locale)
        // cancelFillter();

        // stateManager.appendRows(rows);
        stateManager.notifyListeners(true);
        // stateManager.setFilter(null);
        break;
      // case _CustomColumnMenuItem.cancelAutoFit:
      //   for (final col in stateManager.columns) {
      //     stateManager.autoFitColumn(context, col);

      //   }
      //   stateManager.notifyResizingListeners();
      //   break;

      case null:
        break;
      case _CustomColumnMenuItem.cancelAutoFit:
        // TODO: Handle this case.
        break;
    }
  }

  // void cancelFillter() {
  //   for (int i = 0; i < tabsProvider.getPages().length; i++) {
  //     if (tabsProvider.getPages()[i].value ==
  //         tabsProvider.getActivePage(AppLocalizations.of(context)!).value) {
  //       tabsProvider.changeActiveWidgetByNewWidget(
  //           PagesController.contentPageByText(tabsProvider.getPages()[i].value,
  //               AppLocalizations.of(context)!));

  //       // tabsProvider.changeActiveWidget(i, AppLocalizations.of(context)!);
  //     }
  //   }
  // }

  ValueNotifier selectAll = ValueNotifier(true);
  ValueNotifier loading = ValueNotifier(false);
  void showColumnAttributesPopup(
    BuildContext context,
    PlutoColumn column,
    PlutoGridStateManager stateManager,
  ) async {
    loading.value = true;
    getColumnAttributes(column, stateManager);
    loading.value = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.setFilter),
          content: ValueListenableBuilder(
            valueListenable: loading,
            builder: (context, value, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: isDisplayed.keys.map((element) {
                    return ValueListenableBuilder(
                      valueListenable: isDisplayed[element]!,
                      builder: (context, value, child) {
                        return CheckboxListTile(
                          activeColor: dBar,

                          title: Text(
                              element.cells[column.field]!.value.toString()),
                          value: isDisplayed[element]!
                              .value, // Implement this function
                          onChanged: (bool? value) {
                            if (element.cells[column.field]!.value.toString() ==
                                AppLocalizations.of(context)!.all) {
                              if (!value!) {
                                filterRows.clear();
                                for (var row in isDisplayed.keys) {
                                  toggleAttributeVisibility(row, value, column);
                                }
                                // for (int i = 0;
                                //     i < stateManager.rows.length;
                                //     i++) {
                                //   toggleAttributeVisibility(
                                //       stateManager.rows[i], value);
                                // }
                                // isDisplayed.keys.map((e) {
                                //   // isDisplayed[e]!.value = false;
                                // });
                              } else {
                                filterRows.clear();
                                for (var row in isDisplayed.keys) {
                                  toggleAttributeVisibility(row, value, column);
                                }
                              }
                            }
                            // Implement logic to toggle attribute visibility
                            toggleAttributeVisibility(element, value, column);
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
                // child: Column(
                //   // children: attributes.map((attribute) {
                //   //   return ValueListenableBuilder(
                //   //     valueListenable: ,
                //   //     child: CheckboxListTile(
                //   //       title: Text(attribute.cells[column.field]!.value),
                //   //       value: isAttributeDisplayed(attribute),
                //   //       onChanged: (bool? value) {
                //   //         print('Checkbox onChanged called with value: $value');

                //   //         toggleAttributeVisibility(attribute, value);
                //   //       },
                //   //     ),
                //   //   );
                //   // }).toList(),
                // ),
              );
            },
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    stateManager.removeAllRows();

                    //           rowGroup.forEach((key, value) {
                    //             print(value[0].toJson());
                    //             print(value[1].toJson());
                    // for (int i = 0; i < filterRows.length;i++){
                    //   if(filterRows[i].cells)
                    // }
                    //             if (value.isNotEmpty) {
                    //               for (int i = 0; i < value.length; i++) {
                    //                 if (value[i].cells[column.field]!.value !=
                    //                     AppLocalizations.of(context)!.all) {
                    //                   filterRows.add(value[i]);
                    //                 }
                    //               }
                    //             }
                    //             // if(val)
                    //           });
                    final Set<PlutoRow> uniqueValues = {};
                    uniqueValues.addAll(filterRows);
                    filterRows.clear();
                    filterRows.addAll(uniqueValues);
                    if (filterRows.isNotEmpty) {
                      //to remove all option from filter rows: because i need all option as row like attrbuite
                      for (int i = 0; i < filterRows.length; i++) {
                        if (filterRows[i].cells[column.field]!.value ==
                            AppLocalizations.of(context)!.all) {
                          filterRows.removeAt(i);
                        }
                      }
                    }

                    // filterRows.map((e) => print(e.toJson()));
                    stateManager.appendRows(filterRows);
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
                TextButton(
                  onPressed: () {
                    // stateManager.removeAllRows();
                    // List<PlutoRow> lis = [];

                    // //           rowGroup.forEach((key, value) {
                    // //             print(value[0].toJson());
                    // //             print(value[1].toJson());
                    // // for (int i = 0; i < filterRows.length;i++){
                    // //   if(filterRows[i].cells)
                    // // }
                    // //             if (value.isNotEmpty) {
                    // //               for (int i = 0; i < value.length; i++) {
                    // //                 if (value[i].cells[column.field]!.value !=
                    // //                     AppLocalizations.of(context)!.all) {
                    // //                   filterRows.add(value[i]);
                    // //                 }
                    // //               }
                    // //             }
                    // //             // if(val)
                    // //           });
                    // final Set<PlutoRow> uniqueValues = {};
                    // uniqueValues.addAll(filterRows);
                    // filterRows.clear();
                    // filterRows.addAll(uniqueValues);
                    // if (filterRows.isNotEmpty) {
                    //   //to remove all option from filter rows: because i need all option as row like attrbuite
                    //   for (int i = 0; i < filterRows.length; i++) {
                    //     if (filterRows[i].cells[column.field]!.value ==
                    //         AppLocalizations.of(context)!.all) {
                    //       filterRows.removeAt(i);
                    //     }
                    //   }
                    // }

                    // // filterRows.map((e) => print(e.toJson()));
                    // stateManager.appendRows(filterRows);
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Map<String, List<PlutoRow>> rowGroup = {};

  List<PlutoRow> getColumnAttributes(
    PlutoColumn column,
    PlutoGridStateManager stateManager,
  ) {
    final Set<String> uniqueValues = {};

    List<PlutoRow> attributes = [];
    if (isDisplayed.isEmpty) {
      //to add option all and display it
      final Map<String, PlutoCell> allModel = <String, PlutoCell>{};
      allModel[column.field] =
          PlutoCell(value: AppLocalizations.of(context)!.all);
      isDisplayed[PlutoRow(cells: allModel)] = ValueNotifier(true);
    }
    for (var row in stateManager.rows) {
      // Get the value of the specified column in the current row
      final value = row.cells[column.field]?.value.toString();
      filterRows.add(row);

      // Check if the value is not null

      if (value != null) {
        // Add the value to the uniqueValues set
        //to display just unique value with out duplicate
        final cellValue = PlutoCell(value: value.toString());
        final newRow = PlutoRow(cells: {column.field: cellValue});
        uniqueValues.add(value.toString());

        //if the value exist add to list that has same key
        if (rowGroup[value] != null) {
          rowGroup[value]!.add(row);
        } else {
          //if the value not exist make new opject and add  list that has same key (key and value is same)
          rowGroup[value] = [row];
        }
      }
    }
    bool exist = false;
    for (var value in uniqueValues) {
      // Create a PlutoRow with the value of the column as the cell value
      final cellValue = PlutoCell(value: value.toString());
      final newRow = PlutoRow(cells: {column.field: cellValue});
      print("newRow.toJson() 11 ${newRow.toJson()}");
      // Check if the new row is already in the isDisplayed map
      for (var key in isDisplayed.entries) {
        if (key.key.cells[column.field]!.value ==
            newRow.cells[column.field]!.value) {
          print("newRow.toJson() 22 ${key.key.toJson()}");

          exist = true;
        }
      }
      if (!exist) {
        // Add the PlutoRow to the isDisplayed map and set its ValueNotifier to true as default
        isDisplayed[newRow] = ValueNotifier(true);
      }
    }
    //   print(key.key.toJson());
    // }
    return attributes;
  }

  void priiint(column) {}

  void toggleAttributeVisibility(
      PlutoRow attribute, bool? value, PlutoColumn column) {
    if (value != null) {
      if (value) {
        if (attribute.cells[column.field]!.value ==
            AppLocalizations.of(context)!.all) {
          rowGroup.keys.map((e) {
            filterRows.addAll(rowGroup[e]!);
          });
        } else {
          filterRows.addAll(rowGroup[attribute.cells[column.field]!.value]!);
        }
      } else {
        if (rowGroup.isNotEmpty) {
          if (attribute.cells[column.field]!.value ==
              AppLocalizations.of(context)!.all) {
            filterRows.clear();
          } else {
            filterRows.removeWhere((row) =>
                rowGroup[attribute.cells[column.field]!.value]!.contains(row));
          }
        }

        // filterRows.remove(rowGroup[attribute.cells[column.field]]!);
      }

      isDisplayed[attribute]!.value = value;
    }
  }

// Update the isAttributeDisplayed function
  bool isAttributeDisplayed(PlutoRow attribute) {
    // Check if the key exists in the map
    return isDisplayed.containsKey(attribute);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
