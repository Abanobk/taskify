import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/single_user/single_user_event.dart';
import 'package:taskify/bloc/single_user/single_user_state.dart';


import '../../data/model/user_model.dart';
import '../../data/repositories/user/user_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class SingleUserBloc extends Bloc<SingleUserEvent, SingleUserState> {
  int _offset = 0;
  final int _limit = 15;
  bool _hasReachedMax = false;

  SingleUserBloc() : super(SingleUserInitial()) {
    on<SingleUserList>(_getSingleUserList);
    on<SelectSingleUser>(_onSelectSingleUser);
    on<SingleUserLoadMore>(_onLoadMoreSingleUsers);
    on<SearchSingleUser>(_onSearchSingleeUser);

  }
  Future<void> _onSearchSingleeUser(
      SearchSingleUser event, Emitter<SingleUserState> emit) async {
    try {
      List<User> userSingle = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await UserRepo().getUsers(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          token: true);
      userSingle = List<User>.from(
          result['data'].map((projectData) => User.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =userSingle.length >= result['total'];
      if (result['error'] == false) {
        emit(SingleUserSuccess(userSingle, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(SingleUserError(result['message']));
      }
    } on ApiException catch (e) {
      emit(SingleUserError("Error: $e"));
    }
  }
  Future<void> _getSingleUserList(
      SingleUserList event, Emitter<SingleUserState> emit) async {
    try {
      emit(SingleUserLoading());
      _offset = 0; // Reset offset
      _hasReachedMax = false;

      final result = await UserRepo().getUsers(
        token: true,
        offset: _offset,
        limit: _limit,
      );

      if (result['error'] == false) {
        final users = List<User>.from(result['data']
            .map((userJson) => User.fromJson(userJson)));

        _offset += users.length;
        _hasReachedMax = users.length < _limit;

        emit(SingleUserSuccess(users, -1, '', _hasReachedMax));
      } else {
        emit(SingleUserError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(SingleUserError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreSingleUsers(
      SingleUserLoadMore event, Emitter<SingleUserState> emit) async {
    if (state is SingleUserSuccess && !_hasReachedMax) {
      final currentState = state as SingleUserSuccess;
      try {
        final result = await UserRepo().getUsers(
          token: true,
          offset: _offset,
          limit: _limit,
        );

        if (result['error'] == false) {
          final moreUsers = List<User>.from(result['data']
              .map((userJson) => User.fromJson(userJson)));

          _offset += moreUsers.length;
          _hasReachedMax = moreUsers.length < _limit;

          emit(SingleUserSuccess(
            [...currentState.user, ...moreUsers],
            currentState.selectedIndex,
            currentState.selectedTitle,
            _hasReachedMax,
          ));
        } else {
          emit(SingleUserError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) print(e);
        emit(SingleUserError("Error: $e"));
      }
    }
  }

  void _onSelectSingleUser(
      SelectSingleUser event, Emitter<SingleUserState> emit) {
    if (state is SingleUserSuccess) {
      final currentState = state as SingleUserSuccess;
      emit(SingleUserSuccess(
        currentState.user,
        event.selectedIndex,
        event.selectedTitle,
        currentState.isLoadingMore,
      ));
    }
  }
}
