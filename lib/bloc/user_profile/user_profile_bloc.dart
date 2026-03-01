import 'dart:async';
import 'package:hive/hive.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/user_profile/user_profile_event.dart';
import 'package:taskify/bloc/user_profile/user_profile_state.dart';
import '../../config/strings.dart';
import '../../data/model/user_profile/user_profile.dart';
import '../../data/repositories/Profile/profile_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  String? profilePic;
  int? userId;
  String? firstname;
  String? lastName;
  String? email;
  String? role;
  int? roleId;
  String? address;
  String? city;
  String? phone;
  String? country;
  String? countryCode;
  String? password;
  String? conPassword;
  String? countryIsoCode;
  UserProfileBloc() : super(UserProfileInitial()) {
    on<ProfileList>(_getProfileList);
    on<ProfileDetailsUpdateList>(_onUpdateProfile);
    on<ProfileListGet>(_getProfileListGet);
  }
  String? get selectedImage => profilePic;
  Future<void> _getProfileList(
      ProfileList event, Emitter<UserProfileState> emit) async {
    try {

      var box = await Hive.openBox(userBox);
      var id = box.get('user_id');

      List<ProfileModel> profile = [];
      Map<String, dynamic> result = await ProfileRepo().getProfile(
        token: true,
        id: id.toString(),
      );
      profile = List<ProfileModel>.from(result['data']
          .map((projectData) => ProfileModel.fromJson(projectData)));
      // String photo =  profile.first.photo!;
      //
      //  box.put("photo", photo);
      // var  Photo=  await box.get("photo");
      for (var photo in profile) {
        profilePic = photo.profile;
        var box = await Hive.openBox(userBox);
        await box.put('profilepic', profilePic);

      }
      if (result['error'] == false) {
        emit(UserProfileSuccess(profile));
        add(ProfileListGet());
      }
      if (result['error'] == true) {
        emit((UserProfileError(result['message'])));
        add(ProfileListGet());
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((UserProfileError("Error: $e")));
    }
  }

  Future<void> _getProfileListGet(
      ProfileListGet event, Emitter<UserProfileState> emit) async {
    try {

      emit(UserProfileLoading());

      List<ProfileModel> profile = [];
      Map<String, dynamic> result = await ProfileRepo().getUserProfileDetails();
      userId = result['data']['id'];
      firstname = result['data']['first_name'];
      lastName = result['data']['last_name'];
      email = result['data']['email'];
      role = result['data']['role'];
      roleId = result['data']['role_id'];
      address = result['data']['address'];
      city = result['data']['city'];
      profilePic=result['data']['profile'];
      countryIsoCode=result['data']['country_iso_code'];
      countryCode=result['data']['country_code'];
      phone=result['data']['phone'];
      password=result['data']['password'];
      conPassword=result['data']['password_confirmation'];

      if (result['error'] == false) {
        emit(UserProfileSuccess(profile));
      }
      if (result['error'] == true) {
        emit((UserProfileError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((UserProfileError("Error: $e")));
    }
  }

  void _onUpdateProfile(
      ProfileDetailsUpdateList event, Emitter<UserProfileState> emit) async {
    if (state is UserProfileSuccess) {
      emit(UserProfileLoading());
      print("_onUpdateProfile ${event.firstname}");
      print("_onUpdateProfile ${event.lastname}");
      print("_onUpdateProfile ${event.email}");
      print("_onUpdateProfile ${event.role}");
      print("_onUpdateProfile ${event.address}");
      print("_onUpdateProfile ${event.city}");

      try {
        Map<String, dynamic> result = await ProfileRepo().updateProfileDeatils(
            firstname: event.firstname,
            lastname: event.lastname,
            email: event.email,
            role: event.role,
            address: event.address,
            countryCode:event.countryCode,
            countryIsoCode:event.countryIsoCode,
            phone:event.phone,
            password:event.password,
            conPassword:event.conPassword,


            city: event.city);
        if (result['error'] == false) {
          emit(UserDetailUpdateSuccess());
          add(ProfileList());
        }
        if (result['error'] == true) {
          emit((UserDetailUpdateError(result['message'])));

          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating profile: $e');
        // Optionally, handle the error state, e.g., emit an error state
      }
    }
  }
}
