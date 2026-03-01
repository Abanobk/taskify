import "package:equatable/equatable.dart";

import "../../data/model/leave_request/create_update_model.dart";
import "../../data/model/leave_request/leave_req_model.dart";


abstract class LeaveRequestEvent extends Equatable {
  const LeaveRequestEvent();
  @override
  List<Object?> get props => [];
}

class CreateLeaveRequest extends LeaveRequestEvent {
  final String reason;
  final String fromDate;
  final String toDate;
  final String fromTime;
  final String toTime;
  final String status;
  final String leaveVisibleToAll;
  final List<int> visibleToIds;
  final int userId;
  final String partialLeave;

  const CreateLeaveRequest(
      { required this.reason,
        required this.fromDate,
        required this.toDate,
        required this.fromTime,
        required this.toTime,
        required this.status,
        required this.leaveVisibleToAll,
        required this.visibleToIds,
        required this.userId,
        required this.partialLeave,

      });

  @override
  List<Object> get props => [reason, fromDate,toDate,fromTime,toTime,status,leaveVisibleToAll,visibleToIds,userId,partialLeave];
}

class LeaveRequestList extends LeaveRequestEvent {
  final String searchQuery;
  const LeaveRequestList(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class GetPendingLeaveRequest extends LeaveRequestEvent {

  const GetPendingLeaveRequest();

  @override
  List<Object?> get props => [];
}
class AddLeaveRequest extends LeaveRequestEvent {
  final CreateLeaveRequest leaveRequest;

  const AddLeaveRequest(this.leaveRequest);

  @override
  List<Object?> get props => [leaveRequest];
}

class UpdateLeaveRequest extends LeaveRequestEvent {
  final CreateUpdateModel updatedRequest;

  const UpdateLeaveRequest(this.updatedRequest);
  @override
  List<Object?> get props => [updatedRequest];

}

class DeleteLeaveRequest extends LeaveRequestEvent {
  final LeaveRequests leaveRequest;

  const DeleteLeaveRequest(this.leaveRequest);

  @override
  List<Object?> get props => [leaveRequest];
}

class SearchLeaveRequest extends LeaveRequestEvent {
  final String searchQuery;

  const SearchLeaveRequest(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class LoadMoreLeaveRequest extends LeaveRequestEvent {
  final String? searchQuery;
  const LoadMoreLeaveRequest(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class WeekLeaveReqList extends LeaveRequestEvent {
  final String fromDate;
  final String toDate;
  const WeekLeaveReqList(this.fromDate,this.toDate);

  @override
  List<Object> get props => [fromDate,toDate];
}