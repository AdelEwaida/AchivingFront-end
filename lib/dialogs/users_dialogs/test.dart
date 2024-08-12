import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../../models/db/user_models/user_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../providers/user_provider.dart';
import '../../service/controller/users_controller/user_controller.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/text_and_number_inputFormater.dart';
import '../../widget/table_component/table_component.dart';
import '../../widget/text_field_widgets/custom_searchField.dart';

class UserSelectionDialog extends StatefulWidget {
  final int? index;
  const UserSelectionDialog({
    this.index,
    super.key,
  });

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  late AppLocalizations _local;
  TextEditingController searchName = TextEditingController();
  TextEditingController searchCode = TextEditingController();
  TextEditingController searchBarCode = TextEditingController();

  late PlutoGridStateManager stateManager;
  ValueNotifier isLoading = ValueNotifier(true);
  bool isSearching = false;
  UserController _userController = UserController();
  List<UserModel> _availableUsers = [];
  late UserProvider filterProvider;
  ValueNotifier pageLis = ValueNotifier(1);
  ValueNotifier serachPageLis = ValueNotifier(1);

  ValueNotifier selectAll = ValueNotifier(false);
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool isEnteredSearch = false;

  bool bolIsLooding = false;
  int isSuppStock = 0;
  List<PlutoRow> rowList = [];
  List<PlutoRow> rowList2 = [];

  ValueNotifier itemsNumber = ValueNotifier(0);
  @override
  void didChangeDependencies() {
    _local = AppLocalizations.of(context)!;

    filterProvider = context.read<UserProvider>();

    itemsNumber.value = filterProvider.selectedUsers.length;

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Perform cleanup tasks in the dispose method.
    setState(() {
      isSearching = true;
    });
    super.dispose(); // Call the super class's dispose method if necessary.
  }

  double width = 0;
  double height = 0;
  List<UserModel> selectedCustCategModels = [];

