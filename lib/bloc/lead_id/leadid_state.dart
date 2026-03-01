import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/leads/leads_model.dart';




abstract class LeadidState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LeadidInitial extends LeadidState {}
class LeadIdError extends LeadidState {
  final String errorMessage;
  LeadIdError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class LeadidLoading extends LeadidState {}
class LeadidWithId extends LeadidState {
  final List<LeadModel> Lead;

  LeadidWithId(
      this.Lead,

      );
  @override
  List<Object> get props => [Lead];
}
