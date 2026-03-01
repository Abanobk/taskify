import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/model/notes/notes_model.dart';
import '../../data/repositories/notes/notes_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 6;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingNote = "";

  NotesBloc() : super(NotesInitial()) {
    on<CreateNotes>(_onNotesCreate);
    on<NotesList>(_getListOfNotes);
    on<AddNotes>(_onAddNote);
    on<UpdateNotes>(_onUpdateNote);
    on<DeleteNotes>(_onDeleteNote);
    on<SearchNotes>(_onSearchNotes);
    on<LoadMoreNotes>(_onLoadMoreNotes);
    on<DrawingNote>(_onDrawingNote);
  }
  void _onDrawingNote(DrawingNote event, Emitter<NotesState> emit) {
    drawingNote = event.drawing;
    emit(DrawingNoteUpdated( drawingNote));
  }

  Future<void> _onNotesCreate(CreateNotes event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());

      Map<String,dynamic> result = await NotesRepo().createNote(
          token: true,
          title: event.title,
          desc: event.desc,
          noteType: event.noteType,
          drawingData: drawingNote,
          createdAt: event.createdAt);

      if (result['error'] == false) {
        emit(const NotesCreateSuccess());
        add(const NotesList());
      }
      if (result['error'] == true) {
        emit((NotesCreateError(result['message'])));
        add(const NotesList());
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(NotesError("Error: $e"));
    }
  }


  Future<void> _getListOfNotes(NotesList event, Emitter<NotesState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(NotesLoading());
      List<NotesModel> notes =[];
      Map<String,dynamic> result
      = await NotesRepo().noteList(limit: _limit, offset: _offset, search: '');
      notes = List<NotesModel>.from(result['data'].map((projectData) => NotesModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = notes.length < _limit;

      if (result['error'] == false) {
        emit(NotesPaginated(notes: notes, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((NotesError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(NotesError("Error: $e"));
    }
  }
  Future<void> _onAddNote(AddNotes event, Emitter<NotesState> emit) async {
    if (state is NotesPaginated) {
      final note = event.notes;
      final title = note.title;
      final desc = note.description;
      final createdAt = note.createdAt;
      final noteType = note.type;
      //
      try {
         emit(NotesCreateSuccessLoading());

        Map<String,dynamic> result
    = await NotesRepo().createNote(
          title: title!,
          desc: desc!,
          createdAt: createdAt!,
      noteType: noteType!,
      drawingData: drawingNote,

          token: true,
        );


        if (result['error'] == false) {

          emit(const NotesCreateSuccess());
          add(const NotesList());}
        if (result['error'] == true) {
          emit((NotesCreateError(result['message'])));
          add(const NotesList());
          flutterToastCustom(msg: result['message']);
        }


      } catch (e) {
        print('Error while creating note: $e');
        // Optionally, handle the error state
      }
    }
  }
  void _onUpdateNote(UpdateNotes event, Emitter<NotesState> emit) async {
    if (state is NotesPaginated) {
      final note = event.notes;
      final id = note.id;
      final title = note.title;
      final desc = note.description;
      final noteType = note.type;

      // Update the note in the list
      try {


        emit(NotesEditSuccessLoading());
        Map<String,dynamic> result = await NotesRepo().updateNote(
          id: id!,
          title: title!,
          noteType: noteType!,
          drawingData: drawingNote,
          desc: desc!,
          token: true,
        ) ; // Cast to NotesModel

        // Replace the note in the list with the updated one
        if (result['error'] == false) {
          emit(const NotesEditSuccess());
          add(const NotesList());


        }
        if (result['error'] == true) {
          emit((NotesEditError(result['message'])));
          add(const NotesList());
          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((NotesEditError("$e")));

        print('Error while updating note: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteNote(DeleteNotes event, Emitter<NotesState> emit) async {
    // if (emit is NotesSuccess) {
    final note = event.notes;
    try {
      Map<String,dynamic> result
    =  await NotesRepo().deleteNote(
        id: note,
        token: true,
      );
      if(result['error']== false) {
        emit(const NotesDeleteSuccess());
        add(const NotesList());
      }
      if(result['error'] == true){
        emit(NotesDeleteError(result['message']));
        add(const NotesList());
      }
    } catch (e) {
      emit(NotesDeleteError(e.toString()));
      add(const NotesList());
    }
    // }
  }

  Future<void> _onSearchNotes(
      SearchNotes event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      List<NotesModel> notes =[];
      Map<String,dynamic> result = await NotesRepo()
          .noteList(limit: _limit, offset: 0, search: event.searchQuery);
      notes = List<NotesModel>.from(result['data']
          .map((projectData) => NotesModel.fromJson(projectData)));
      bool hasReachedMax = notes.length < _limit;
      if (result['error'] == false) {
        emit(NotesPaginated(notes:notes,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((NotesError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(NotesError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreNotes(
      LoadMoreNotes event, Emitter<NotesState> emit) async {
    if (state is NotesPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as NotesPaginated;
        final updatedNotes = List<NotesModel>.from(currentState.notes);

        List<NotesModel> additionalNotes = [];
        Map<String, dynamic> result = await NotesRepo().noteList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalNotes = List<NotesModel>.from(
            result['data'].map((projectData) => NotesModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of notes has been reached
        if (updatedNotes.length + additionalNotes.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched notes to the updated list
        updatedNotes.addAll(additionalNotes);

        if (result['error'] == false) {
          emit(NotesPaginated(notes: updatedNotes, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(NotesError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(NotesError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
