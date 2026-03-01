import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/interview/interview_model.dart';



abstract class CandidateInterviewsState extends Equatable {
  const CandidateInterviewsState();

  @override
  List<Object?> get props => [];
}

class CandidateInterviewInitial extends CandidateInterviewsState {}

class CandidateInterviewssLoading extends CandidateInterviewsState {}

class CandidateInterviewssSuccess extends CandidateInterviewsState {
  const CandidateInterviewssSuccess([this.CandidateInterviewss=const []]);

  final List<InterviewModel> CandidateInterviewss;

  @override
  List<Object> get props => [CandidateInterviewss];
}

class CandidateInterviewssError extends CandidateInterviewsState {
  final String errorMessage;
  const CandidateInterviewssError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class CandidateInterviewssPaginated extends CandidateInterviewsState {
  final List<InterviewModel> CandidateInterviewss;
  final bool hasReachedMax;

  const CandidateInterviewssPaginated({
    required this.CandidateInterviewss,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [CandidateInterviewss, hasReachedMax];
}
class CandidateInterviewssCreateError extends CandidateInterviewsState {
  final String errorMessage;

  const CandidateInterviewssCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidateInterviewssEditError extends CandidateInterviewsState {
  final String errorMessage;

  const CandidateInterviewssEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidateInterviewssEditSuccessLoading extends CandidateInterviewsState {}
class CandidateInterviewssCreateSuccessLoading extends CandidateInterviewsState {}
class CandidateInterviewssEditSuccess extends CandidateInterviewsState {
  const CandidateInterviewssEditSuccess();
  @override
  List<Object> get props => [];
}
class CandidateInterviewssCreateSuccess extends CandidateInterviewsState {
  const CandidateInterviewssCreateSuccess();
  @override
  List<Object> get props => [];
}
class CandidateInterviewssDeleteError extends CandidateInterviewsState {
  final String errorMessage;

  const CandidateInterviewssDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidateInterviewssDeleteSuccess extends CandidateInterviewsState {
  const CandidateInterviewssDeleteSuccess();
  @override
  List<Object> get props => [];
}