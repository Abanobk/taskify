import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class TaxesRepo {
  Future<Map<String, dynamic>> createtax({
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
        "percentage":percentage


      });
      final response = await ApiBaseHelper.formPost(
          url: createTaxesUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> taxList(
      {int? limit, int? offset, String? search = "",String? type}) async {


    try {
      print("dfgvhbjkm,lqsa $limit");
      print("dfgvhbjkm,l$offset");
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
      print("dfgvhbjkm,l rt $body");
      final response = await ApiBaseHelper.getApi(
          url: taxesUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deletetax({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteTaxesUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   taxes.add(taxesModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updatetax({
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
        "percentage":percentage
      };
      final response = await ApiBaseHelper.post(
          url: updateTaxesUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
