import "package:equatable/equatable.dart";
import "../../data/model/leave_request/leave_req_model.dart";




abstract class LeaveRequestState extends Equatable{
  const LeaveRequestState();

  @override
  List<Object?> get props => [];
}

class LeaveRequestInitial extends LeaveRequestState {}

class LeaveRequestLoading extends LeaveRequestState {}
class TodayLeaveRequestLoading extends LeaveRequestState {}

class LeaveRequestSuccess extends LeaveRequestState {
  const LeaveRequestSuccess([this.leaveRequest=const []]);

  final List<LeaveRequests> leaveRequest;

  @override
  List<Object> get props => [leaveRequest];
}
class LeaveRequestError extends LeaveRequestState {
  final String errorMessage;
  const LeaveRequestError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeaveRequestPaginated extends LeaveRequestState {
  final List<LeaveRequests> leave;
  final bool hasReachedMax;
  final bool isLoading;

  const LeaveRequestPaginated({
    required this.leave,
    required this.hasReachedMax,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [leave, hasReachedMax, isLoading];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LeaveRequestPaginated &&
        other.leave == leave &&
        other.hasReachedMax == hasReachedMax &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(leave, hasReachedMax, isLoading);
}

class LeaveRequestCreateLoading extends LeaveRequestState {}
class LeaveRequestEditLoading extends LeaveRequestState {}
class LeaveRequestCreateError extends LeaveRequestState {
  final String errorMessage;

  const LeaveRequestCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeaveRequestEditError extends LeaveRequestState {
  final String errorMessage;

  const LeaveRequestEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeaveRequestEditSuccess extends LeaveRequestState {
  const LeaveRequestEditSuccess();
  @override
  List<Object> get props => [];
}
class LeaveRequestCreateSuccess extends LeaveRequestState {
  const LeaveRequestCreateSuccess();
  @override
  List<Object> get props => [];
}
class LeaveRequestDeleteSuccess extends LeaveRequestState {
  const LeaveRequestDeleteSuccess();
  @override
  List<Object> get props => [];
}
class LeaveRequestDeleteError extends LeaveRequestState {
  final String errorMessage;

  const LeaveRequestDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class TodayLeavereqSuccess extends LeaveRequestState {
  final List<LeaveRequests> leave;
  final int? upcomingDays;
  final List<int>? userId;
  final bool hasReachedMax;

  const TodayLeavereqSuccess({
    this.userId,this.upcomingDays,
    required this.leave,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [leave, hasReachedMax];
}