import '../department_models/department_model.dart';
import 'department_user_model.dart';
import 'user_model.dart';

class UserDeptModel {
  List<DepartmentModel>? depts;
  UserModel? user;
  UserDeptModel({this.depts, this.user});
  factory UserDeptModel.fromJson(Map<String, dynamic> json) {
    return UserDeptModel(
      user: UserModel.fromJson(json['user']),
      depts: (json['depts'] as List)
          .map((e) => DepartmentModel.fromJson(e))
          .toList(),
    );
  }

  // Method to convert DocumentFileRequest instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'user': user!.toJson(),
      'depts': depts!.map((e) => e.toJson()).toList(),
    };
  }
}
