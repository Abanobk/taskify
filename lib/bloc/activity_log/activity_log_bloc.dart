import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/activity_log/activity_log_model.dart';
import '../../data/repositories/activity_log/activity_log_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'activity_log_event.dart';
import 'activity_log_state.dart';

class ActivityLogBloc extends Bloc<ActivityLogEvent, ActivityLogState> {
  int _offset = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  ActivityLogBloc() : super(ActivityLogInitial()) {
    on<AllActivityLogList>(_onAllActivityLog);
    on<SearchActivityLog>(_onSearchActivityLog);
    on<DeleteActivityLog>(_onDeleteActivityLogs);
    on<LoadMoreActivityLog>(_onLoadMoreActivityLog);
  }

  Future<void> _onAllActivityLog(
      AllActivityLogList event, Emitter<ActivityLogState> emit) async {
    try {
      List<ActivityLog> activity = [];
      _offset = 0;
      _hasReachedMax = false;
      emit(ActivityLogLoading());
      Map<String, dynamic> result = await ActivityLogRepo().activityLogList(
        limit: _limit,
        offset: _offset,
        search: '',
        type: event.type,
        typeId: event.typeId

      );
      activity = List<ActivityLog>.from(result['data']
          .map((projectData) => ActivityLog.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = activity.length < _limit;
      if (result['error'] == false) {
        emit(ActivityLogPaginated(
            activityLog: activity, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ActivityLogError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ActivityLogError("Error: $e")));
    }
  }

  Future<void> _onSearchActivityLog(
      SearchActivityLog event, Emitter<ActivityLogState> emit) async {
    try {
      List<ActivityLog> activity = [];
      emit(ActivityLogLoading());
      Map<String, dynamic> result = await ActivityLogRepo().activityLogList(
        limit: _limit,
        offset: 0,
        search: event.searchQuery,
        typeId: event.typeId,
        type: event.type      );
      activity = List<ActivityLog>.from(result['data']
          .map((projectData) => ActivityLog.fromJson(projectData)));
      bool hasReachedMax = activity.length < _limit;
      if (result['error'] == false) {
        emit(ActivityLogPaginated(
            activityLog: activity, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ActivityLogError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ActivityLogError("Error: $e"));
    }
  }

  void _onDeleteActivityLogs(
      DeleteActivityLog event, Emitter<ActivityLogState> emit) async {
    // if (emit is NotesSuccess) {
    final note = event.activityLog;
    try {
      Map<String, dynamic> result = await ActivityLogRepo().deleteActivityLog(
        id: note.toString(),
        token: true,
      );
      if (result['error'] == false) {
        emit(ActivityLogDeleteSuccess());
        add(AllActivityLogList());
      }
      if (result['error'] == true) {
        emit((ActivityLogDeleteError(result['message'])));
        // flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(ActivityLogDeleteError(e.toString()));

      add(AllActivityLogList());
    }
    // }
  }

  Future<void> _onLoadMoreActivityLog(
      LoadMoreActivityLog event, Emitter<ActivityLogState> emit) async {
    if (state is ActivityLogPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true;
      try {
        List<ActivityLog> activity = [];

        final currentState = state as ActivityLogPaginated;
        final updatedActivityLog =
        List<ActivityLog>.from(currentState.activityLog);

        // Fetch additional ActivityLogs from the repository
        Map<String, dynamic> result = await ActivityLogRepo().activityLogList(
          limit: _limit,
          offset: _offset,
          search: '',
        );

        activity = List<ActivityLog>.from(result['data']
            .map((projectData) => ActivityLog.fromJson(projectData)));

        // Update the offset for the next load by incrementing it by the limit
        _offset += _limit;

        // Check if we've reached the maximum number of records
        if (updatedActivityLog.length + activity.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched activity logs to the existing list
        updatedActivityLog.addAll(activity);

        if (result['error'] == false) {
          emit(ActivityLogPaginated(
              activityLog: updatedActivityLog, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(ActivityLogError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ActivityLogError("Error: $e"));
      }finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
