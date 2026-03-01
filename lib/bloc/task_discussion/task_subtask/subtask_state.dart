import 'package:equatable/equatable.dart';

import '../../../data/model/project/milestone.dart';

abstract class SubTaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubTaskInitial extends SubTaskState {}
class SubTaskWithId extends SubTaskState {
  final List<Milestone> SubTask;

  SubTaskWithId(
      this.SubTask,

      );
  @override
  List<Object> get props => [SubTask];
}
class SubTaskLoading extends SubTaskState {}

class SubTaskSuccess extends SubTaskState {
  SubTaskSuccess(this.SubTask, this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<Milestone> SubTask;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;

  @override
  List<Object> get props =>
      [SubTask, selectedIndex!, selectedTitle,isLoadingMore];
}

class SubTaskPaginated extends SubTaskState {
  final List<Milestone> SubTask;
  final bool hasReachedMax;


  SubTaskPaginated({
    required this.SubTask,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [SubTask, hasReachedMax];
}
class SubTaskMileStonePaginated extends SubTaskState {
  final List<Milestone> SubTaskMilestone;
  final bool hasReachedMax;


  SubTaskMileStonePaginated({
    required this.SubTaskMilestone,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [SubTaskMilestone, hasReachedMax];
}

class SubTaskError extends SubTaskState {
  final String errorMessage;
  SubTaskError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SubTaskCreateLoading extends SubTaskState {}
class SubTaskCreateSuccess extends SubTaskState {
  final List<Milestone> createSubTask;
  SubTaskCreateSuccess(this.createSubTask);
  @override
  List<Object> get props =>
      [createSubTask];
}
class SubTaskEditLoading extends SubTaskState {}
class SubTaskEditSuccess extends SubTaskState {
  final List<Milestone> editSubTask;
  SubTaskEditSuccess(this.editSubTask);
  @override
  List<Object> get props =>
      [editSubTask];
}
class SubTaskCreateError extends SubTaskState {
  final String errorMessage;
  SubTaskCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SubTaskEditError extends SubTaskState {
  final String errorMessage;
  SubTaskEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SubTaskDeleteSuccess extends SubTaskState {
  SubTaskDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class SubTaskDeleteError extends SubTaskState {
  final String errorMessage;
  SubTaskDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}