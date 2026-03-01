import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/candidate_status/candidate_status_model.dart';


abstract class CandidatesStatusState extends Equatable {
  const CandidatesStatusState();

  @override
  List<Object?> get props => [];
}

class CandidatesStatusInitial extends CandidatesStatusState {}

class CandidatesStatusLoading extends CandidatesStatusState {}

class CandidatesStatusSuccess extends CandidatesStatusState {
  const CandidatesStatusSuccess([this.CandidatesStatus=const []]);

  final List<CandidateStatusModel> CandidatesStatus;

  @override
  List<Object> get props => [CandidatesStatus];
}

class CandidatesStatusError extends CandidatesStatusState {
  final String errorMessage;
  const CandidatesStatusError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class CandidatesStatusPaginated extends CandidatesStatusState {
  final List<CandidateStatusModel> CandidatesStatus;
  final bool hasReachedMax;

  const CandidatesStatusPaginated({
    required this.CandidatesStatus,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [CandidatesStatus, hasReachedMax];
}
class CandidatesStatusCreateError extends CandidatesStatusState {
  final String errorMessage;

  const CandidatesStatusCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidatesStatusEditError extends CandidatesStatusState {
  final String errorMessage;

  const CandidatesStatusEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidatesStatusEditSuccessLoading extends CandidatesStatusState {}
class CandidatesStatusCreateSuccessLoading extends CandidatesStatusState {}
class CandidatesStatusEditSuccess extends CandidatesStatusState {
  const CandidatesStatusEditSuccess();
  @override
  List<Object> get props => [];
}
class CandidatesStatusCreateSuccess extends CandidatesStatusState {
  const CandidatesStatusCreateSuccess();
  @override
  List<Object> get props => [];
}
class CandidatesStatusDeleteError extends CandidatesStatusState {
  final String errorMessage;

  const CandidatesStatusDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidatesStatusDeleteSuccess extends CandidatesStatusState {
  final String message;
  const CandidatesStatusDeleteSuccess(this.message);
  @override
  List<Object> get props => [message];
}