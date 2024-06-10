import 'dart:convert';

class PayloadModel {
  String? sub;
  List<String>? roles;
  int? exp;
  int? iat;
  String? group;

  PayloadModel({this.sub, this.roles, this.exp, this.iat, this.group});

  factory PayloadModel.fromJson(Map<String, dynamic> json) {
    return PayloadModel(
      sub: json['sub'],
      roles: List<String>.from(json['roles']),
      exp: json['exp'],
      iat: json['iat'],
      group: json['group'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sub'] = sub;
    data['roles'] = roles;
    data['exp'] = exp;
    data['iat'] = iat;
    data['group'] = group;
    return data;
  }
}
