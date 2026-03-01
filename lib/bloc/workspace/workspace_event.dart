import "package:equatable/equatable.dart";
import "package:taskify/data/model/workspace/workspace_model.dart";


abstract class WorkspaceEvent extends Equatable{
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}
class WorkspaceList extends WorkspaceEvent {

  const WorkspaceList();
  @override
  List<Object> get props => [];
}
class WorkspaceRemove extends WorkspaceEvent {
final int id;

const WorkspaceRemove({ required this.id});
  @override
  List<Object> get props => [id];
}
class RemoveUSerFromWorkspace extends WorkspaceEvent {
 final  int id;

  const RemoveUSerFromWorkspace({ required this.id});
  @override
  List<Object> get props => [id];
}
class SelectedWokspce extends WorkspaceEvent {
final int id;
final String title;
final bool isSelected;

const SelectedWokspce({ required this.id,required this.title,required this.isSelected});
  @override
  List<Object> get props => [id];
}
class SearchWorkspace extends WorkspaceEvent {
  final String searchQuery;

  const SearchWorkspace(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class LoadMoreWorkspace extends WorkspaceEvent {
  final String? searchQuery;
  const LoadMoreWorkspace({ this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}
class AllWorkspaceList extends WorkspaceEvent {

  const AllWorkspaceList();

  @override
  List<Object> get props => [];
}
class AddWorkspace extends WorkspaceEvent {
  final WorkspaceModel workspace;

   const AddWorkspace(this.workspace);

  @override
  List<Object?> get props => [workspace];
}
class UpdateWorkspace extends WorkspaceEvent {
  final WorkspaceModel workspace;

  const UpdateWorkspace(this.workspace);

  @override
  List<Object?> get props => [workspace];
}
class CreateRemoveWorkspace extends WorkspaceEvent {
  final int id;
  final int defaultPrimary;

  const CreateRemoveWorkspace({ required this.id,required this.defaultPrimary});
  @override
  List<Object> get props => [id];
}