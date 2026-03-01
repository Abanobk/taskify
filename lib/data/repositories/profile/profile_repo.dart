import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';
import '../../../config/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
class ProfileRepo {
  Future<Map<String, dynamic>> getProfile({
    required bool token,
    required String id,
  }) async {
    print("USER REPO fgh$id");

    try {
      print("USER REPO ");
      var box = await Hive.openBox(userBox);
      var id = box.get('user_id');
      final response = await ApiBaseHelper.getApi(
        url: "$getUser/$id",
        useAuthToken: true,
        params: {},
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getUserProfileDetails() async {

    try {

      final response = await ApiBaseHelper.getApi(
        url: getUserDetailUrl,
        useAuthToken: true,
        params: {},
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required File profile,
    required type,required id
  }) async {
    try {

      print("FILE PHTOT $profile");
      print("FILE PHTOT  ID $id");
      print("FILE PHTOT  ID $type");


     // await ApiBaseHelper.postProfile(
     //    url: "$updateProfileurl/$id/photo",
     //    useAuthToken: true,
     //    profile: profile,
     //
     //  );
      await Future.delayed(Duration(seconds: 2));
      final response = await ApiBaseHelper.postProfile(
        url: "$updateProfileUrl/photo",
        useAuthToken: true,
        profile: profile,
        type:type,
        id:id
      );
      print(response);
      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      return {
        'data': {'error': true, 'message': error.toString()}
      };    }
  }


  Future<Map<String, dynamic>> updateProfileDeatils({
    required String firstname,
    required String lastname,
    required int role,
    required String email,
    required String address,
     String? password,
     String? conPassword,
    required String phone,
    required String countryCode,
    required String countryIsoCode,
    required String city,
  }) async {
    try {
      Map<String, dynamic> body = {
        "first_name": firstname,
        "last_name": lastname,
        "role": role,
        "email": email,
        "address": address,
        "phone": phone,
        "password": password,
        "password_confirmation":conPassword,
        "country_code": countryCode,
        "country_iso_code": countryIsoCode,
        "city": city,
      };
      var box = await Hive.openBox(userBox);
      var id = box.get('user_id');
      final response = await ApiBaseHelper.post(
        url: "$updateProfilDetailsUrl/$id/profile",
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

}
