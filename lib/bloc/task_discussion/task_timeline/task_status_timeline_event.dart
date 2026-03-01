part of 'task_status_timeline_bloc.dart';

abstract class TaskStatusTimelineEvent extends Equatable{
  @override
  List<Object?> get props => [];
}
class TaskStatusTimelineList extends TaskStatusTimelineEvent {
  final int? id;


  TaskStatusTimelineList({this.id,});

  @override
  List<Object?> get props => [id];
}
class DeleteTaskMedia extends TaskStatusTimelineEvent {
  final int? id;


  DeleteTaskMedia({this.id,});

  @override
  List<Object?> get props => [id];
}
