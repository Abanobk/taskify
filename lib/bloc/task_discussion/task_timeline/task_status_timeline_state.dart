part of 'task_status_timeline_bloc.dart';

abstract class TaskStatusTimelineState extends Equatable{
  @override
  List<Object?> get props => [];
}

final class StatusTimelineInitial extends TaskStatusTimelineState {}

class TaskStatusTimelineLoading extends TaskStatusTimelineState {}

class TaskStatusTimelineSuccess extends TaskStatusTimelineState {}
class TaskStatusTimelinePaginated extends TaskStatusTimelineState {
  final List<StatusTimelineModel> TaskTimeline;
  final bool hasReachedMax;


  TaskStatusTimelinePaginated({
    required this.TaskTimeline,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [TaskTimeline, hasReachedMax];
}
class TaskStatusTimelineError extends TaskStatusTimelineState {
  final String errorMessage;
  TaskStatusTimelineError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class TaskStatusTimelineDeleteSuccess extends TaskStatusTimelineState {
  TaskStatusTimelineDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
