import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';

class TodosRepo {
  static Future<Map<String, dynamic>> createTodo({
    required String title,
    required String desc,
    required String priority,
    required bool token,
  }) async {


    try {
      Map<String, dynamic> body = {
        "title": title,
        "priority": priority,
        "description": desc,
      };
      final response = await ApiBaseHelper.post(url: createTododsUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> todoList(
      {int? limit, int? offset, String? search = ""}) async {

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
      final response = await ApiBaseHelper.getApi(
          url: listTododsUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> todoStatus(
      {int? id, int? status}) async {

    try {
      Map<String, dynamic> body = {};
      if (status != null) {
        body["status"] = status;
      }
print("BODY OF TODOS $listTododsUrl/$id/status?status=$status");
      // https://test-taskify.infinitietech.com/api/todos/127/status?status=1
      final response = await ApiBaseHelper.patch(
          url: "$listTododsUrl/$id/status?status=$status", useAuthToken: true, body: body);
      print("RESPONSE OF TODOS $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> deleteTodo({
    required String id,
    required bool token,
  }) async {
    // Map<String, dynamic> rows;

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$deleteTododsUrl/$id", useAuthToken: true, body: {});

      // rows = response as Map<String, dynamic>;
      // for (var row in rows) {
      //   Todos.add(TodosModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String,dynamic>> updateTodo({
    required int id,
    required String title,
    required String priority,
    required String desc,
    required bool token,
  }) async {
    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "priority": priority,
        "description": desc,
      };
      final response = await ApiBaseHelper.post(
          url: updateTododsUrl, useAuthToken: true, body: body);
      // print("xdctfvgybhnjmk,l ${response['data']['data']}");
      // rows = response['data']['data'] as Map<String, dynamic>;

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
