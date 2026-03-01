import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/Project/all_project.dart';


abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}
class ProjectMindMapSuccess extends ProjectState {
  final Map<String,dynamic> mindmap;
  ProjectMindMapSuccess(
      this.mindmap,

      );
  @override
  List<Object> get props => [mindmap];
}
class ProjectWithId extends ProjectState {
  final List<ProjectModel> project;

  ProjectWithId(
      this.project,

      );
  @override
  List<Object> get props => [project];
}
class ProjectLoading extends ProjectState {}
class ProjectMapLoading extends ProjectState {}

class ProjectSuccess extends ProjectState {
  ProjectSuccess(this.project, this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<ProjectModel> project;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;

  @override
  List<Object> get props =>
      [project, selectedIndex!, selectedTitle,isLoadingMore];
}

class ProjectPaginated extends ProjectState {
  final List<ProjectModel> project;
  final bool hasReachedMax;


  ProjectPaginated({
    required this.project,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [project, hasReachedMax];
}
class ProjectFavPaginated extends ProjectState {
  final List<ProjectModel> project;
  final bool hasReachedMax;


  ProjectFavPaginated({
    required this.project,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [project, hasReachedMax];
}


class ProjectError extends ProjectState {
  final String errorMessage;
  ProjectError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectCreateLoading extends ProjectState {}
class ProjectCreateSuccess extends ProjectState {
  final List<ProjectModel> createProject;
  ProjectCreateSuccess(this.createProject);
  @override
  List<Object> get props =>
      [createProject];
}
class ProjectEditLoading extends ProjectState {}
class ProjectEditSuccess extends ProjectState {
  final List<ProjectModel> editProject;
  ProjectEditSuccess(this.editProject);
  @override
  List<Object> get props =>
      [editProject];
}
class ProjectCreateError extends ProjectState {
  final String errorMessage;
  ProjectCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectEditError extends ProjectState {
  final String errorMessage;
  ProjectEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectDeleteSuccess extends ProjectState {
  ProjectDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class ProjectDeleteError extends ProjectState {
  final String errorMessage;
  ProjectDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}