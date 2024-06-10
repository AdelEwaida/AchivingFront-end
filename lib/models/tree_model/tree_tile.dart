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
      guide: const IndentGuide.connectingLines(indent: 48),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
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
                    color: Colors.amber,
                    icon: const Icon(
                      Icons.article,
                      color: Color(0xFF6895D2),
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
