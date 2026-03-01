import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/leads/lead_Source.dart';


abstract class LeadSourceState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LeadSourceInitial extends LeadSourceState {}
class  LeadSourceEditSuccessLoading extends  LeadSourceState {}
class  LeadSourceCreateSuccessLoading extends  LeadSourceState {}
class LeadSourceLoading extends LeadSourceState {}
class LeadSourceSuccess extends LeadSourceState {
  LeadSourceSuccess(this.LeadSource,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<LeadSourceModel> LeadSource;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [LeadSource,selectedIndex!,selectedTitle,isLoadingMore];
}

class LeadSourceError extends LeadSourceState {
  final String errorMessage;
  LeadSourceError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadSourceEditLoading extends LeadSourceState {}
class LeadSourceCreateLoading extends LeadSourceState {}
class LeadSourceCreateSuccess extends LeadSourceState {}
class LeadSourceDeleteSuccess extends LeadSourceState {}

class LeadSourceEditSuccess extends LeadSourceState {

  LeadSourceEditSuccess();
  @override
  List<Object> get props =>
      [];
}

class LeadSourceCreateError extends LeadSourceState {
  final String errorMessage;
  LeadSourceCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadSourceEditError extends LeadSourceState {
  final String errorMessage;
  LeadSourceEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadSourceDeleteError extends LeadSourceState {
  final String errorMessage;
  LeadSourceDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
