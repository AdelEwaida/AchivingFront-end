import 'dart:convert';

class WhatsAppMessageModel {
  String alias;
  String mobNum;
  String msg;
  String file;
  List<String> mobNumList;

  WhatsAppMessageModel(
      {required this.alias,
      required this.mobNum,
      required this.msg,
      required this.file,
      required this.mobNumList});

  factory WhatsAppMessageModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessageModel(
        alias: json['alias'],
        mobNum: json['mobNum'],
        msg: json['msg'],
        file: json['file'],
        mobNumList: json['mobNumList']);
  }

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'mobNum': mobNum,
      'msg': msg,
      'file': file,
      'mobNumList': mobNumList
    };
  }
}
