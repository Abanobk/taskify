import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/workspace/workspace_model.dart';

abstract class WorkspaceState extends Equatable{
  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {}
class WorkspaceLoading extends WorkspaceState {}
class WorkspaceSuccess extends WorkspaceState {
  WorkspaceSuccess([this.workspace=const []]);

  final List<WorkspaceModel> workspace;

  @override
  List<Object> get props => [workspace];
}
class WorkspaceError extends WorkspaceState {
  final String errorMessage;
  WorkspaceError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class WorkspaceDeleteSuccess extends WorkspaceState {
  WorkspaceDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class WorkspaceDeleteError extends WorkspaceState {
  final String errorMessage;
  WorkspaceDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class WorkspacePaginated extends WorkspaceState {
  final List<WorkspaceModel> workspace;
  final bool hasReachedMax;
  final bool isLoading;

  WorkspacePaginated({
    required this.workspace,
    required this.hasReachedMax,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [workspace, hasReachedMax, isLoading];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkspacePaginated &&
        other.workspace == workspace &&
        other.hasReachedMax == hasReachedMax &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(workspace, hasReachedMax, isLoading);
}


class  WorkspaceCreateError extends  WorkspaceState {
  final String errorMessage;

  WorkspaceCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  WorkspaceEditError extends  WorkspaceState {
  final String errorMessage;

  WorkspaceEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  WorkspaceEditSuccess extends  WorkspaceState {
  WorkspaceEditSuccess();
  @override
  List<Object> get props => [];
}
class WorkspaceCreateSuccessLoading extends WorkspaceState {}
class WorkspaceEditSuccessLoading extends WorkspaceState {}
class  WorkspaceCreateSuccess extends  WorkspaceState {
  WorkspaceCreateSuccess();
  @override
  List<Object> get props => [];
}
class  CreatePrimaryWorkspaceSuccess extends  WorkspaceState {
 final int id;
  CreatePrimaryWorkspaceSuccess(this.id);
  @override
  List<Object> get props => [id];
}