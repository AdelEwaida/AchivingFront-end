import 'package:archiving_flutter_project/models/db/user_models/user_category.dart';

class UserUpdateReq {
  String? userCategory;
  List<UserCategory>? users;
  UserUpdateReq({this.userCategory, this.users});

  factory UserUpdateReq.fromJson(Map<String, dynamic> json) {
    return UserUpdateReq(
      userCategory: json['userCategory'],
      users: json['users'] != null
          ? (json['users'] as List)
              .map((i) => UserCategory.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userCategory': userCategory,
      'users': users?.map((i) => i.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return userCategory!;
  }
}
