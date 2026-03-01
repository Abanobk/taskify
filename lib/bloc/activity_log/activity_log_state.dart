import 'package:equatable/equatable.dart';

import '../../data/model/activity_log/activity_log_model.dart';

abstract class ActivityLogState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActivityLogInitial extends ActivityLogState {}

class ActivityLogLoading extends ActivityLogState {}


class ActivityLogError extends ActivityLogState {
  final String errorMessage;

  ActivityLogError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ActivityLogPaginated extends ActivityLogState {
  final List<ActivityLog> activityLog;
  final bool hasReachedMax;

  ActivityLogPaginated({
    required this.activityLog,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [activityLog, hasReachedMax];
}
class ActivityLogDeleteSuccess extends ActivityLogState {


  ActivityLogDeleteSuccess();

  @override
  List<Object> get props => [];
}
class ActivityLogDeleteError extends ActivityLogState {
  final String errorMessage;

  ActivityLogDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}