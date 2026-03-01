import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/Birthday/birthday_model.dart';
import '../../data/repositories/Birthday/birthday_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'birthday_event.dart';
import 'birthday_state.dart';

class BirthdayBloc extends Bloc<BirthdayEvent, BirthdayState> {
    int _offset = 0;
    final int _limit = 10;
    bool _hasReachedMax = false;

    BirthdayBloc() : super(BirthdayInitial()) {
      on<WeekBirthdayList>(_onWeekBirthday);
      on<LoadMoreBirthday>(_onLoadMoreBirthday);
      on<UpdateSelectedUsers>(_onUpdateSelectedUsers);
      on<UpdateSelectedClients>(_onUpdateSelectedClients);
    }
    Future<void> _onUpdateSelectedUsers(UpdateSelectedUsers event, Emitter<BirthdayState> emit) async {
    if (kDebugMode) {
      print(
          'UpdateSelectedUsers: userSelectedname=${event.userSelectedname}, userSelectedId=${event.userSelectedId}');
    }
    if (state is TodayBirthdaySuccess) {
      final currentState = state as TodayBirthdaySuccess;
      emit(currentState.copyWith(
        userSelectedname: event.userSelectedname,
        userSelectedId: event.userSelectedId,
      ));
    } else {
      emit(TodayBirthdaySuccess(
        birthday: [],
        hasReachedMax: false,
        userSelectedname: event.userSelectedname,
        userSelectedId: event.userSelectedId,
        clientSelectedname: [],
        clientSelectedId: [],
      ));
    }
  }

  Future<void> _onUpdateSelectedClients(UpdateSelectedClients event, Emitter<BirthdayState> emit) async {
    if (kDebugMode) {
      print(
          'UpdateSelectedClients: clientSelectedname=${event.clientSelectedname}, clientSelectedId=${event.clientSelectedId}');
    }
    if (state is TodayBirthdaySuccess) {
      final currentState = state as TodayBirthdaySuccess;
      emit(currentState.copyWith(
        clientSelectedname: event.clientSelectedname,
        clientSelectedId: event.clientSelectedId,
      ));
    } else {
      emit(TodayBirthdaySuccess(
        birthday: [],
        hasReachedMax: false,
        userSelectedname: [],
        userSelectedId: [],
        clientSelectedname: event.clientSelectedname,
        clientSelectedId: event.clientSelectedId,
      ));
    }
  }
  Future<void> _onWeekBirthday(WeekBirthdayList event, Emitter<BirthdayState> emit) async {
    try {
      emit(TodaysBirthdayLoading());
      _offset = 0;
      _hasReachedMax = false;

      // 🌐 API call
      final result = await BirthdayRepo().getBirthday(
        limit: _limit,
        offset: _offset,
        token: true,
        upComingDays: event.upcomingDays,
        userId: event.userId,
        clientId: event.clientId,
      );

      final birthday = List<BirthdayModel>.from(
        result['data']
            .map((projectData) => BirthdayModel.fromJson(projectData)),
      );

      _offset += _limit;
      _hasReachedMax = birthday.length < _limit;

      if (result['error'] == false) {
        // ✅ Preserve names from state if available
        final userSelectedname = state is TodayBirthdaySuccess
            ? (state as TodayBirthdaySuccess).userSelectedname
            : event.userNames;

        final clientSelectedname = state is TodayBirthdaySuccess
            ? (state as TodayBirthdaySuccess).clientSelectedname
            : event.clientNames;

        emit(TodayBirthdaySuccess(
          birthday: birthday,
          hasReachedMax: _hasReachedMax,
          userSelectedname: userSelectedname!,
          userSelectedId: event.userId!,
          clientSelectedId: event.clientId!,
          clientSelectedname: clientSelectedname!,
        ));
      } else {
        emit(BirthdayError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(BirthdayError("Error: $e"));
      flutterToastCustom(msg: "$e");
    }
  }

  Future<void> _onLoadMoreBirthday(LoadMoreBirthday event, Emitter<BirthdayState> emit) async {
    if (state is TodayBirthdaySuccess && !_hasReachedMax) {
      try {
        final currentState = state as TodayBirthdaySuccess;
        final updatedBirthday = List<BirthdayModel>.from(currentState.birthday);
        Map<String, dynamic> result = await BirthdayRepo().getBirthday(
          limit: _limit,
          offset: _offset,
          token: true,
          upComingDays: event.upcomingDays,
          userId: event.userId,
          clientId: event.clientId,
        );
        final birthday = List<BirthdayModel>.from(result['data']
            .map((projectData) => BirthdayModel.fromJson(projectData)));

        _offset = updatedBirthday.length + birthday.length;
        _hasReachedMax =
            updatedBirthday.length + birthday.length >= result['total'];
        updatedBirthday.addAll(birthday);

        if (result['error'] == false) {
          emit(currentState.copyWith(
            birthday: updatedBirthday,
            hasReachedMax: _hasReachedMax,
            userSelectedname: currentState.userSelectedname,
            userSelectedId: currentState.userSelectedId,
            clientSelectedname: currentState.clientSelectedname,
            clientSelectedId: currentState.clientSelectedId,
          ));
        } else {
          emit(BirthdayError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print('LoadMoreBirthday error: $e');
        }
        emit(BirthdayError("Error: $e"));
        flutterToastCustom(msg: "$e");
      }
    }
  }


}
