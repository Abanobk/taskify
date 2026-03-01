import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class PermissionRepo{
  Future<Map<String, dynamic>> getPermissions(
      { String? permissionFor,
        required bool token,
      }) async {


    try {
      final response = await ApiBaseHelper.get(
        url: assignedPermissionsurl,
        useAuthToken: true, params: {},


      );
      print("3dfrtghuyijkol; $response");

      return response.data as Map<String,dynamic>;
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

}