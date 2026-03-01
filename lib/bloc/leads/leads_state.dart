import 'package:equatable/equatable.dart';

import '../../data/model/leads/leads_model.dart';


abstract class LeadState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LeadInitial extends LeadState {}
class  LeadEditSuccessLoading extends  LeadState {}
class  LeadCreateSuccessLoading extends  LeadState {}
class LeadLoading extends LeadState {}
class LeadSuccess extends LeadState {
  LeadSuccess(this.Lead,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<LeadModel> Lead;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [Lead,selectedIndex!,selectedTitle,isLoadingMore];
}

class LeadError extends LeadState {
  final String errorMessage;
  LeadError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadEditLoading extends LeadState {}
class LeadCreateLoading extends LeadState {}
class LeadCreateSuccess extends LeadState {}
class LeadCreateFollowUpSuccess extends LeadState {}
class LeadDeleteSuccess extends LeadState {}
class LeadDeleteFollowUpSuccess extends LeadState {}

class LeadEditSuccess extends LeadState {

  LeadEditSuccess();
  @override
  List<Object> get props =>
      [];
}
class LeadEditFollowUpSuccess extends LeadState {

  LeadEditFollowUpSuccess();
  @override
  List<Object> get props =>
      [];
}

class LeadCreateError extends LeadState {
  final String errorMessage;
  LeadCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadCreateFollowUpError extends LeadState {
  final String errorMessage;
  LeadCreateFollowUpError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}class LeadEditFollowUpError extends LeadState {
  final String errorMessage;
  LeadEditFollowUpError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadEditError extends LeadState {
  final String errorMessage;
  LeadEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadDeleteError extends LeadState {
  final String errorMessage;
  LeadDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
