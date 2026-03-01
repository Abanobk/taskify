import 'package:equatable/equatable.dart';

import '../../data/model/interview/interview_model.dart';


abstract class InterviewsState extends Equatable {
  const InterviewsState();

  @override
  List<Object?> get props => [];
}

class InterviewsInitial extends InterviewsState {}

class InterviewsLoading extends InterviewsState {}

class InterviewsSuccess extends InterviewsState {
  const InterviewsSuccess([this.Interviews=const []]);

  final List<InterviewModel> Interviews;

  @override
  List<Object> get props => [Interviews];
}

class InterviewsError extends InterviewsState {
  final String errorMessage;
  const InterviewsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class InterviewsPaginated extends InterviewsState {
  final List<InterviewModel> Interviews;
  final bool hasReachedMax;

  const InterviewsPaginated({
    required this.Interviews,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Interviews, hasReachedMax];
}
class InterviewsCreateError extends InterviewsState {
  final String errorMessage;

  const InterviewsCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class InterviewsEditError extends InterviewsState {
  final String errorMessage;

  const InterviewsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class InterviewsEditSuccessLoading extends InterviewsState {}
class InterviewsCreateSuccessLoading extends InterviewsState {}
class InterviewsEditSuccess extends InterviewsState {
  const InterviewsEditSuccess();
  @override
  List<Object> get props => [];
}
class InterviewsCreateSuccess extends InterviewsState {
  const InterviewsCreateSuccess();
  @override
  List<Object> get props => [];
}
class InterviewsDeleteError extends InterviewsState {
  final String errorMessage;

  const InterviewsDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class InterviewsDeleteSuccess extends InterviewsState {
  const InterviewsDeleteSuccess();
  @override
  List<Object> get props => [];
}