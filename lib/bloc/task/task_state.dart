import 'package:equatable/equatable.dart';

import '../../data/model/task/task_model.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TodaysTaskLoading extends TaskState {}
class TaskSuccess extends TaskState {
  TaskSuccess(this.task,);

  final List<Tasks> task;

  @override
  List<Object> get props => [task];
}
class AllTaskSuccess extends TaskState {
  AllTaskSuccess(this.allTask,);

  final List<Tasks> allTask;

  @override
  List<Object> get props => [allTask];
}
class TaskError extends TaskState {
  final String errorMessage;

  TaskError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskPaginated extends TaskState {
  final List<Tasks> task;
  final bool hasReachedMax;
  final bool isToday;

  TaskPaginated({
    required this.task,
    required this.hasReachedMax,
    required this.isToday,
  });

  @override
  List<Object> get props => [task, hasReachedMax,isToday];
}
class TodayTaskSuccess extends TaskState {
  final List<Tasks> task;
  final bool hasReachedMax;

  TodayTaskSuccess({
    required this.task,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [task, hasReachedMax];
}
class TaskCreateError extends TaskState {
  final String errorMessage;

  TaskCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskEditError extends TaskState {
  final String errorMessage;

  TaskEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskFavPaginated extends TaskState {
  final List<Tasks> task;
  final bool hasReachedMax;


  TaskFavPaginated({
    required this.task,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [task, hasReachedMax];
}
class TaskEditSuccessLoading extends TaskState {}
class TaskEditSuccess extends TaskState {
  TaskEditSuccess();
  @override
  List<Object> get props => [];
}
class TaskCreateSuccessLoading extends TaskState {}
class TaskCreateSuccess extends TaskState {
  TaskCreateSuccess();
  @override
  List<Object> get props => [];
}
class TaskDeleteError extends TaskState {
  final String errorMessage;

  TaskDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskDeleteSuccess extends TaskState {
  TaskDeleteSuccess();
  @override
  List<Object> get props => [];
}