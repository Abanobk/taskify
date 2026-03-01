import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';



class CandidatesStatusRepo {
  Future<Map<String, dynamic>> createCandidateStatus({
    required String name,
    required String color

  }) async {

    try {

      FormData formData = FormData.fromMap({
        "name": name,
        'color':color.toLowerCase()

      });
      final response = await ApiBaseHelper.formPost(
          url: createCandidateStatusUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> CandidateStatusList(
      {int? limit, int? offset, String? search = ""}) async {


    try {
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
      final response = await ApiBaseHelper.getApi(
          url: getCandidateStatusUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteCandidateStatus({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteCandidateStatusUrl/${id.toString()}", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateCandidateStatus({
    required int id,
    required String name,
    required String color

  }) async {

    try {
      Map<String, dynamic> body = {
        "name": name,
        'color':color.toLowerCase()
      };
      final response = await ApiBaseHelper.post(
          url: "$updateCandidateStatusUrl/$id", useAuthToken: true, body: body);
      print("tgbhnjmk $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
