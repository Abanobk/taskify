import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';
class PaymentMethodRepo {
  Future<Map<String, dynamic>> createPaymentMethod({
    required String title,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
      });
      final response = await ApiBaseHelper.formPost(
          url: createPaymentMethodsUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> paymentPaymentMethodList(
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
          url: paymentMethodsUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deletePaymentMethod({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deletePaymentMethodsUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   PaymentMethd.add(PaymentMethdModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updatePaymentMethod({
    required int id,
    required String title,
  }) async {

    try {
      Map<String, dynamic> body = {
        "id":id,
        "title": title,

      };
      final response = await ApiBaseHelper.post(
          url: updatePaymentMethodsUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
