import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/screens/file_screens/fillter_section.dart';
import 'package:archiving_flutter_project/screens/file_screens/table_file_list_section.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  List<MyNode> treeNodes = [];
  // bool isLoading = false;
  ValueNotifier selectedCamp = ValueNotifier("");
  ValueNotifier selectedValue = ValueNotifier("");
  Color currentColor = Color.fromARGB(255, 225, 65, 65);
  Color selectedColor = Colors.grey;
  bool isDesktop = false;
  DocumentCategory? selectedCategory;
  late final TreeController<MyNode> treeController;
  List<MyNode> roots = [];
  CategoriesController categoriesController = CategoriesController();
  TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController =
      TextEditingController(text: Converters.getDateBeforeMonth());
  TextEditingController toDateController = TextEditingController(
      text: Converters.formatDate2(DateTime.now().toString()));
  late DocumentListProvider documentListProvider;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  DocumentsController documentsController = DocumentsController();
  late PlutoGridStateManager stateManager;
  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    documentListProvider = context.read<DocumentListProvider>();
    calssificatonNameAndCodeProvider =
        context.read<CalssificatonNameAndCodeProvider>();
    if (treeNodes.isEmpty) {
      roots = <MyNode>[
        MyNode(title: '/', children: treeNodes, extra: null, isRoot: true),
      ];
      treeController = TreeController<MyNode>(
        roots: roots,
        childrenProvider: (MyNode node) => node.children,
      );
      await fetchData();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.documentExplorer),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adding some spacing between search field and tree
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: width * 0.35,
                        height: height * 0.37,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomSearchField(
                              label: _locale.search,
                              width: width * 0.3,
                              padding: 8,
                              controller: searchController,
                              onChanged: (value) {
                                searchTree(value);
                                // Add search functionality if needed
                              },
                            ),
                            Expanded(child: treeSection()),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      const FillterFileSection()
                    ],
                  ),
                ),
                const Row(
                  children: [
                    TableFileListSection(),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget treeSection() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) {
        return isLoading.value
            ? Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
              )
            : TreeView<MyNode>(
                key: ValueKey(treeController),
                treeController: treeController,
                nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
                  return MyTreeTile(
                    onPointerDown: (p0) {},
                    key: ValueKey(entry.node),
                    entry: entry,
                    folderOnTap: () {
                      if (entry.node.children.isNotEmpty) {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;

                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonName(selectedCamp.value);
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonKey(
                                selectedCategory!.docCatParent!.txtKey!);
                        treeController.toggleExpansion(entry.node);
                      } else {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;
                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                      }
                    },
                    textWidget: nodeDesign(entry.node),
                  );
                },
              );
      },
    );
  }

  void searchTree(String query) {
    if (query == "") {
      selectedCamp.value = "";
      selectedValue.value = "";

      treeController.roots = [];
      treeNodes = [];
      treeController.collapseAll();
      convertToTreeList(campClassificationList);
      MyNode node =
          MyNode(title: '/', children: treeNodes, extra: null, isRoot: true);
      treeController.toggleExpansion(node);
      treeController.roots = <MyNode>[node];
      treeController.notifyListeners();
      // setState(() {});
    } else {
      for (final node in treeNodes) {
        if (searchNode(node, query)) {
          print("INNNNNNNNN SEEEEEEAAAAAAAAAARCH");
          // selectedCategory = node;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;

          treeController.roots = [];
          treeNodes = [];

          convertToTreeList(campClassificationList);
          MyNode node = MyNode(
              title: '/', children: treeNodes, extra: null, isRoot: true);
          treeController.toggleExpansion(node);
          treeController.roots = <MyNode>[node];
          // setState(() {});
          treeController.notifyListeners();

          break;
        }
      }
    }
  }

  bool searchNode(MyNode node, String query) {
    if (node.title.contains(query)) {
      selectedCategory = node.extra;
      selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
      selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
      return true;
    }
    for (final child in node.children) {
      if (searchNode(child, query)) {
        return true;
      }
    }
    return false;
  }

  Widget nodeDesign(MyNode node) {
    return SizedBox(
      width: node.isRoot ? 200 : 300,
      child: InkWell(
        onTap: () {
          selectedCategory = node.extra;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          calssificatonNameAndCodeProvider
              .setSelectedClassificatonName(selectedCamp.value);
          calssificatonNameAndCodeProvider.setSelectedClassificatonKey(
              selectedCategory!.docCatParent!.txtKey!);
          treeController.notifyListeners();

          // setState(() {});
        },
        onDoubleTap: () {
          if (!node.isRoot && node.children.isEmpty) {
            selectedCategory = node.extra;
            selectedCamp.value =
                selectedCategory!.docCatParent!.txtDescription!;
          }
        },
        child: ValueListenableBuilder(
          valueListenable: selectedValue,
          builder: (context, value, child) {
            return Text(
              node.title,
              style: TextStyle(
                fontSize: 16,
                color: getColor(node.extra, value.toString())
                    ? currentColor
                    : Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }

  List<DocumentCategory> campClassificationList = [];
  List<DocumentCategory> children = [];
  Future<void> fetchData() async {
    // setState(() {
    //   isLoading = true;
    // });
    isLoading.value = true;
    campClassificationList = await categoriesController.getCategoriesTree();

    convertToTreeList(campClassificationList);

    children = [];
    for (int i = 0; i < campClassificationList.length; i++) {
      children.addAll(getChildren(campClassificationList[i]));
    }
    treeController.toggleExpansion(roots.first);
  }

  ValueNotifier isLoading = ValueNotifier(false);
  void convertToTreeList(List<DocumentCategory> result) {
    for (int i = 0; i < result.length; i++) {
      treeNodes.add(getNodes(result[i]));
    }
    isLoading.value = false;
    // setState(() {
    //   isLoading = false;
    // });
  }

  MyNode getNodes(DocumentCategory data) {
    MyNode node = MyNode(
      title:
          "${data.docCatParent!.txtShortcode}@${data.docCatParent!.txtDescription!}",
      extra: data,
      isRoot: false,
      children: List.from(data.docCatChildren!.map((x) => getNodes(x))),
    );
    treeController.setExpansionState(node, checkChildren(data));
    return node;
  }

  bool checkChildren(DocumentCategory data) {
    if (selectedCategory != null &&
        selectedCategory!.docCatParent!.txtShortcode ==
            data.docCatParent!.txtShortcode) {
      return true;
    }
    if (data.docCatChildren != null) {
      for (int i = 0; i < data.docCatChildren!.length; i++) {
        if (checkChildren(data.docCatChildren![i])) {
          return true;
        }
      }
    }
    return false;
  }

  List<DocumentCategory> getChildren(DocumentCategory data) {
    List<DocumentCategory> discountList = [];
    if (data.docCatChildren!.isEmpty) {
      discountList.add(data);
      return discountList;
    }
    if (data.docCatChildren != null) {
      for (int i = 0; i < data.docCatChildren!.length; i++) {
        List<DocumentCategory> childList = getChildren(data.docCatChildren![i]);
        discountList.addAll(childList);
      }
    }
    return discountList;
  }

  bool getColor(DocumentCategory? current, String value) {
    if (current != null) {
      String code = current.docCatParent!.txtShortcode!;
      return value.compareTo(code) == 0;
    }
    return false;
  }

  @override
  void dispose() {
    documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria());
    // TODO: implement dispose
    super.dispose();
  }
}
