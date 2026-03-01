import 'package:equatable/equatable.dart';

import '../../data/model/Project/all_project.dart';




abstract class ProjectidState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ProjectidInitial extends ProjectidState {}

class ProjectidLoading extends ProjectidState {}
class ProjectidWithId extends ProjectidState {
  final List<ProjectModel> project;

  ProjectidWithId(
      this.project,

      );
  @override
  List<Object> get props => [project];
}
