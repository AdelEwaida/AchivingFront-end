import 'dart:html';

import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../dialogs/error_dialgos/categories_dialogs/add_category_dialog.dart';
import '../../dialogs/error_dialgos/categories_dialogs/edit_category_dialog.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/responsive.dart';

class DealClassificationTreeScreen extends StatefulWidget {
  const DealClassificationTreeScreen({Key? key, this.selectedModel})
      : super(key: key);

  final DocumentCategory? selectedModel;

  @override
  DealClassificationTreeScreenState createState() =>
      DealClassificationTreeScreenState();
}

class DealClassificationTreeScreenState
    extends State<DealClassificationTreeScreen> {
  DealClassificationTreeScreenState();

  static final DealClassificationTreeScreenState _instance =
      DealClassificationTreeScreenState();
  late AppLocalizations _locale;
  CategoriesController categoriesController = CategoriesController();
  List<MyNode> treeNodes = [];

  bool isLoading = false;
  ValueNotifier selectedCamp = ValueNotifier("");
  ValueNotifier selectedValue = ValueNotifier("");
  Color currentColor = Color.fromARGB(255, 225, 65, 65);
  Color selectedColor = Colors.grey;

  List<MyNode> roots = [];

  static bool get enabled => _instance._enabled;

  bool _enabled = true;

  final MethodChannel _channel = SystemChannels.contextMenu;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    if (widget.selectedModel != null) {
      selectedCategory = widget.selectedModel;
      selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
      selectedValue.value = selectedCategory!.docCatParent!.txtDeptcode;
    }

    if (treeNodes.isEmpty) {
      roots = <MyNode>[
        MyNode(title: '/', children: treeNodes, extra: null, isRoot: true),
      ];
      treeController = TreeController<MyNode>(
        roots: roots,
        childrenProvider: (MyNode node) => node.children,
      );
      await fetchDate();
    }
    super.didChangeDependencies();
  }

  double screenWidth = 0;
  double screenHeight = 0;
  DocumentCategory? selectedCategory;
  late final TreeController<MyNode> treeController;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth * 0.4;
    final double dialogheight = screenHeight * 0.75;
    bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_locale.listOfCategories),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchField(
                  label: _locale.search,
                  width: screenWidth * 0.45,
                  padding: 8,
                  controller: searchController,
                  // decoration: InputDecoration(
                  //   labelText: 'Search',
                  //   hintText: 'Search categories',
                  //   prefixIcon: Icon(Icons.search),
                  //   border: OutlineInputBorder(
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  // ),
                  onChanged: (value) {
                    searchTree(value);
                    // Add search functionality if needed
                  },
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AddCategoryDialog();
                          }).then((value) {
                        if (value != null) {}
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                    )),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const EditCategoryDialog();
                          }).then((value) {
                        if (value != null) {}
                      });
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    )),
              ],
            ),
            if (isLoading)
              Expanded(
                child: Center(
                  child: SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: 50.0,
                  ),
                ),
              )
            else
              Expanded(
                child: Stack(
                  children: [
                    TreeView<MyNode>(
                      key: ValueKey(treeController),
                      treeController: treeController,
                      nodeBuilder:
                          (BuildContext context, TreeEntry<MyNode> entry) {
                        return MyTreeTile(
                          onPointerDown: (p0) {},
                          key: ValueKey(entry.node),
                          entry: entry,
                          folderOnTap: () {
                            if (entry.node.children.isNotEmpty) {
                              selectedCategory = entry.node.extra;
                              selectedCamp.value = selectedCategory!
                                  .docCatParent!.txtDescription!;
                              selectedValue.value =
                                  selectedCategory!.docCatParent!.txtShortcode;
                              treeController.toggleExpansion(entry.node);
                            } else {
                              // if (!entry.node.isRoot) {
                              selectedCategory = entry.node.extra;
                              selectedCamp.value = selectedCategory!
                                  .docCatParent!.txtDescription!;
                              selectedValue.value =
                                  selectedCategory!.docCatParent!.txtShortcode;
                              // }
                            }
                          },
                          textWidget: nodeDesign(entry.node),
                        );
                      },
                    ),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            const Divider(height: 3),
          ],
        ),
      ),
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
      setState(() {});
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
          setState(() {});
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
      width: node.isRoot ? 100 : 180,
      child: InkWell(
        onTap: () {
          // if (!node.isRoot && node.children.isEmpty) {
          selectedCategory = node.extra;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          // }
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
                fontSize: 12,
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
  Future<void> fetchDate() async {
    setState(() {
      isLoading = true;
    });

    campClassificationList = await categoriesController.getCategoriesTree();

    convertToTreeList(campClassificationList);

    children = [];
    for (int i = 0; i < campClassificationList.length; i++) {
      children.addAll(getChildren(campClassificationList[i]));
    }
    treeController.toggleExpansion(roots.first);
  }

  void convertToTreeList(List<DocumentCategory> result) {
    for (int i = 0; i < result.length; i++) {
      treeNodes.add(getNodes(result[i]));
    }

    setState(() {
      isLoading = false;
    });
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

  bool getColor(DocumentCategory? current, String value) {
    if (current != null) {
      String code = current.docCatParent!.txtShortcode!;
      return value.compareTo(code) == 0;
    }
    return false;
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

  static Future<void> disableContextMenu() {
    assert(kIsWeb, 'This has no effect on platforms other than web.');
    return _instance._channel
        .invokeMethod<void>('disableContextMenu')
        .then((_) {
      _instance._enabled = false;
    });
  }

  static Future<void> enableContextMenu() {
    assert(kIsWeb, 'This has no effect on platforms other than web.');
    return _instance._channel.invokeMethod<void>('enableContextMenu').then((_) {
      _instance._enabled = true;
    });
  }
}
