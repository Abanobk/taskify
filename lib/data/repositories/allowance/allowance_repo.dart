import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class AllowancesRepo {
  Future<Map<String, dynamic>> createAllowance({
    required String title,
    required String amount,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "amount":amount,
      });
      final response = await ApiBaseHelper.formPost(
          url: createAllowanceUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> allowanceList(
      {int? limit, int? offset, String? search = "",String? type}) async {


    try {
      Map<String, dynamic> body = {};
      if (search != null) {
        body["search"] = search;
      } if (type != null) {
        body["types[]"] = type;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      final response = await ApiBaseHelper.getApi(
          url: allowanceUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteAllowance({
    required int id,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteAllowanceUrl/$id", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateAllowance({
    required int id,
    required String title,
    required String amount,

  }) async {

    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "amount": amount,
      };
      final response = await ApiBaseHelper.post(
          url: updateAllowanceUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
