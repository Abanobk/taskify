import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class TagRepo{
  Future<Map<String, dynamic>> getTags(
      {
        int? offset,
        int? limit,
        String? search,
        required bool token,
      }) async {


    try {
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
      print("USER REPO ");
      final response = await ApiBaseHelper.getApi(
        url: getTagUrl,
        useAuthToken: true, params: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> createTags({
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
          url: createTagUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteTags({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$deleteTagUrl/$id", useAuthToken: true, body: {});



      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTags( {
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
          url: updateTagUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}