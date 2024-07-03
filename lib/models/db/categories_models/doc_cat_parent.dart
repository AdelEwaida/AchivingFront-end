class DocCatParent {
  final String? txtKey;
  final String? txtDescription;
  final int? intLevel;
  final String? txtParentcode;
  final String? txtShortcode;
  final String? txtDeptcode;
  final String? txtMainparent;
  final String? txtReference;
  DocCatParent({
    this.txtKey,
    this.txtDescription,
    this.intLevel,
    this.txtParentcode,
    this.txtShortcode,
    this.txtDeptcode,
    this.txtMainparent,
      this.txtReference
  });

  factory DocCatParent.fromJson(Map<String, dynamic> json) {
    return DocCatParent(
      txtKey: json['txtKey'],
      txtDescription: json['txtDescription'],
      intLevel: json['intLevel'],
      txtParentcode: json['txtParentcode'],
      txtShortcode: json['txtShortcode'],
      txtDeptcode: json['txtDeptcode'],
      txtMainparent: json['txtMainparent'],
        txtReference: json['txtReference']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtDescription': txtDescription,
      'intLevel': intLevel,
      'txtParentcode': txtParentcode,
      'txtShortcode': txtShortcode,
      'txtReference': txtReference,
      'txtDeptcode': txtDeptcode,
      'txtMainparent': txtMainparent,
    };
  }

  @override
  String toString() {
    return txtDescription.toString();
  }
}
