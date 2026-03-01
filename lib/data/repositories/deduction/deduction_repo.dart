import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class DeductionRepo {
  Future<Map<String, dynamic>> createDeduction({
    required String title,
    required String type,
    required String amount,
    required String percentage,
  }) async {

    try {

      FormData formData = FormData.fromMap({
        "title": title,
        "type":type.toLowerCase(),
        "amount":amount,
        "percentage":percentage,
        "isApi":true


      });
      final response = await ApiBaseHelper.formPost(
          url: createDeductionUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> DeductionList(
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
      final response = await ApiBaseHelper.getApi(url: deductionUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteDeduction({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteDeductionUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   Deductiones.add(DeductionesModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateDeduction({
    required int id,
    required String title,
    required String type,
    required String amount,
    required String percentage,

  }) async {

    try {
      Map<String, dynamic> body = {
        "id":id,
        "title": title,
        "type":type.toLowerCase(),
        "amount":amount,
        "percentage":percentage,
        "isApi":true
      };
      final response = await ApiBaseHelper.post(
          url: updateDeductionUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
