import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class MyTreeTile extends StatelessWidget {
  MyTreeTile({
    super.key,
    required this.entry,
    required this.folderOnTap,
    // required this.folderOnDoubleTap,
    required this.onPointerDown,
    required this.textWidget,
  });

  final TreeEntry<MyNode> entry;
  final VoidCallback folderOnTap;
  // final VoidCallback folderOnDoubleTap;

  final Function(PointerDownEvent) onPointerDown;

  final Widget textWidget;

  @override
  Widget build(BuildContext context) {
    return TreeIndentation(
      entry: entry,
      guide: const IndentGuide.connectingLines(
        indent: 38,
        color: Color(0xFFCBD5E1),
        thickness: 1,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
        child: Row(
          children: [
            InkWell(
              onTap: folderOnTap,
              // onDoubleTap: folderOnDoubleTap,
              child: Listener(
                  onPointerDown: onPointerDown,
                  child: FolderButton(
                    isOpen: entry.hasChildren ? entry.isExpanded : null,
                    onPressed: entry.hasChildren ? folderOnTap : null,
                    color: const Color(0xFF2563EB),
                    icon: Icon(
                      entry.hasChildren
                          ? (entry.isExpanded
                              ? Icons.folder_open_rounded
                              : Icons.folder_rounded)
                          : Icons.article_rounded,
                      color: const Color(0xFF2563EB),
                      size: 18,
                    ),
                  )),
            ),
            textWidget
          ],
        ),
      ),
    );
  }
}
