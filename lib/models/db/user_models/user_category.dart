import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserCategory {
  String? categoryId;
  String? userId;
  String? categoryName;
  String? userName;

  UserCategory({
    this.categoryId,
    this.userId,
    this.categoryName,
    this.userName,
  });

  // fromJson method
  factory UserCategory.fromJson(Map<String, dynamic> json) {
    return UserCategory(
      categoryId: json['categoryId'],
      userId: json['userId'],
      categoryName: json['categoryName'],
      userName: json['userName'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'userId': userId,
      'categoryName': categoryName,
      'userName': userName,
    };
  }

  // toPlutoRow method
  PlutoRow toPlutoRow(int count, AppLocalizations localizations) {
    return PlutoRow(
      cells: {
        "count": PlutoCell(value: count),
        'categoryId': PlutoCell(value: categoryId),
        'userId': PlutoCell(value: userId),
        'categoryName': PlutoCell(value: categoryName),
        'userName': PlutoCell(value: userName),
      },
    );
  }

  factory UserCategory.fromPlutoRow(
      PlutoRow row, AppLocalizations localizations) {
    return UserCategory(
      categoryId: row.cells['categoryId']?.value,
      userId: row.cells['userId']?.value,
      categoryName: row.cells['categoryName']?.value,
      userName: row.cells['userName']?.value,
    );
  }
  @override
  String toString() {
    // TODO: implement toString
    return userName!;
  }
}
