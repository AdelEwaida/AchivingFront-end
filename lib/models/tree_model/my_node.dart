class MyNode {
  MyNode({
    required this.title,
    required this.extra,
    required this.isRoot,
    this.children = const <MyNode>[],
  });

  final String title;
  List<MyNode> children;
  final dynamic extra;
  final bool isRoot;
}
