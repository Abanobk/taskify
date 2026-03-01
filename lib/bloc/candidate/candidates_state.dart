import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/candidate/candidate_model.dart';


abstract class CandidatesState extends Equatable {
  const CandidatesState();

  @override
  List<Object?> get props => [];
}

class CandidatesInitial extends CandidatesState {}

class CandidatesLoading extends CandidatesState {}

class CandidatesSuccess extends CandidatesState {
  const CandidatesSuccess([this.Candidates=const []]);

  final List<CandidateModel> Candidates;

  @override
  List<Object> get props => [Candidates];
}

class CandidatesError extends CandidatesState {
  final String errorMessage;
  const CandidatesError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DrawingCandidateUpdated extends CandidatesState {
  final String drawing;
  const DrawingCandidateUpdated(this.drawing);

  @override
  List<Object> get props => [drawing];
}
class CandidatesPaginated extends CandidatesState {
  final List<CandidateModel> Candidates;
  final bool hasReachedMax;

  const CandidatesPaginated({
    required this.Candidates,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Candidates, hasReachedMax];
}
class CandidatesCreateError extends CandidatesState {
  final String errorMessage;

  const CandidatesCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidatesEditError extends CandidatesState {
  final String errorMessage;

  const CandidatesEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidatesEditSuccessLoading extends CandidatesState {}
class CandidatesCreateSuccessLoading extends CandidatesState {}
class CandidatesEditSuccess extends CandidatesState {
  const CandidatesEditSuccess();
  @override
  List<Object> get props => [];
}
class CandidatesCreateSuccess extends CandidatesState {
  const CandidatesCreateSuccess();
  @override
  List<Object> get props => [];
}
class CandidatesDeleteError extends CandidatesState {
  final String errorMessage;

  const CandidatesDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CandidatesDeleteSuccess extends CandidatesState {
  const CandidatesDeleteSuccess();
  @override
  List<Object> get props => [];
}
class DownloadSuccess extends CandidatesState {
  final String filePath;
  final String fileName;
  DownloadSuccess(this.filePath,this.fileName);

  @override
  List<Object?> get props => [filePath];
}