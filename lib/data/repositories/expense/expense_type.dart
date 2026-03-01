import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';


class ExpenseTypeRepo{
  Future<Map<String, dynamic>> getExpenseType(
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
        url: expenseTypeListUrl,
        params: body,
        useAuthToken: true,
      );
      print("Respomse of Expense $response");
      return response;

    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> createExpenseType({
    required String title,
    required String desc,
  }) async {

    try {
      Map<String, dynamic> body = {
        "title": title,
        "description": desc,

      };
      print("tghyjkl,");
      print("tghyjkl, $body");
      final response = await ApiBaseHelper.post(
          url: createExpenseTypeUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteExpenseType({
    required int id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$destroyExpenseTypeUrl/$id", useAuthToken: true, body: {});



      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateExpenseType( {
    required int id,
    required String title,
    required String desc,


  }) async {

    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "description": desc,

      };
      final response = await ApiBaseHelper.post(
          url: updateExpenseTypeUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}