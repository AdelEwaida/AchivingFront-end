import 'package:archiving_flutter_project/models/db/user_models/user_category.dart';

class UserUpdateReq {
  String? categoryId;
  List<String>? users;

  UserUpdateReq({this.categoryId, this.users});

  factory UserUpdateReq.fromJson(Map<String, dynamic> json) {
    return UserUpdateReq(
      categoryId: json['categoryId'],
      users: json['users'] != null ? List<String>.from(json['users']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'users': users,
    };
  }

  @override
  String toString() {
    return userCategory!;
  }
}
