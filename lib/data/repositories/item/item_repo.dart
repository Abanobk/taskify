import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class ItemsRepo {
  Future<Map<String, dynamic>> createItem({
    required String title,
    required String desc,
    required int unitId,
    required int price,
    required bool token,
  }) async {
print("ytjk $price");
print("ytjk $unitId");
    try {

      FormData formData = FormData.fromMap({
        "title": title,
        "price": price,
        "unit_id":unitId,
        "description":desc,


      });
      final response = await ApiBaseHelper.formPost(
          url: createItemsUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> ItemList(
      {int? limit, int? offset, String? search = "",String? unitId = ""}) async {


    try {
      print("dfgvhbjkm,lqsa $limit");
      print("dfgvhbjkm,l$offset");
      print("dfgvhbjkm,l erer $unitId");
      Map<String, dynamic> body = {};
      if (search != null) {
        body["search"] = search;
      }  if (unitId != "") {
        body["unit_ids[]"] = unitId;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      print("dfgvhbjkm,l rt $body");
      final response = await ApiBaseHelper.getApi(
          url: itemsUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteItem({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteItemsUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   Items.add(ItemsModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateItem({
    required int id,
    required String title,
    required String desc,
    required String price,
    required int unitId,
    required bool token,
  }) async {
print("fehlkjdsh $unitId");
    try {
      Map<String, dynamic> body = {
        "id":id,
        "title": title,
        "price": price,
        "unit_id":unitId,
        "description":desc,
      };
      final response = await ApiBaseHelper.post(
          url: updateItemsUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
