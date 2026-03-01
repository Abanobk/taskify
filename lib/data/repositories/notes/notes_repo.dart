import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class NotesRepo {
  Future<Map<String, dynamic>> createNote({
    required String title,
    required String desc,
    required String noteType,
    required String createdAt,

    required String drawingData,
    required bool token,
  }) async {

    try {

      FormData formData = FormData.fromMap({
        "title": title,
        "description": desc,
        "color": "warning",
        "note_type":noteType,
        "drawing_data":drawingData

      });
      final response = await ApiBaseHelper.formPost(
          url: createNotesUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> noteList(
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
          url: listNotesUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteNote({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteNotesUrl/$id", useAuthToken: true, body: {});


      // for (var row in rows) {
      //   notes.add(NotesModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateNote({
    required int id,
    required String title,
    required String desc,
    required String noteType,

    required String drawingData,
    required bool token,
  }) async {

    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "description": desc,
        "color": "warning",
        "note_type": noteType,
        "drawing_data":drawingData
      };
      final response = await ApiBaseHelper.post(
          url: updateNotesUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
