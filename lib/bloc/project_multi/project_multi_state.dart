import 'package:equatable/equatable.dart';
import '../../data/model/Project/all_project.dart';

abstract class ProjectMultiState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ProjectMultiInitial extends ProjectMultiState {}

class ProjectMultiLoading extends ProjectMultiState {}

class ProjectMultiSuccess extends ProjectMultiState {
  final List<ProjectModel> projectMulti;
  final List<int> selectedIndices;
  final List<String> selectedProjectMultinames;
  final bool isLoadingMore;

  ProjectMultiSuccess({
    required this.projectMulti,
    this.selectedIndices = const [],
    this.selectedProjectMultinames = const [],
    this.isLoadingMore = false,
  });
}

class ProjectMultiPaginated extends ProjectMultiState {
  final List<ProjectModel> projectMulti;
  final bool hasReachedMax;

  ProjectMultiPaginated({
    required this.projectMulti,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [projectMulti, hasReachedMax];
}

class ProjectMultiSuccessCreate extends ProjectMultiState {


  ProjectMultiSuccessCreate();

  @override
  List<Object> get props => [];
}

class ProjectMultiError extends ProjectMultiState {
  final String errorMessage;
  ProjectMultiError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMultiCreateError extends ProjectMultiState {
  final String errorMessage;

  ProjectMultiCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMultiEditError extends ProjectMultiState {
  final String errorMessage;

  ProjectMultiEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMultiEditSuccess extends ProjectMultiState {
  ProjectMultiEditSuccess();
  @override
  List<Object> get props => [];
}
class ProjectMultiCreateSuccess extends ProjectMultiState {
  ProjectMultiCreateSuccess();
  @override
  List<Object> get props => [];
}

class ProjectMultiDeleteError extends ProjectMultiState {
  final String errorMessage;

  ProjectMultiDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ProjectMultiDeleteSuccess extends ProjectMultiState {
  ProjectMultiDeleteSuccess();
  @override
  List<Object> get props => [];
}