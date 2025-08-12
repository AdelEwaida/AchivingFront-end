import 'dart:html';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_update_req.dart';
import 'package:archiving_flutter_project/models/dto/category_dto_model/insert_category_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/test_drop_down.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../dialogs/categories_dialogs/add_category_dialog.dart';
import '../../dialogs/categories_dialogs/edit_category_dialog.dart';
import '../../dialogs/error_dialgos/confirm_dialog.dart';
import '../../dialogs/users_dialogs/selected_users_table.dart';
import '../../models/db/user_models/user_category.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/responsive.dart';

class AddUserPermisonsScreen extends StatefulWidget {
  const AddUserPermisonsScreen({Key? key, this.selectedModel})
      : super(key: key);

  final DocumentCategory? selectedModel;

  @override
  AddUserPermisonsScreenState createState() => AddUserPermisonsScreenState();
}

class AddUserPermisonsScreenState extends State<AddUserPermisonsScreen> {
  AddUserPermisonsScreenState();

  late AppLocalizations _locale;
  CategoriesController categoriesController = CategoriesController();
  List<MyNode> treeNodes = [];
  bool _loadedInitial = false;
  bool isLoading = false;
  ValueNotifier selectedCamp = ValueNotifier("");
  ValueNotifier selectedValue = ValueNotifier("");
  ValueNotifier<String> selectedKey = ValueNotifier<String>("");

  Color currentColor = Color.fromARGB(255, 225, 65, 65);
  Color selectedColor = Colors.grey;
  String hintUsers = "";