  List<PlutoColumn> polCols = [];
  bool isFirstSpace = true;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth * 0.45;
    final double dialogheight = screenHeight * 0.85;
    polCols = UserModel.getColumnsForDialogSearchFillter(
        AppLocalizations.of(context)!, context);
    return bolIsLooding
        ? CircularProgressIndicator()
        : AlertDialog(
            content: SizedBox(
              width: dialogWidth,
              height: dialogheight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Text(_local.search),
                      Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color.fromARGB(255, 237, 34, 20)),
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // CustomSearchField(
                      //   inputFormatters: [MyInputFormatter()],
                      //   width: width * .19,
                      //   label: _local.userCode,
                      //   padding: 0,
                      //   onChanged: (value) {
                      //     if (value == " " ||
                      //         value.trim().isEmpty ||
                      //         value.isEmpty) {
                      //       if (isFirstSpace) {
                      //         isFirstSpace = false;
                      //         isSearching = true;
                      //         isEnteredSearch = true;

                      //         searchItem().then((value) {
                      //           isSearching = false;
                      //         });
                      //       }
                      //     } else if (value.isNotEmpty &&
                      //         value.length > 1 &&
                      //         value[value.length - 1] == " ") {
                      //       if (isFirstSpace) {
                      //         isFirstSpace = false;
                      //         isSearching = true;
                      //         isEnteredSearch = true;

                      //         searchItem().then((value) {
                      //           isSearching = false;
                      //         });
                      //       }
                      //     } else if (value.isEmpty) {
                      //       isFirstSpace = true;
                      //     } else {
                      //       isFirstSpace = true;
                      //     }
                      //   },
                      //   onSubmitted: ((value) {
                      //     isSearching = true;
                      //     isEnteredSearch = true;

                      //     searchItem().then((value) {
                      //       isSearching = false;
                      //     });
                      //   }),
                      //   controller: searchCode,
                      // ),
                      // CustomSearchField(
                      //   inputFormatters: [MyInputFormatter()],
                      //   width: width * .19,
                      //   label: _local.byName,
                      //   padding: 0,
                      //   onChanged: (value) {
                      //     if (value == " " ||
                      //         value.trim().isEmpty ||
                      //         value.isEmpty) {
                      //       if (isFirstSpace) {
                      //         isFirstSpace = false;
                      //         isSearching = true;
                      //         isEnteredSearch = true;

                      //         searchItem().then((value) {
                      //           isSearching = false;
                      //         });
                      //       }
                      //     } else if (value.isNotEmpty &&
                      //         value.length > 1 &&
                      //         value[value.length - 1] == " ") {
                      //       if (isFirstSpace) {
                      //         isFirstSpace = false;
                      //         isSearching = true;
                      //         isEnteredSearch = true;

                      //         searchItem().then((value) {
                      //           isSearching = false;
                      //         });
                      //       }
                      //     } else if (value.isEmpty) {
                      //       isFirstSpace = true;
                      //     } else {
                      //       isFirstSpace = true;
                      //     }
                      //   },
                      //   onSubmitted: ((value) {
                      //     isSearching = true;
                      //     isEnteredSearch = true;

                      //     searchItem().then((value) {
                      //       isSearching = false;
                      //     });
                      //   }),
                      //   controller: searchName,
                      // )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  checkBox(),
                  Expanded(
                    child: TableComponent(
                      footerBuilder: (stateManager) {
                        return lazyLoadingfooter(stateManager);
                      },
                      handleOnRowChecked: (event) {
                        // handleOnRowChecked(event);
                      },
                      mode: PlutoGridMode.normal,
                      onSelected: (event) {},
                      //key: UniqueKey(),
                      plCols: polCols,
                      // ignore: prefer_const_literals_to_create_immutables
                      polRows: [],
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;

                        /// When the grid is finished loading, enable loading.
                        if (isLoading.value) {
                          stateManager.setShowLoading(true);
                        }
                        stateManager.setShowColumnFilter(true);
                      },
                      doubleTab: (event) {
                        if (event.row.checked == false) {
                          selectedCustCategModels
                              .add(UserModel.fromPlutoRow(event.row, _local));
                          stateManager.setRowChecked(event.row, true);

                          itemsNumber.value = selectedCustCategModels.length;
                        } //   filterProvider.addToStocksList(selectedStkModels);
                        //     Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // save();
                    },
                    style: customButtonStyle(Size(width * 0.09, height * 0.045),
                        18, const Color(0xff1F6E8C)),
                    child: Text(
                      _local.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              )
            ],
          );
  }

  // void save() async {
  //   FilterCriteriaModel filterCriteria = FilterCriteriaModel(
  //       suppliers: filterProvider.suppList,
  //       stockCategories: filterProvider.stockCategList,
  //       stocks: filterProvider.stocksList,
  //       supplierApplyList: [],
  //       branchApplyList: [],
  //       isSuppStock: isSuppStock,
  //       page: 0,
  //       type: stocksType);

  //   if (selectAll.value) {
  //     setState(() {
  //       bolIsLooding = true;
  //     });
  //     await StockController()
  //         .newGetStocksByStkCategories(filterCriteria)
  //         .then((value) {
  //       if (value is List<StkModel>) {
  //         filterProvider.clearBranch();
  //         filterProvider.addToitemsList(value);

  //         Navigator.pop(context);
  //       } else {
  //         Navigator.pop(context);
  //         Navigator.pop(context);

  //         // ErrorController.openErrorDialog(
  //         //   value.,
  //         //   value.body,
  //         // );
  //       }
  //     });
  //   } else {
  //     filterProvider.clearBranch();
  //     filterProvider.addToitemsList(selectedCustCategModels);

  //     Navigator.pop(context);
  //   }
  // }

  PlutoInfinityScrollRows lazyLoadingfooter(
      PlutoGridStateManager stateManager) {
    return PlutoInfinityScrollRows(
      initialFetch: true,
      fetchWithSorting: false,
      fetchWithFiltering: false,
      fetch: fetch,
      stateManager: stateManager,
    );
  }

  SearchModel getSearchCriteria(String text) {
    SearchModel dropDownSearchCriteria = SearchModel(searchField: text);
    return dropDownSearchCriteria;
  }

  Future<PlutoInfinityScrollRowsResponse> fetch(
    PlutoInfinityScrollRowsRequest request,
  ) async {
    if (searchCode.text.isEmpty && searchName.text.isEmpty) {
      List<PlutoRow> fetchedRows = [];
      List<PlutoRow> tempList = [];

      SearchModel filterCriteria = SearchModel(
        page: pageLis.value,
      );
      _availableUsers = await _userController.getUsers(filterCriteria);

      if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
        tempList = [...tempList];

        tempList.sort((a, b) {
          final sortA = request.sortColumn!.sort.isAscending ? a : b;
          final sortB = request.sortColumn!.sort.isAscending ? b : a;

          return request.sortColumn!.type.compare(
            sortA.cells[request.sortColumn!.field]!.valueForSorting,
            sortB.cells[request.sortColumn!.field]!.valueForSorting,
          );
        });
      }

      for (int i = 0; i < _availableUsers.length; i++) {
        rowList.add(_availableUsers[i].toPlutoRow(i, _local));

        fetchedRows.add(_availableUsers[i].toPlutoRow(i, _local));
      }

      if (request.lastRow == null) {
        if (pageLis.value == 1) {
          pageLis.value = pageLis.value + 1;
        }
      } else {
        pageLis.value = pageLis.value + 1;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      for (int i = 0; i < selectedCustCategModels.length; i++) {
        for (int j = 0; j < fetchedRows.length; j++) {
          if (selectedCustCategModels[i].txtCode ==
              fetchedRows[j].cells['txtCode']!.value) {
            fetchedRows.remove(fetchedRows[j]);
            rowList.remove(rowList[j]);
            break;
          }
        }
      }

      if (pageLis.value == 2) {
        List<PlutoRow> fetchedRows2 = [];
        for (int i = 0; i < fetchedRows.length; i++) {
          fetchedRows2.add(fetchedRows[i]);
        }
        fetchedRows = [];
        rowList = [];
        for (int i = 0; i < rowList2.length; i++) {
          fetchedRows.add(rowList2[i]);
          rowList.add(rowList2[i]);
          fetchedRows[i].setChecked(true);
        }
        for (int i = 0; i < fetchedRows2.length; i++) {
          rowList.add(fetchedRows2[i]);
          fetchedRows.add(fetchedRows2[i]);
        }
      }
      isLoading.value = false;

      return Future.value(PlutoInfinityScrollRowsResponse(
        isLast: false,
        rows: fetchedRows.toList(),
      ));
    } else {
      //Execute when press Enter or the input is white-space
      List<PlutoRow> searchRow = [];

      // CampaignHeaderFilterModel campaignHeaderFilterModel =
      //     CampaignHeaderFilterModel(
      //         page: serachPageLis.value,
      //         customers: [],
      //         code: searchCode.text,
      //         name: searchName.text);

      SearchModel dropDownSearchCriteria =
          SearchModel(page: -1, searchField: searchCode.text, status: -1);
      // FilterCriteriaModel filterCriteria = FilterCriteriaModel(
      //     suppliers: filterProvider.suppList,
      //     stockCategories: filterProvider.stockCategList,
      //     stocks: filterProvider.stocksList,
      //     supplierApplyList: [],
      //     branchApplyList: [],
      //     isSuppStock: isSuppStock,
      //     page: pageLis.value,
      //     type: stocksType);

      await _userController.getUsers(dropDownSearchCriteria).then((value) {
        for (int i = 0; i < value.length; i++) {
          searchRow.add(value[i].toPlutoRow(i, _local));
        }

        for (int i = 0; i < selectedCustCategModels.length; i++) {
          for (int j = 0; j < searchRow.length; j++) {
            if (selectedCustCategModels[i].txtCode ==
                searchRow[j].cells['txtCode']!.value) {
              searchRow[j].setChecked(true);
              break;
            }
          }
        }
      });
      if (request.lastRow == null) {
        if (serachPageLis.value == 1) {
          serachPageLis.value = serachPageLis.value + 1;
        }
      } else {
        serachPageLis.value = serachPageLis.value + 1;
      }

      return Future.value(PlutoInfinityScrollRowsResponse(
        isLast: false,
        rows: searchRow.toList(),
      ));
    }
  }

  checkBox() {
    return Row(
      children: [
        ValueListenableBuilder(
          builder: (context, value, child) {
            return Checkbox(
              activeColor: primary2,
              value: selectAll.value,
              onChanged: (bool? newValue) {
                selectAll.value = newValue;
                if (selectAll.value == false) {
                  for (int i = 0; i < stateManager.rows.length; i++) {
                    stateManager.rows[i].setChecked(false);
                  }
                } else {
                  for (int i = 0; i < stateManager.rows.length; i++) {
                    stateManager.setRowChecked(stateManager.rows[i], true);
                  }
                }
              },
            );
          },
          valueListenable: selectAll,
        ),
        Text(
          _local.searchByContnet,
          style: TextStyle(fontSize: width * 0.009),
        ),
      ],
    );
  }

  // Future<void> searchItem() async {
  //   List<PlutoRow> searchRow = [];
  //   serachPageLis.value = 1;
  //   print("SSSSSSSSSSSSSSSSSSSSSEEEEEEEEEARCHH");
  //   //Execute when deleting the inputs are searched for before
  //   if (searchCode.text.isEmpty &&
  //       searchName.text.isEmpty &&
  //       searchBarCode.text.isEmpty) {
  //     stateManager.removeAllRows();

  //     stateManager.setShowLoading(false);
  //     stateManager.appendRows(rowList);
  //   } else {
  //     //Execute when press Enter or the input is white-space
  //     stateManager.setShowLoading(true);
  //     FilterCriteriaModel filterCriteria;

  //     filterCriteria = FilterCriteriaModel(
  //         suppliers: [],
  //         stockCategories: [],
  //         stocks: [],
  //         supplierApplyList: [],
  //         branchApplyList: [],
  //         isSuppStock: 0,
  //         page: 1,
  //         stkCode: searchCode.text.trim(),
  //         stkName: searchName.text,
  //         stkBarcode: searchBarCode.text.trim(),
  //         viewNotActiveSell: 1,
  //         viewNotActiveAll: 1,
  //         viewNotActivePurchase: 1,
  //         type: stocksType);

  //     await StockController()
  //         .newGetStocksByStkCategories(filterCriteria)
  //         .then((value) {
  //       for (int i = 0; i < value.length; i++) {
  //         searchRow.add(value[i].toPluto(i + 1));
  //       }

  //       stateManager.removeAllRows();
  //       stateManager.appendRows(searchRow);
  //       stateManager.setShowLoading(false);
  //       serachPageLis.value = serachPageLis.value + 1;
  //     });
  //   }
  // }

  // void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
  //   if (event.isRow) {
  //     // or event.isAll

  //     if (event.isChecked == false) {
  //       for (int i = 0; i < selectedCustCategModels.length; i++) {
  //         if (selectedCustCategModels[i].txtStkcode ==
  //             event.row!.cells['txtStkcode']!.value) {
  //           selectedCustCategModels.removeAt(i);
  //           break;
  //         }
  //       }
  //     } else {
  //       selectedCustCategModels
  //           .add(StkModel().createStkModelFromRow(event.row));
  //     }

  //     itemsNumber.value = selectedCustCategModels.length;
  //   } else {
  //     bool isCheck = false;

  //     List<PlutoRow>? selectedRows = [];
  //     if (event.isChecked == false) {
  //       for (int i = 0; i < stateManager.rows.length; i++) {
  //         selectedRows.add(stateManager.rows[i]);
  //       }
  //       for (int i = 0; i < selectedRows.length; i++) {
  //         for (int j = 0; j < selectedCustCategModels.length; j++) {
  //           if (selectedCustCategModels[j].txtStkcode ==
  //               selectedRows[i].cells['txtStkcode']!.value!) {
  //             stateManager.rows[i].setChecked(true);
  //             break;
  //           }
  //         }
  //       }
  //     } else {
  //       for (int i = 0; i < stateManager.checkedRows.length; i++) {
  //         selectedRows.add(stateManager.checkedRows[i]);
  //       }
  //       for (int i = 0; i < selectedRows.length; i++) {
  //         isCheck = false;
  //         for (int j = 0; j < selectedCustCategModels.length; j++) {
  //           if (selectedCustCategModels[j].txtStkcode ==
  //               selectedRows[i].cells['txtStkcode']!.value!) {
  //             isCheck = true;
  //             break;
  //           }
  //         }
  //         if (!isCheck) {
  //           stateManager.rows[i].setChecked(false);
  //         }
  //       }
  //     }
  //   }
  // }
}
