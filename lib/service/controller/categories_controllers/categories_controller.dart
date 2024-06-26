import 'dart:convert';

import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/dto/category_dto_model/insert_category_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';

class CategoriesController {
  Future<List<DocumentCategory>> getCategoriesTree() async {
    var api = categoriesTreeApi;
    List<DocumentCategory> stockCategoriesList = [];
    try {
      var response = await ApiService().getRequest(api);
      print(response);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          stockCategoriesList.add(DocumentCategory.fromJson(stock));
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
    return stockCategoriesList;
  }

  Future addCategory(InsertCategoryModel insertCategoryModel) async {
    return await ApiService()
        .postRequest(inseartCategoryApi, insertCategoryModel);
  }

  Future updateCategory(InsertCategoryModel insertCategoryModel) async {
    return await ApiService()
        .postRequest(updateCategoryApi, insertCategoryModel);
  }

  Future deleteCategory(InsertCategoryModel insertCategoryModel) async {
    return await ApiService()
        .postRequest(deleteCategoryApi, insertCategoryModel.toJsonDelete());
  }
}
