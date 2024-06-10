import 'package:archiving_flutter_project/models/db/categories_models/doc_cat_parent.dart';

class DocumentCategory {
  final DocCatParent? docCatParent;
  final List<DocumentCategory>? docCatChildren;

  DocumentCategory({this.docCatParent, this.docCatChildren});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      docCatParent: json['docCatParent'] != null
          ? DocCatParent.fromJson(json['docCatParent'])
          : null,
      docCatChildren: json['docCatChildren'] != null
          ? (json['docCatChildren'] as List)
              .map((i) => DocumentCategory.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docCatParent': docCatParent?.toJson(),
      'docCatChildren': docCatChildren?.map((i) => i.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return docCatParent!.txtDescription!;
  }
}
