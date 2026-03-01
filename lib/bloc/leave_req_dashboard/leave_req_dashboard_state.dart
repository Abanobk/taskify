import "package:equatable/equatable.dart";
import "../../data/model/leave_request/dashboard_leavereq.dart";




abstract class LeaveReqDashboardState extends Equatable{
  const LeaveReqDashboardState();

  @override
  List<Object?> get props => [];
}

class LeaveRequestDashboardInitial extends LeaveReqDashboardState {}

class LeaveRequestDashboardLoading extends LeaveReqDashboardState {}
class LeaveRequestDashboardSuccess extends LeaveReqDashboardState {
  final List<DashBoardLeaveReq> leave;
  final bool hasReachedMax;
  final List<String> userSelectedname;
  final List<int> userSelectedId;


  const LeaveRequestDashboardSuccess({
    required this.leave,
    required this.hasReachedMax,
    required this.userSelectedname,
    required this.userSelectedId,

  });

  @override
  List<Object> get props => [leave, hasReachedMax,    userSelectedname,
    userSelectedId,
];
  LeaveRequestDashboardSuccess copyWith({
    List<DashBoardLeaveReq>? leave,
    bool? hasReachedMax,
    List<String>? userSelectedname,
    List<int>? userSelectedId,
    List<String>? clientSelectedname,
    List<int>? clientSelectedId,
  }) {
    return LeaveRequestDashboardSuccess(
      leave: leave ?? this.leave,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      userSelectedname: userSelectedname ?? this.userSelectedname,
      userSelectedId: userSelectedId ?? this.userSelectedId,

    );
  }
}
class LeaveRequestDasdhboardError extends LeaveReqDashboardState {
  final String errorMessage;

  const LeaveRequestDasdhboardError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class UpdateSelectedUsersLeaveReq extends LeaveReqDashboardState {
  final List<String> userSelectedname;
  final List<int> userSelectedId;

  UpdateSelectedUsersLeaveReq(this.userSelectedname, this.userSelectedId);

  @override
  List<Object> get props => [userSelectedname, userSelectedId];
}


