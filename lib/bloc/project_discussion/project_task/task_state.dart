import 'package:equatable/equatable.dart';

import '../../../data/model/task/task_model.dart';


abstract class ProjectTaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends ProjectTaskState {}
class TaskLoading extends ProjectTaskState {}
class TodaysTaskLoading extends ProjectTaskState {}
class TaskSuccess extends ProjectTaskState {
  TaskSuccess(this.ProjectTask,);

  final List<Tasks> ProjectTask;

  @override
  List<Object> get props => [ProjectTask];
}
class AllTaskSuccess extends ProjectTaskState {
  AllTaskSuccess(this.allTask,);

  final List<Tasks> allTask;

  @override
  List<Object> get props => [allTask];
}
class TaskError extends ProjectTaskState {
  final String errorMessage;

  TaskError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskPaginated extends ProjectTaskState {
  final List<Tasks> ProjectTask;
  final bool hasReachedMax;

  TaskPaginated({
    required this.ProjectTask,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectTask, hasReachedMax];
}
class TodayTaskSuccess extends ProjectTaskState {
  final List<Tasks> ProjectTask;
  final bool hasReachedMax;

  TodayTaskSuccess({
    required this.ProjectTask,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectTask, hasReachedMax];
}
class TaskCreateError extends ProjectTaskState {
  final String errorMessage;

  TaskCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskEditError extends ProjectTaskState {
  final String errorMessage;

  TaskEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskFavPaginated extends ProjectTaskState {
  final List<Tasks> ProjectTask;
  final bool hasReachedMax;


  TaskFavPaginated({
    required this.ProjectTask,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectTask, hasReachedMax];
}
class TaskEditSuccessLoading extends ProjectTaskState {}
class TaskEditSuccess extends ProjectTaskState {
  TaskEditSuccess();
  @override
  List<Object> get props => [];
}
class TaskCreateSuccessLoading extends ProjectTaskState {}
class TaskCreateSuccess extends ProjectTaskState {
  TaskCreateSuccess();
  @override
  List<Object> get props => [];
}
class TaskDeleteError extends ProjectTaskState {
  final String errorMessage;

  TaskDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskDeleteSuccess extends ProjectTaskState {
  TaskDeleteSuccess();
  @override
  List<Object> get props => [];
}