import 'dart:html';

import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants/colors.dart';

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
  bool expand = true;
  Color currentColor = const Color.fromARGB(255, 65, 185, 225);
  Color selectedColor = Colors.grey;

  List<MyNode> roots = [];

  static bool get enabled => _instance._enabled;

  bool _enabled = true;

  final MethodChannel _channel = SystemChannels.contextMenu;

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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (!isLoading)
                    TreeView<MyNode>(
                      key: ValueKey(treeController),
                      shrinkWrap: true,
                      treeController: treeController,
                      nodeBuilder:
                          (BuildContext context, TreeEntry<MyNode> entry) {
                        return MyTreeTile(
                          key: ValueKey(entry.node),
                          entry: entry,
                          folderOnTap: () {
                            if (entry.node.children.isNotEmpty) {
                              treeController.toggleExpansion(entry.node);
                            } else {
                              if (!entry.node.isRoot) {
                                selectedCategory = entry.node.extra;
                                selectedCamp.value = selectedCategory!
                                    .docCatParent!.txtDescription!;
                                selectedValue.value =
                                    selectedCategory!.docCatParent!.txtKey;
                              }
                            }
                          },
                          textWidget: nodeDesign(entry.node),
                          onPointerDown: (event) {
                            if (entry.node.children.isEmpty) {
                              // _onPointerDown(event, node: entry.node);
                            }
                          },
                        );
                      },
                    )
                  else
                    const SizedBox(),
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

  Widget nodeDesign(MyNode node) {
    return SizedBox(
      width: node.isRoot ? 100 : 180,
      child: InkWell(
        onTap: () {
          if (!node.isRoot && node.children.isEmpty) {
            selectedCategory = node.extra;
            selectedCamp.value =
                selectedCategory!.docCatParent!.txtDescription!;
            selectedValue.value = selectedCategory!.docCatParent!.txtKey;
          }
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
