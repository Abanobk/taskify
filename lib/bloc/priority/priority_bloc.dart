import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/priority/priority_event.dart';
import 'package:taskify/bloc/priority/priority_state.dart';
import 'package:taskify/data/model/priority_model.dart';
import '../../data/repositories/priority/priority_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class PriorityBloc extends Bloc<PriorityEvent, PriorityState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  PriorityBloc() : super(PriorityInitial()) {
    on<PriorityLists>(_getPriorityList);
    on<SelectedPriority>(_onSelectPriority);
    on<PriorityLoadMore>(_onLoadMorePriorityes);
    on<SearchPriority>(_onSearchPriority);
    on<CreatePriority>(_onCreatePriority);
    on<UpdatePriority>(_onUpdatePriority);
    on<DeletePriority>(_onDeletePriority);
  }
  void _onDeletePriority(DeletePriority event, Emitter<PriorityState> emit) async {
    // if (emit is NotesSuccess) {
    final Priority = event.PriorityId;

    try {
      Map<String, dynamic> result = await PriorityRepo().deletePriority(
        id: Priority,
        token: true,
      );
      if (result['data']['error'] == false) {

        emit(PriorityDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((PriorityDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(PriorityError(e.toString()));
    }
    // }
  }
  void _onUpdatePriority(UpdatePriority event, Emitter<PriorityState> emit) async {
    if (state is PrioritySuccess) {
      final id = event.id;
      final title = event.title;
      final color = event.color;


      emit(PriorityEditLoading());

      try {
        Map<String, dynamic> updatedProject = await PriorityRepo().updatePriority(
            id: id,
            title: title,
            color: color,

        );
        if (updatedProject['error'] == false) {
          emit(PriorityEditSuccess());

        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);

          emit(PriorityEditError(updatedProject['message']));
        }

      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }
  Future<void> _onCreatePriority(
      CreatePriority event, Emitter<PriorityState> emit) async {
    try {

      emit(PriorityCreateLoading());
      var result = await PriorityRepo().createPriority(
        title: event.title,
        color: event.color,
      );
      if (result['error'] == false) {
        emit(PriorityCreateSuccess());
      }
      if (result['error'] == true) {
        emit(PriorityCreateError(result['message']));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PriorityError("Error: $e")));
    }
  }
  Future<void> _onSearchPriority(
      SearchPriority event, Emitter<PriorityState> emit) async {
    try {
      List<Priorities> Priorityes = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await  PriorityRepo().getPriorities(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          token: true);
      Priorityes = List<Priorities>.from(
          result['data'].map((projectData) => Priorities.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =Priorityes.length >= result['total'];
      if (result['error'] == false) {
        emit(PrioritySuccess(Priorityes, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(PriorityError(result['message']));
      }
    } on ApiException catch (e) {
      emit(PriorityError("Error: $e"));
    }
  }
  Future<void> _getPriorityList(
      PriorityLists event, Emitter<PriorityState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<Priorities> priorities = [];

      Map<String, dynamic> result = await PriorityRepo().getPriorities(
        token: true,
        offset: _offset,
        limit: _limit,
      );

      priorities = List<Priorities>.from(
          result['data'].map((projectData) => Priorities.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];

      if (result['error'] == false) {
        emit(PrioritySuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(PriorityError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(PriorityError("Error: $e"));
    }
  }


  Future<void> _onLoadMorePriorityes(
      PriorityLoadMore event, Emitter<PriorityState> emit) async {
    if (state is PrioritySuccess && !_isFetching) {
      final currentState = state as PrioritySuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;


      try {
        // Fetch more Priorityes from the repository
        Map<String, dynamic> result = await PriorityRepo().getPriorities(
            limit: _limit, offset: _offset, search: event.searchQuery, token: true);

        // Convert the fetched data into a list of Priorityes
        List<Priorities> morePriorityes = List<Priorities>.from(
            result['data'].map((projectData) => Priorities.fromJson(projectData)));

        // Only update the offset if new data is received
        if (morePriorityes.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of Priorityes
        bool hasReachedMax = (currentState.priority.length + morePriorityes.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of Priorityes
          emit(PrioritySuccess(
            [...currentState.priority, ...morePriorityes],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(PriorityError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(PriorityError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(PriorityError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectPriority(SelectedPriority event, Emitter<PriorityState> emit) {
    if (state is PrioritySuccess) {
      final currentState = state as PrioritySuccess;
      emit(PrioritySuccess(currentState.priority, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
