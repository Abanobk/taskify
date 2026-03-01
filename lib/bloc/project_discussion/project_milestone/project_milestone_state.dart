import 'package:equatable/equatable.dart';

import '../../../data/model/project/milestone.dart';

abstract class ProjectMilestoneState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectMilestoneInitial extends ProjectMilestoneState {}
class ProjectMilestoneWithId extends ProjectMilestoneState {
  final List<Milestone> ProjectMilestone;

  ProjectMilestoneWithId(
      this.ProjectMilestone,

      );
  @override
  List<Object> get props => [ProjectMilestone];
}
class ProjectMilestoneLoading extends ProjectMilestoneState {}

class ProjectMilestoneSuccess extends ProjectMilestoneState {
  ProjectMilestoneSuccess(this.ProjectMilestone, this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<Milestone> ProjectMilestone;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;

  @override
  List<Object> get props =>
      [ProjectMilestone, selectedIndex!, selectedTitle,isLoadingMore];
}

class ProjectMilestonePaginated extends ProjectMilestoneState {
  final List<Milestone> ProjectMilestone;
  final bool hasReachedMax;


  ProjectMilestonePaginated({
    required this.ProjectMilestone,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectMilestone, hasReachedMax];
}
class ProjectMilestoneMileStonePaginated extends ProjectMilestoneState {
  final List<Milestone> ProjectMilestoneMilestone;
  final bool hasReachedMax;


  ProjectMilestoneMileStonePaginated({
    required this.ProjectMilestoneMilestone,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectMilestoneMilestone, hasReachedMax];
}

class ProjectMilestoneError extends ProjectMilestoneState {
  final String errorMessage;
  ProjectMilestoneError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMilestoneCreateLoading extends ProjectMilestoneState {}
class ProjectMilestoneCreateSuccess extends ProjectMilestoneState {
  final List<Milestone> createProjectMilestone;
  ProjectMilestoneCreateSuccess(this.createProjectMilestone);
  @override
  List<Object> get props =>
      [createProjectMilestone];
}
class ProjectMilestoneEditLoading extends ProjectMilestoneState {}
class ProjectMilestoneEditSuccess extends ProjectMilestoneState {
  final List<Milestone> editProjectMilestone;
  ProjectMilestoneEditSuccess(this.editProjectMilestone);
  @override
  List<Object> get props =>
      [editProjectMilestone];
}
class ProjectMilestoneCreateError extends ProjectMilestoneState {
  final String errorMessage;
  ProjectMilestoneCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMilestoneEditError extends ProjectMilestoneState {
  final String errorMessage;
  ProjectMilestoneEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMilestoneDeleteSuccess extends ProjectMilestoneState {
  ProjectMilestoneDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class ProjectMilestoneDeleteError extends ProjectMilestoneState {
  final String errorMessage;
  ProjectMilestoneDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}