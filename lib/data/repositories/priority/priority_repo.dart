import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';


class PriorityRepo{
  Future<Map<String, dynamic>> getPriorities(
      {
        int? offset=0,
        int? limit=20,
        String type = "",
        required bool token,
        String? search
      }) async {

    try {

      Map<String, dynamic> body = {
        "type": type,
        "limit": limit,
        "offset": offset
      };
      if(search !=null){
        body["search"] = search;
      }

      final response = await ApiBaseHelper.getApi(
        url: getPriorityUrl,
        params: body,
        useAuthToken: true,
      );
      print("Respomse of Priority $response");
      return response;

    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> createPriority({
    required String title,
    required String color,
  }) async {

    try {
      Map<String, dynamic> body = {
        "title": title,
        "color": color,

      };
      print("tghyjkl,");
      print("tghyjkl, $body");
      final response = await ApiBaseHelper.post(
          url: createPriorityUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deletePriority({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$deletePriorityUrl/$id", useAuthToken: true, body: {});



      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updatePriority( {
    required int id,
    required String title,
    required String color,


  }) async {
    print("kdfjfkln $id");
    print("kdfjfkln $title");
    print("kdfjfkln $color");



    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "color": color,

      };
      final response = await ApiBaseHelper.post(
          url: updatePriorityUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}