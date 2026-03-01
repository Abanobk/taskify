import 'package:equatable/equatable.dart';
import '../../data/model/meetings/meeting_model.dart';

abstract class MeetingState extends Equatable {
  const MeetingState();

  @override
  List<Object?> get props => [];
}

class MeetingInitial extends MeetingState {}

class MeetingLoading extends MeetingState {}

class MeetingSuccess extends MeetingState {
  const MeetingSuccess([this.meeting=const []]);

  final List<MeetingModel> meeting;

  @override
  List<Object> get props => [meeting];
}

class MeetingError extends MeetingState {
  final String errorMessage;
  const MeetingError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class MeetingPaginated extends MeetingState {
  final List<MeetingModel> meeting;
  final bool hasReachedMax;

  const MeetingPaginated({
    required this.meeting,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [meeting, hasReachedMax];
}
class MeetingCreateError extends MeetingState {
  final String errorMessage;

  const MeetingCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class MeetingEditError extends MeetingState {
  final String errorMessage;

  const MeetingEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class MeetingDeleteError extends MeetingState {
  final String errorMessage;

  const MeetingDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class MeetingEditSuccessLoading extends MeetingState {}
class MeetingCreateSuccessLoading extends MeetingState {}
class MeetingEditSuccess extends MeetingState {
  const MeetingEditSuccess();
  @override
  List<Object> get props => [];
}
class MeetingCreateSuccess extends MeetingState {
  const MeetingCreateSuccess();
  @override
  List<Object> get props => [];
}
class MeetingDeleteSuccess extends MeetingState {
  const MeetingDeleteSuccess();
  @override
  List<Object> get props => [];
}