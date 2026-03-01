import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/model/Project/all_project.dart';


abstract class ProjectMultiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectMultiList extends ProjectMultiEvent {

  ProjectMultiList();
  @override
  List<Object> get props => [];
}
class ProjectMultiLoadMore extends ProjectMultiEvent {
  ProjectMultiLoadMore();

  @override
  List<Object?> get props => [];
}
class SelectedProjectMulti extends ProjectMultiEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedProjectMulti(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleProjectMultiSelection extends ProjectMultiEvent {
  final int projectMultiId;
  final String projectMultiName;

  ToggleProjectMultiSelection(this.projectMultiId, this.projectMultiName);
}
class ProjectMultisCreated extends ProjectMultiEvent {
  final ProjectModel projectMultiList;

  final File? image;
  final String? profileImage;
  // final ProjectMulti ProjectMulti;

  ProjectMultisCreated(this.projectMultiList,this.image,this.profileImage);
  @override
  List<Object> get props => [projectMultiList];
}
class AllProjectMultisList extends ProjectMultiEvent {

  AllProjectMultisList();

  @override
  List<Object> get props => [];
}
class UpdateProjectMultis extends ProjectMultiEvent {
  final ProjectModel projectMulti;

  UpdateProjectMultis(this.projectMulti);
  @override
  List<Object> get props => [projectMulti];
}

class DeleteProjectMultis extends ProjectMultiEvent {
  final int projectMultiId;

  DeleteProjectMultis(this.projectMultiId);

  @override
  List<Object?> get props => [projectMultiId];
}
class SearchProjectMultis extends ProjectMultiEvent {
  final String searchQuery;

  SearchProjectMultis(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
