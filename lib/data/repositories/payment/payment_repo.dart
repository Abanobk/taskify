import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class PaymentRepo {
  Future<Map<String, dynamic>> createPayment({

    required int userId,
    int? invoiceId,
    required String invoice,
    required int paymentMethodId,
    required String paymentMethod,
    required String amount,
    required String paymentDate,
    required String note,
    // required String createdBy,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "user_id": userId,
        "payment_method_id": paymentMethodId,
        "payment_method": paymentMethod,
        "amount": amount,
        "payment_date": paymentDate,
        "note": note,
      };

      if (invoiceId != 0) {
        data["invoice_id"] = invoiceId;
      }

      FormData formData = FormData.fromMap(data);
      final response = await ApiBaseHelper.formPost(
        url: createPaymentUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> paymentList({
    int? limit,
    int? offset,
    String? search = "",
    List<int>? userIds,
    List<int>? invoiceIds,
    List<int>? paymentMethodIds,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      print("Limit: $limit");
      print("Offset: $offset");

      Map<String, dynamic> body = {};

      if (search != null && search.isNotEmpty) {
        body["search"] = search;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      if (userIds != null && userIds.isNotEmpty) {
        body["user_id[]"] = userIds;
      }
      if (invoiceIds != null && invoiceIds.isNotEmpty) {
        body["invoice_id[]"] = invoiceIds;
      }
      if (paymentMethodIds != null && paymentMethodIds.isNotEmpty) {
        body["pm_id[]"] = paymentMethodIds;
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        body["from_date"] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        body["to_date"] = toDate;
      }

      print("Request body: $body");

      final response = await ApiBaseHelper.getApi(
        url: paymentUrl,
        useAuthToken: true,
        params: body,
      );

      return response;
    } catch (error) {
      print("Error: ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> deletePayment({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deletePaymentUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   PaymentMethd.add(PaymentMethdModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updatePayment({
    required int id,
    required int userId,
    int? invoiceId,
    required String invoice,
    required int paymentMethodId,
    required String paymentMethod,
    required String amount,
    required String paymentDate,
    required String note,
    // required String createdBy,

  }) async {
    try {
      Map<String, dynamic> body = {
        "id": id,
        "user_id": userId,
        "invoice_id": invoiceId,
        "invoice": invoice,
        "payment_method_id": paymentMethodId,
        "payment_method": paymentMethod,
        "amount": amount,
        "payment_date": paymentDate,
        "note": note,

      };

      // Add user only if it's not null


      final response = await ApiBaseHelper.post(
        url: updatePaymentUrl,
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


}
