import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class StatusRepo{
  Future<Map<String, dynamic>> getStatuses(
      {
        int? offset,
        int? limit,
        String? search,
      }) async {

    try {
      print("USER REPO ");
      Map<String, dynamic> body = {"limit": limit, "offset": offset};
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
        url: getStatus,
        useAuthToken: true, params: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> createStatus({
    required String title,
    required String color,
     List<int>? roleId,
  }) async {

    try {
      Map<String, dynamic> body = {
        "title": title,
        "color": color,
        "role_ids":roleId

      };
      print("tghyjkl,");
      print("tghyjkl, $body");
      final response = await ApiBaseHelper.post(
          url: createStatusUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteStatus({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$deleteStatusUrl/$id", useAuthToken: true, body: {});



      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateStatus( {
    required int id,
    required String title,
    required String color,
    List<int>? roleId,

  }) async {
print("kdfjfkln $id");
print("kdfjfkln $title");
print("kdfjfkln $color");
print("kdfjfkln $roleId");


    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "color": color,
        "role_ids":roleId

      };
      final response = await ApiBaseHelper.post(
          url: updateStatusUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}