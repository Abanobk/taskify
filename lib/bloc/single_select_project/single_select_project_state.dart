
import 'package:equatable/equatable.dart';

import '../../data/model/Project/all_project.dart';



abstract class SingleSelectProjectState extends Equatable{
  @override
  List<Object?> get props => [];
}

class SingleProjectInitial extends SingleSelectProjectState {}
class SingleProjectLoading extends SingleSelectProjectState {}
class SingleProjectSuccess extends SingleSelectProjectState {
  SingleProjectSuccess(this.project,this.selectedIndex, this.selectedTitle,this.hasReachedMax);
  final List<ProjectModel> project;
  final int? selectedIndex;
  final String selectedTitle;
  final bool hasReachedMax;
  @override
  List<Object> get props => [project,selectedIndex!,selectedTitle,hasReachedMax];
}

class SingleProjectError extends SingleSelectProjectState {
  final String errorMessage;
  SingleProjectError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
