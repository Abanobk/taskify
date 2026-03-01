import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class UnitsRepo {
  Future<Map<String, dynamic>> createUnit({
    required String title,
    required String desc,
    required bool token,
  }) async {

    try {

      FormData formData = FormData.fromMap({
        "title": title,
        "description": desc,


      });
      final response = await ApiBaseHelper.formPost(
          url: createUnitUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> UnitList(
      {int? limit, int? offset, String? search = ""}) async {


    try {
      print("dfgvhbjkm,lqsa $limit");
      print("dfgvhbjkm,l$offset");
      Map<String, dynamic> body = {};
      if (search != null) {
        body["search"] = search;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      print("dfgvhbjkm,l rt $body");
      final response = await ApiBaseHelper.getApi(
          url: unitUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteUnit({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteUnitUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   Units.add(UnitsModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateUnit({
    required int id,
    required String title,
    required String desc,

  }) async {

    try {
      Map<String, dynamic> body = {
        "id":id,
        "title": title,
        "description":desc,
      };
      final response = await ApiBaseHelper.post(
          url: updateUnitUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
