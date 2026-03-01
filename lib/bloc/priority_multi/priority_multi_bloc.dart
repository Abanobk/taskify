import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/priority_multi/priority_multi_event.dart';
import 'package:taskify/bloc/priority_multi/priority_multi_state.dart';

import '../../data/model/priority_model.dart';
import '../../data/repositories/Priority/priority_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class PriorityMultiBloc extends Bloc<PriorityMultiEvent, PriorityMultiState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 16;
  bool _hasReachedMax = false;
  PriorityMultiBloc() : super(PriorityMultiInitial()) {
    on<PriorityMultiList>(_getPriorityMultiList);
    on<SelectedPriorityMulti>(_onSelectPriorityMulti);
    on<PriorityMultiLoadMore>(_onLoadMore);
    on<TogglePriorityMultiSelection>(_onTogglePriorityMultiSelection);
    on<SearchPriorityMultis>(_onSearchPriorityMulti);
  }
  Future<void> _getPriorityMultiList(PriorityMultiList event, Emitter<PriorityMultiState> emit) async {
    try {
      List<Priorities> priorityMultis =[];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      // emit(PriorityMultiLoading());
      Map<String,dynamic> result = await PriorityRepo().getPriorities(token: true,limit: _limit, offset: _offset,);
      priorityMultis = List<Priorities>.from(result['data']
          .map((projectData) => Priorities.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = priorityMultis.length >= result['total'];
      print("ertyuiolp ${result['total']}");
      emit(PriorityMultiPaginated(priorityMulti: priorityMultis, hasReachedMax: _hasReachedMax));

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PriorityMultiError("Error: $e")));
    }
  }
  Future<void> _onSearchPriorityMulti(
      SearchPriorityMultis event, Emitter<PriorityMultiState> emit) async {
    try {
      List<Priorities> priorityMulti=[];
      // emit(PriorityMultiLoading());
      print("SEARCH ${event.searchQuery}");
      Map<String,dynamic> result  = await PriorityRepo().getPriorities(limit: _limit, offset: 0, search: event.searchQuery,token: true);
      priorityMulti = List<Priorities>.from(result['data']
          .map((projectData) => Priorities.fromJson(projectData)));

      bool hasReachedMax = priorityMulti.length >= result['total'];
      if (result['error'] == false) {
        emit(PriorityMultiPaginated(priorityMulti:priorityMulti,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((PriorityMultiError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      flutterToastCustom(msg:"$e");

      emit(PriorityMultiError("Error: $e"));

    }
  }
  Future<void> _onLoadMore(
      PriorityMultiLoadMore event, Emitter<PriorityMultiState> emit) async {
    if (state is PriorityMultiPaginated && !_hasReachedMax) {
      print("ertfghj $_hasReachedMax");
      try {
        final currentState = state as PriorityMultiPaginated;
        final updatedNotification = List<Priorities>.from(currentState.priorityMulti);

        // Fetch additional Notifications from the repository
        List<Priorities> additionalNotes = [];
        Map<String,dynamic> result = await PriorityRepo().getPriorities(token: true,limit: _limit, offset: _offset,);
        additionalNotes = List<Priorities>.from(result['data']
            .map((projectData) => Priorities.fromJson(projectData)));
        // Update the offset for the next load
        _offset= updatedNotification.length;

        // Check if the D number of items has been reached
        print("loading more ${currentState.priorityMulti.length} and > = ${result['total']}");
        if (currentState.priorityMulti.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }
        print("rftyuhijkl $_hasReachedMax");
        // Add the newly fetched Notifications to the existing list
        updatedNotification.addAll(additionalNotes);
        if (result['error'] == false) {
          emit(PriorityMultiPaginated(priorityMulti: updatedNotification, hasReachedMax: _hasReachedMax, ));
        }
        if (result['error'] == true) {
          emit((PriorityMultiError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }
        // Emit the new state with the updated Notification list and hasReachedMax flag

      } on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(PriorityMultiError("Error: $e"));
      }
    }

  }

  void _onSelectPriorityMulti(SelectedPriorityMulti event, Emitter<PriorityMultiState> emit) {
    if (state is PriorityMultiSuccess) {
      final currentState = state as PriorityMultiSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedPriorityMultinames =
      List<String>.from(currentState.selectedPriorityMultinames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedPriorityMultinames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedPriorityMultinames.add(event.selectedTitle);
      }
      print("fghj ${selectedPriorityMultinames.toString()}");
      emit(PriorityMultiSuccess(
        priorityMulti: currentState.priorityMulti,
        selectedIndices: selectedIndices,
        selectedPriorityMultinames: selectedPriorityMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _onTogglePriorityMultiSelection(TogglePriorityMultiSelection event, Emitter<PriorityMultiState> emit) {
    if (state is PriorityMultiSuccess) {
      final currentState = state as PriorityMultiSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedPriorityMultiIds = List<int>.from(currentState.selectedIndices);
      final updatedSelectedPriorityMultinames = List<String>.from(currentState.selectedPriorityMultinames);

      // Check if the PriorityMulti is already selected based on PriorityMultiId
      final isSelected = updatedSelectedPriorityMultiIds.contains(event.priorityMultiId);

      if (isSelected) {
        // Find the index of the PriorityMultiId in the selectedIndices list
        final removeIndex = updatedSelectedPriorityMultiIds.indexOf(event.priorityMultiId);

        // Remove PriorityMultiId and corresponding PriorityMultiname
        updatedSelectedPriorityMultiIds.removeAt(removeIndex);
        updatedSelectedPriorityMultinames.removeAt(removeIndex);
      } else {
        // Add PriorityMultiId and corresponding PriorityMultiname
        updatedSelectedPriorityMultiIds.add(event.priorityMultiId);
        updatedSelectedPriorityMultinames.add(event.priorityMultiName);
      }

      // Emit the updated state
      emit(PriorityMultiSuccess(
        priorityMulti: currentState.priorityMulti,
        selectedIndices: updatedSelectedPriorityMultiIds,
        selectedPriorityMultinames: updatedSelectedPriorityMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
      print("updatedSelectedPriorityMultinames $updatedSelectedPriorityMultinames");
    }
  }

}
