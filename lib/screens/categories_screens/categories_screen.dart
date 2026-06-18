import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/dto/category_dto_model/insert_category_model.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../dialogs/categories_dialogs/add_category_dialog.dart';
import '../../dialogs/categories_dialogs/edit_category_dialog.dart';
import '../../dialogs/error_dialgos/confirm_dialog.dart';

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
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _selectedNodeKey = GlobalKey();
  List<DocumentCategory> _searchMatches = [];
  int _searchMatchIndex = 0;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
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
  int _treeRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomSearchField(
                      label: _locale.search,
                      width: screenWidth * 0.45,
                      padding: 8,
                      controller: searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        searchTree(value);
                      },
                      onSubmitted: (value) {
                        searchTree(value, advanceMatch: true);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    icon: Icons.add,
                    color: const Color(0xFF16A34A),
                    tooltip: _locale.add,
                    onPressed: () {
                      if (selectedCategory != null) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AddCategoryDialog(
                                  category: selectedCategory);
                            }).then((value) {
                          if (value) {
                            reloadData();
                          }
                        });
                      } else {
                        CustomToastMessage.error(
                            context, _locale.pleaseSelectACategory);
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.edit,
                    color: const Color(0xFF2563EB),
                    tooltip: _locale.edit,
                    onPressed: () {
                      if (selectedCategory != null) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return EditCategoryDialog(
                                  category: selectedCategory);
                            }).then((value) {
                          if (value) {
                            reloadData();
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  _actionButton(
                    icon: Icons.delete,
                    color: Colors.red,
                    tooltip: _locale.delete,
                    onPressed: (selectedCategory != null &&
                            selectedCategory!.docCatChildren!.isEmpty)
                        ? () {
                            deleteMethod();
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Stack(
                    children: [
                      TreeView<MyNode>(
                        key: ValueKey(_treeRefreshKey),
                        treeController: treeController,
                        nodeBuilder:
                            (BuildContext context, TreeEntry<MyNode> entry) {
                          return MyTreeTile(
                            onPointerDown: (p0) {},
                            key: _isSelectedTreeNode(entry.node)
                                ? _selectedNodeKey
                                : ValueKey(entry.node),
                            entry: entry,
                            folderOnTap: () {
                              if (entry.node.children.isNotEmpty) {
                                selectedCategory = entry.node.extra;
                                selectedCamp.value = selectedCategory!
                                    .docCatParent!.txtDescription!;
                                selectedValue.value = selectedCategory!
                                    .docCatParent!.txtShortcode;
                                treeController.toggleExpansion(entry.node);
                              } else {
                                selectedCategory = entry.node.extra;
                                selectedCamp.value = selectedCategory!
                                    .docCatParent!.txtDescription!;
                                selectedValue.value = selectedCategory!
                                    .docCatParent!.txtShortcode;
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
              ),
            // const Divider(height: 3),
          ],
        ),
      ),
    );
  }

  void deleteMethod() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomConfirmDialog(confirmMessage: _locale.sureToDeleteThisCat);
      },
    ).then((value) async {
      if (value) {
        await categoriesController
            .deleteCategory(InsertCategoryModel(
                shortCode: selectedCategory!.docCatParent!.txtShortcode!))
            .then((value) {
          if (value.statusCode == 200) {
            CustomToastMessage.success(context, _locale.deleteDoneSuccess);
            reloadData();
          }
        });
      }
    });
  }

  Future<void> reloadData() async {
    final expansionState = storeExpansionState();
    final parentShortCode = selectedCategory?.docCatParent?.txtShortcode;

    setState(() {
      isLoading = true;
    });

    try {
      campClassificationList = await categoriesController.getCategoriesTree();

      treeNodes.clear();
      for (int i = 0; i < campClassificationList.length; i++) {
        treeNodes.add(getNodes(campClassificationList[i]));
      }

      children = [];
      for (int i = 0; i < campClassificationList.length; i++) {
        children.addAll(getChildren(campClassificationList[i]));
      }

      roots = <MyNode>[
        MyNode(title: '/', children: treeNodes, extra: null, isRoot: true),
      ];
      treeController.roots = roots;

      restoreExpansionState(expansionState);

      if (parentShortCode != null) {
        selectedCategory =
            findCategoryByShortCode(campClassificationList, parentShortCode);
        if (selectedCategory != null) {
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          expandCategoryNode(roots.first, parentShortCode);
        } else {
          selectedCategory = null;
        }
      } else {
        selectedCategory = null;
      }

      _treeRefreshKey++;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  DocumentCategory? findCategoryByShortCode(
      List<DocumentCategory> categories, String shortCode) {
    for (final category in categories) {
      if (category.docCatParent?.txtShortcode == shortCode) {
        return category;
      }
      if (category.docCatChildren != null &&
          category.docCatChildren!.isNotEmpty) {
        final found =
            findCategoryByShortCode(category.docCatChildren!, shortCode);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  void expandCategoryNode(MyNode node, String shortCode) {
    if (node.extra != null &&
        (node.extra as DocumentCategory).docCatParent?.txtShortcode ==
            shortCode) {
      treeController.setExpansionState(node, true);
      return;
    }
    for (final child in node.children) {
      expandCategoryNode(child, shortCode);
    }
  }

  Map<String, bool> storeExpansionState() {
    final Map<String, bool> expansionState = {};
    for (final node in treeController.roots) {
      _storeExpansionState(node, expansionState);
    }
    return expansionState;
  }

  void _storeExpansionState(MyNode node, Map<String, bool> expansionState) {
    expansionState[node.title] = treeController.getExpansionState(node);
    for (final child in node.children) {
      _storeExpansionState(child, expansionState);
    }
  }

  void restoreExpansionState(Map<String, bool> expansionState) {
    for (final node in treeController.roots) {
      _restoreExpansionState(node, expansionState);
    }
  }

  void _restoreExpansionState(MyNode node, Map<String, bool> expansionState) {
    if (expansionState[node.title] != null) {
      treeController.setExpansionState(node, expansionState[node.title]!);
    }
    for (final child in node.children) {
      _restoreExpansionState(child, expansionState);
    }
  }

  void searchTree(String query, {bool advanceMatch = false}) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      _searchMatches = [];
      _searchMatchIndex = 0;
      _lastSearchQuery = '';
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
      return;
    }

    if (normalizedQuery != _lastSearchQuery) {
      _lastSearchQuery = normalizedQuery;
      _searchMatches = _findAllMatches(normalizedQuery);
      _searchMatchIndex = 0;
    } else if (advanceMatch && _searchMatches.isNotEmpty) {
      _searchMatchIndex = (_searchMatchIndex + 1) % _searchMatches.length;
    }

    if (_searchMatches.isEmpty) return;

    _selectSearchMatch(
      _searchMatches[_searchMatchIndex],
      keepSearchFocus: advanceMatch,
    );
  }

  List<DocumentCategory> _findAllMatches(String query) {
    final matches = <DocumentCategory>[];
    for (final category in campClassificationList) {
      _collectCategoryMatches(category, query, matches);
    }
    return matches;
  }

  void _collectCategoryMatches(
    DocumentCategory category,
    String query,
    List<DocumentCategory> matches,
  ) {
    final label =
        '${category.docCatParent!.txtShortcode}@${category.docCatParent!.txtDescription!}'
            .toLowerCase();
    if (label.contains(query)) {
      matches.add(category);
    }
    if (category.docCatChildren != null) {
      for (final child in category.docCatChildren!) {
        _collectCategoryMatches(child, query, matches);
      }
    }
  }

  void _selectSearchMatch(
    DocumentCategory category, {
    bool keepSearchFocus = false,
  }) {
    selectedCategory = category;
    selectedCamp.value = category.docCatParent!.txtDescription!;
    selectedValue.value = category.docCatParent!.txtShortcode;

    treeController.roots = [];
    treeNodes = [];
    convertToTreeList(campClassificationList);
    final root =
        MyNode(title: '/', children: treeNodes, extra: null, isRoot: true);
    treeController.toggleExpansion(root);
    treeController.roots = <MyNode>[root];
    setState(() {});
    _revealSelectedNode(keepSearchFocus: keepSearchFocus);
  }

  bool _isSelectedTreeNode(MyNode node) {
    if (selectedCategory == null || node.extra == null) return false;
    return (node.extra as DocumentCategory).docCatParent?.txtShortcode ==
        selectedCategory!.docCatParent?.txtShortcode;
  }

  void _revealSelectedNode({bool keepSearchFocus = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetContext = _selectedNodeKey.currentContext;
        if (targetContext != null) {
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.35,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        if (keepSearchFocus) {
          _searchFocusNode.requestFocus();
        }
      });
    });
  }

  void removeNodeFromTree(DocumentCategory? category) {
    if (category == null) return;

    // Find the node in the treeNodes
    MyNode? nodeToRemove;
    for (var node in treeNodes) {
      nodeToRemove = findNode(node, category.docCatParent!.txtShortcode!);
      if (nodeToRemove != null) {
        break;
      }
    }

    if (nodeToRemove != null) {
      // Remove the node from its parent's children list

      // If the node is a root node, remove it from the roots list
      treeNodes.remove(nodeToRemove);

      // Update the tree view
      setState(() {
        // Refresh the tree controller to reflect changes
        treeController = TreeController<MyNode>(
          roots: treeNodes,
          childrenProvider: (MyNode node) => node.children,
        );
      });
    }
  }

  MyNode? findNode(MyNode node, String shortCode) {
    if (node.extra != null &&
        (node.extra as DocumentCategory).docCatParent!.txtShortcode ==
            shortCode) {
      return node;
    }

    for (var child in node.children) {
      var found = findNode(child, shortCode);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  Widget nodeDesign(MyNode node) {
    return SizedBox(
      width: node.isRoot ? 220 : 360,
      child: InkWell(
        onTap: () {
          selectedCategory = node.extra;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          treeController.toggleExpansion(node);

          setState(() {});
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
            final bool isSelected = getColor(node.extra, value.toString());
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                node.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0C4A6E) : Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Ink(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(onPressed == null ? 0.08 : 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: color),
          padding: EdgeInsets.zero,
          splashRadius: 20,
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
