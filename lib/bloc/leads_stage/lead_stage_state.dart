import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/leads/lead_stage.dart';


abstract class LeadStageState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LeadStageInitial extends LeadStageState {}
class  LeadStageEditSuccessLoading extends  LeadStageState {}
class  LeadStageCreateSuccessLoading extends  LeadStageState {}
class LeadStageLoading extends LeadStageState {}
class LeadStageSuccess extends LeadStageState {
  LeadStageSuccess(this.LeadStage,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<LeadStageModel> LeadStage;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [LeadStage,selectedIndex!,selectedTitle,isLoadingMore];
}

class LeadStageError extends LeadStageState {
  final String errorMessage;
  LeadStageError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadStageEditLoading extends LeadStageState {}
class LeadStageCreateLoading extends LeadStageState {}
class LeadStageCreateSuccess extends LeadStageState {}
class LeadStageDeleteSuccess extends LeadStageState {}

class LeadStageEditSuccess extends LeadStageState {

  LeadStageEditSuccess();
  @override
  List<Object> get props =>
      [];
}

class LeadStageCreateError extends LeadStageState {
  final String errorMessage;
  LeadStageCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadStageEditError extends LeadStageState {
  final String errorMessage;
  LeadStageEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadStageDeleteError extends LeadStageState {
  final String errorMessage;
  LeadStageDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
