import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../model/user_model.dart';

class UserRepo{
  Future<Map<String, dynamic>> getUsers(
      {
        int? offset,
        int? limit,
        int? id,
        int? taskId,
        String? search,
        required bool token,
      }) async {
    // List rows;
    // final List<User> users = [];
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
      final response = await ApiBaseHelper.getApi(
        url: id != null ?"$getUser/$id":getUser,
        useAuthToken: true, params: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required User user,
  }) async {
    try {
      print("ftgyhu ${user.uploadPicture}");
      // Map<String, dynamic> body = user.toJson();
      Map<String,dynamic>body ={
        "id":user.id,
        "first_name":user.firstName,
        "last_name":user.lastName,
        "role":user.role,
        "role_id":user.roleId,
        // "company":user.company,
        "email":user.email,
        "phone":user.phone,
        "country_code":user.countryCode,
        // "country_iso_code":user.countryIsoCode,
        "password":user.password,
        "password_confirmation":user.passwordConfirmation,
        "type":user.type,
        "address":user.address,
        "dob":user.dob,
        "doj":user.doj,
        "city":user.type,
        "state":user.state,
        "country":user.country,
        "zip":user.zip,
        "profile": user.uploadPicture,
        "status":user.status,
        "created_at":user.createdAt,
        "updated_at":user.updatedAt,
        "assigned":user.assigned,
        "require_ev":user.requireEv
      };
      print('Request Body: ${user.toJson()}');

      final response = await ApiBaseHelper.post(
        url: createUserUrl,
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error wewe ${error.toString()}");
      flutterToastCustom(msg: error.toString());
      print(error);
      throw Exception('Error occurred');
    }
  }





  Future<Map<String, dynamic>>getDeleteUser({
    required String id,
    required bool token,
  }) async {
    // Map<String, dynamic> rows;
    // final List<User> task = [];
    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$deleteUserUrl/$id", useAuthToken: true, body: {});

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

      // Assuming the response contains the updated user data
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

}