  List<MyNode> roots = [];
  UserController userController = UserController();
  final MethodChannel _channel = SystemChannels.contextMenu;
  TextEditingController searchController = TextEditingController();
  List<UserModel>? usersListModel = [];
  List<String>? listOfUsersCode = [];
  late UserProvider userProvider;
  List<UserCategory>? usersListModelCategory = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    userProvider = context.read<UserProvider>();

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
        title: Text(_locale.addUserCategories),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // MAIN AREA: Tree (left) + Users table (right)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: search + tree
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔎 tree search
                        CustomSearchField(
                          label: _locale.search,
                          width: screenWidth * 0.45,
                          padding: 8,
                          controller: searchController,
                          onChanged: (value) => searchTree(value),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${_locale.pleaseSelectCat} *",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // 🌲 tree itself
                        Expanded(
                          child: isLoading
                              ? Center(
                                  child: SpinKitCircle(
                                    color: Theme.of(context).primaryColor,
                                    size: 50.0,
                                  ),
                                )
                              : Stack(
                                  children: [
                                    TreeView<MyNode>(
                                      key: ValueKey(treeController),
                                      treeController: treeController,
                                      nodeBuilder: (context, entry) {
                                        return MyTreeTile(
                                          onPointerDown: (p0) {},
                                          key: ValueKey(entry.node),
                                          entry: entry,
                                          folderOnTap: () {
                                            if (entry
                                                .node.children.isNotEmpty) {
                                              selectedCategory =
                                                  entry.node.extra;
                                              selectedCamp.value =
                                                  selectedCategory!
                                                      .docCatParent!
                                                      .txtDescription!;
                                              selectedValue.value =
                                                  selectedCategory!
                                                      .docCatParent!
                                                      .txtShortcode;
                                              selectedKey.value =
                                                  selectedCategory!
                                                          .docCatParent!
                                                          .txtKey ??
                                                      "";
                                              treeController
                                                  .toggleExpansion(entry.node);
                                            } else {
                                              selectedCategory =
                                                  entry.node.extra;
                                              selectedCamp.value =
                                                  selectedCategory!
                                                      .docCatParent!
                                                      .txtDescription!;
                                              selectedKey.value =
                                                  selectedCategory!
                                                          .docCatParent!
                                                          .txtKey ??
                                                      "";
                                              selectedValue.value =
                                                  selectedCategory!
                                                      .docCatParent!
                                                      .txtShortcode;
                                            }
                                            // ✅ prefill right table with users of this category
                                            getUsersForCategory(
                                                selectedKey.value);
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
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ValueListenableBuilder<String>(
                      valueListenable: selectedKey,
                      builder: (context, catId, _) {
                        return UserSelectionTable(
                          key: ValueKey(catId), // يضمن إعادة بناء الودجت
                          selectedCategoryId: catId, // مرّر الكاتيجوري المختار
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: save,
                    style: customButtonStyle(
                      Size(
                        isDesktop ? screenWidth * 0.1 : screenWidth * 0.4,
                        screenHeight * 0.045,
                      ),
                      18,
                      primary,
                    ),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              ),
            ),
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
            reloadData();
          }
        });
      }
    });
  }

  void getUsersForCategory(String categoryId) async {
    List<UserCategory> userList =
        await userController.getUsersByCatMethod(categoryId);
    setState(() {
      usersListModelCategory = userList;
      hintUsers = usersListModelCategory!.map((e) => e.userName!).join(', ');
      userProvider.clearUsers();
      for (int i = 0; i < usersListModelCategory!.length; i++) {
        UserModel userModel = UserModel(
            txtCode: usersListModelCategory![i].userId!,
            txtNamee: usersListModelCategory![i].userName!,
            txtDeptkey: "",
            txtPwd: "",
            txtReferenceUsername: "",
            bolActive: 0,
            intType: 0,
            activeToken: "",
            email: "",
            url: "");
        userProvider.addUser(userModel);
      }

      if (hintUsers.endsWith(', ')) {
        hintUsers = hintUsers.substring(0, hintUsers.length - 2);
      }
    });
  }

  save() async {
    List<String> userCodes = context
        .read<UserProvider>()
        .selectedUsers
        .map((user) => user.txtCode!)
        .toList();
    UserUpdateReq userUpdateReq =
        UserUpdateReq(categoryId: selectedKey.value, users: userCodes);
    var response = await userController.updateUserCatgeory(userUpdateReq);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.done_all,
              errorDetails: _locale.done,
              errorTitle: _locale.addDoneSucess,
              color: Colors.green,
              statusCode: 200);
        },
      ).then((value) {
        setState(() {
          listOfUsersCode!.clear();
          hintUsers = "";
          usersListModel!.clear();
          usersListModel!.clear();
          userProvider.clearUsers();
        });
        // setState(() {});
        // resetPage(); // reloadData();
      });
    }
  }

  Future<void> resetPage() async {
    selectedCamp.value = "";
    selectedValue.value = "";
    selectedKey.value = "";
    treeController.collapseAll();

    await reloadData();
  }

  Future<void> reloadData() async {
    final expansionState = storeExpansionState();

    setState(() {
      isLoading = true;
    });

    campClassificationList = await categoriesController.getCategoriesTree();

    treeNodes.clear();
    convertToTreeList(campClassificationList);

    children = [];
    for (int i = 0; i < campClassificationList.length; i++) {
      children.addAll(getChildren(campClassificationList[i]));
    }

    restoreExpansionState(expansionState);

    setState(() {
      isLoading = false;
    });
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

  void searchTree(String query) {
    if (query == "") {
      selectedCamp.value = "";
      selectedValue.value = "";
      selectedKey.value = "";
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
          selectedKey.value = selectedCategory!.docCatParent!.txtKey ?? "";
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

  bool searchNode(MyNode node, String query) {
    if (node.title.contains(query)) {
      selectedCategory = node.extra;
      selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
      selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
      selectedKey.value = selectedCategory!.docCatParent!.txtKey ?? "";
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
          // if (!node.isRoot && node.children.isEmpty) {
          selectedCategory = node.extra;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          selectedKey.value = selectedCategory!.docCatParent!.txtKey ?? "";
          getUsersForCategory(selectedKey.value);

          setState(() {});
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


}
