
import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';

import '../../model/user_model.dart';





class RoleRepo{
  Future<Map<String, dynamic>> getRoles({
    int? offset,
    int? limit,
    String? search,
  }) async {
    try {
      print("USER REPO ");
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

      final response = await ApiBaseHelper.getRole(
        url: getRoleUrl,
        useAuthToken: false,
        params: body,
      );

      // Ensure you access the `data` field
      if (response is Response) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Unexpected response format");
      }
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getSpecificRolePermissions({
    int? offset,
    int? limit,
    String? search,
    int? roleId
  }) async {
    try {
      print("USER REPO ");
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

      final response = await ApiBaseHelper.getRole(
        url: "$getSpecificRolePermissionsUrl/$roleId",
        useAuthToken: false,
        params: body,
      );

      // Ensure you access the `data` field
      if (response is Response) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Unexpected response format");
      }
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getAllPermissions(
      { String? permissionFor,
        required bool token,
      }) async {


    try {
      final response = await ApiBaseHelper.get(
        url: getAllPermissionsListUrl,
        useAuthToken: true, params: {},


      );
      print("3dfrtghuyijkol; $response");

      return response.data as Map<String,dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required User user,
  }) async {
    try {
      Map<String, dynamic> body = user.toJson();
      print('Request Body: ${user.toJson()}');

      final response = await ApiBaseHelper.post(
        url: createUserUrl,
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> updateRole({
    required int id,
    required List<int> ids,
    required String name,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (ids.isNotEmpty) {
        body["permissions"] = ids;
      }
      if (name.isNotEmpty) {
        body["name"] = name;
      }

      final response = await ApiBaseHelper.post(
        url:"$getRoleUpdateUrl/$id",
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }  Future<Map<String, dynamic>> createRole({
    required List<int> ids,
    required String name,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (ids.isNotEmpty) {
        body["permissions"] = ids;
      }
      if (name.isNotEmpty) {
        body["name"] = name;
      }

      final response = await ApiBaseHelper.post(
        url:"$createRoleUrl",
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }




  Future<Map<String, dynamic>> getDeleteRole({
    required String id,
    required bool token,
  }) async {
    try {
      print("rftgyhujikl Id $id");
      final response  = await ApiBaseHelper.delete(
          url: "$getDeleteRoleUrl/$id", useAuthToken: true, body: {});

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

  Future<Map<String, dynamic>> updateUser({required User user}) async {
    print("Updating user...");
    try {
      // Send the request to update the user
      final response = await ApiBaseHelper.post(
        url: updateUserUrl,
        useAuthToken: true,
        body: user.toJson(),
      );
      return response;

    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

}