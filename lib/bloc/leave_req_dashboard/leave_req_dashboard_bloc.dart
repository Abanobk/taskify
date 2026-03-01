import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../api_helper/api.dart';
import '../../data/model/leave_request/dashboard_leavereq.dart';
import '../../data/repositories/leave_request/leave_request_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'leave_req_dashboard_event.dart';
import 'leave_req_dashboard_state.dart';

class LeaveReqDashboardBloc
    extends Bloc<LeaveReqDashboardEvent, LeaveReqDashboardState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  LeaveReqDashboardBloc() : super(LeaveRequestDashboardInitial()) {
    on<WeekLeaveReqListDashboard>(_onWeekLeavereq);
    on<WeekLeaveReqListDashboardLoadMore>(_onLoadMoreLeaveReq);
    on<UpdateSelectedUsersLeaveRequest>(_onUpdateSelectedUsers);

  }
  Future<void> _onUpdateSelectedUsers(UpdateSelectedUsersLeaveRequest event, Emitter<LeaveReqDashboardState> emit)
  async {
    if (kDebugMode) {
      print(
          'UpdateSelectedUsers: userSelectedname=${event.userSelectedname}, userSelectedId=${event.userSelectedId}');
    }
    if (state is LeaveRequestDashboardSuccess) {
      final currentState = state as LeaveRequestDashboardSuccess;
      emit(currentState.copyWith(
        userSelectedname: event.userSelectedname,
        userSelectedId: event.userSelectedId,
      ));
    } else {
      emit(LeaveRequestDashboardSuccess(
        leave: [],
        hasReachedMax: false,
        userSelectedname: event.userSelectedname,
        userSelectedId: event.userSelectedId,

      ));
    }
  }

  Future<void> _onWeekLeavereq(WeekLeaveReqListDashboard event, Emitter<LeaveReqDashboardState> emit) async {
    try {
      emit(LeaveRequestDashboardLoading());
      _offset = 0;
      _hasReachedMax = false;

      // 🌐 API call
      final result = await LeaveRequestRepo().memberOnLeaveRequestList(
        limit: _limit,
        offset: _offset,
        token: true,
        upcomingDays: event.upComingDays,
        userId: event.userID,
        search: '',
      );

      final leave = List<DashBoardLeaveReq>.from(
        result['data']?.map((projectData) => DashBoardLeaveReq.fromJson(projectData)) ?? [],
      );

      _offset += _limit;
      _hasReachedMax = leave.length < _limit;

      if (result['error'] == false) {
        // ✅ Preserve names from state if available
        final userSelectedname = state is LeaveRequestDashboardSuccess
            ? (state as LeaveRequestDashboardSuccess).userSelectedname
            : event.userNames;

        emit(LeaveRequestDashboardSuccess(
          leave: leave,
          hasReachedMax: _hasReachedMax,
          userSelectedname: userSelectedname ?? [],
          userSelectedId: event.userID ,
        ));
      } else {
        emit(LeaveRequestDasdhboardError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('WeekLeavereq error: $e');
      }
      emit(LeaveRequestDasdhboardError("Error: $e"));
      flutterToastCustom(msg: "$e");
    }
  }
  Future<void> _onLoadMoreLeaveReq(WeekLeaveReqListDashboardLoadMore event, Emitter<LeaveReqDashboardState> emit) async {
    if (state is LeaveRequestDashboardSuccess && !_hasReachedMax) {
      try {
        final currentState = state as LeaveRequestDashboardSuccess;
        final updatedLeave = List<DashBoardLeaveReq>.from(currentState.leave);

        Map<String, dynamic> result = await LeaveRequestRepo().memberOnLeaveRequestList(
          limit: _limit,
          offset: _offset,
          token: true,
          upcomingDays: event.upComingDays,
          userId: event.userID,
          search: '',
        );

        final additional = List<DashBoardLeaveReq>.from(
          result['data']?.map((projectData) => DashBoardLeaveReq.fromJson(projectData)) ?? [],
        );

        _offset = updatedLeave.length + additional.length;
        _hasReachedMax = updatedLeave.length + additional.length >= result['total'];
        updatedLeave.addAll(additional);

        if (result['error'] == false) {
          emit(currentState.copyWith(
            leave: updatedLeave,
            hasReachedMax: _hasReachedMax,
            userSelectedname: currentState.userSelectedname,
            userSelectedId: currentState.userSelectedId,
          ));
        } else {
          emit(LeaveRequestDasdhboardError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print('LoadMoreLeaveReq error: $e');
        }
        emit(LeaveRequestDasdhboardError("Error: $e"));
        flutterToastCustom(msg: "$e");
      }
    }
  }}
