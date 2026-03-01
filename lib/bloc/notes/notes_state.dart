import 'package:equatable/equatable.dart';

import '../../data/model/notes/notes_model.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesSuccess extends NotesState {
  const NotesSuccess([this.notes=const []]);

  final List<NotesModel> notes;

  @override
  List<Object> get props => [notes];
}

class NotesError extends NotesState {
  final String errorMessage;
  const NotesError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DrawingNoteUpdated extends NotesState {
  final String drawing;
  const DrawingNoteUpdated(this.drawing);

  @override
  List<Object> get props => [drawing];
}
class NotesPaginated extends NotesState {
  final List<NotesModel> notes;
  final bool hasReachedMax;

  const NotesPaginated({
    required this.notes,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [notes, hasReachedMax];
}
class NotesCreateError extends NotesState {
  final String errorMessage;

  const NotesCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class NotesEditError extends NotesState {
  final String errorMessage;

  const NotesEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class NotesEditSuccessLoading extends NotesState {}
class NotesCreateSuccessLoading extends NotesState {}
class NotesEditSuccess extends NotesState {
  const NotesEditSuccess();
  @override
  List<Object> get props => [];
}
class NotesCreateSuccess extends NotesState {
  const NotesCreateSuccess();
  @override
  List<Object> get props => [];
}
class NotesDeleteError extends NotesState {
  final String errorMessage;

  const NotesDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class NotesDeleteSuccess extends NotesState {
  const NotesDeleteSuccess();
  @override
  List<Object> get props => [];
}