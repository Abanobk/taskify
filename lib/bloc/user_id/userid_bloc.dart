import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/model/user_model.dart';

import '../../api_helper/api.dart';

import '../../data/repositories/user/user_repo.dart';
import 'userid_event.dart';
import 'userid_state.dart';

class UseridBloc extends Bloc<UseridEvent, UseridState> {
  UseridBloc() : super(UseridInitial()) {
    on<UserIdListId>(_getuserListId);
  }
  Future<void> _getuserListId(
      UserIdListId event, Emitter<UseridState> emit) async {
    try {
      // emit(UseridLoading()); // Ensure loading state is shown first

      List<User> users = [];
      List<User> existingusers = [];

      if (state is UseridWithId) {
        existingusers = List.from((state as UseridWithId).user);
      }

      // Fetch users from API
      Map<String, dynamic> result = await UserRepo().getUsers(
        id: event.id,
        token: true,
      );

      users = List<User>.from(
        result['data'].map((userData) => User.fromJson(userData)),
      );

      // If the user list already exists, update it
      bool found = false;
      for (int i = 0; i < existingusers.length; i++) {
        if (existingusers[i].id == event.id) {
          existingusers[i] = users.first;
          found = true;
          break;
        }
      }

      if (!found) {
        existingusers.addAll(users);
      }

      emit(UseridWithId(existingusers)); // Emit the updated user list
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(UserIdError("Error: $e")); // Emit error state if API fails
    }
  }

}
