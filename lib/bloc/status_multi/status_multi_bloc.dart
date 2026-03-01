import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/status_multi/status_multi_event.dart';
import 'package:taskify/bloc/status_multi/status_multi_state.dart';
import 'package:taskify/data/model/status_model.dart';
import '../../data/repositories/Status/status_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class StatusMultiBloc extends Bloc<StatusMultiEvent, StatusMultiState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 16;
  bool _hasReachedMax = false;
  StatusMultiBloc() : super(StatusMultiInitial()) {
    on<StatusMultiList>(_getStatusMultiList);
    on<SelectedStatusMulti>(_onSelectStatusMulti);
    on<StatusMultiLoadMore>(_onLoadMore);
    on<ToggleStatusMultiSelection>(_onToggleStatusMultiSelection);

    on<SearchStatusMultis>(_onSearchStatusMulti);
  }
  Future<void> _getStatusMultiList(StatusMultiList event, Emitter<StatusMultiState> emit) async {
    try {
      List<Statuses> statusMultis =[];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      // emit(StatusMultiLoading());
      Map<String,dynamic> result = await StatusRepo().getStatuses(limit: _limit, offset: _offset,);
      statusMultis = List<Statuses>.from(result['data']
          .map((projectData) => Statuses.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = statusMultis.length >= result['total'];
      emit(StatusMultiPaginated(statusMulti: statusMultis, hasReachedMax: _hasReachedMax));

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((StatusMultiError("Error: $e")));
    }
  }
  Future<void> _onSearchStatusMulti(
      SearchStatusMultis event, Emitter<StatusMultiState> emit) async {
    try {
      List<Statuses> statusMulti=[];

      Map<String,dynamic> result  = await StatusRepo().getStatuses(limit: _limit, offset: 0, search: event.searchQuery,);
      statusMulti = List<Statuses>.from(result['data']
          .map((projectData) => Statuses.fromJson(projectData)));

      bool hasReachedMax = statusMulti.length >= result['total'];
      if (result['error'] == false) {
        emit(StatusMultiPaginated(statusMulti:statusMulti,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((StatusMultiError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      flutterToastCustom(msg:"$e");

      emit(StatusMultiError("Error: $e"));

    }
  }
  Future<void> _onLoadMore(
      StatusMultiLoadMore event, Emitter<StatusMultiState> emit) async {
    if (state is StatusMultiPaginated && !_hasReachedMax) {
      try {
        final currentState = state as StatusMultiPaginated;
        final updatedNotification = List<Statuses>.from(currentState.statusMulti);

        // Fetch additional Notifications from the repository
        List<Statuses> additionalNotes = [];
        Map<String,dynamic> result = await StatusRepo().getStatuses(limit: _limit, offset: _offset,);
        additionalNotes = List<Statuses>.from(result['data']
            .map((projectData) => Statuses.fromJson(projectData)));
        // Update the offset for the next load
        _offset= updatedNotification.length;

        // Check if the D number of items has been reached
        if (currentState.statusMulti.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }
        // Add the newly fetched Notifications to the existing list
        updatedNotification.addAll(additionalNotes);
        if (result['error'] == false) {
          emit(StatusMultiPaginated(statusMulti: updatedNotification, hasReachedMax: _hasReachedMax, ));
        }
        if (result['error'] == true) {
          emit((StatusMultiError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }
        // Emit the new state with the updated Notification list and hasReachedMax flag

      } on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(StatusMultiError("Error: $e"));
      }
    }

  }

  void _onSelectStatusMulti(SelectedStatusMulti event, Emitter<StatusMultiState> emit) {
    if (state is StatusMultiSuccess) {
      final currentState = state as StatusMultiSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedStatusMultinames =
      List<String>.from(currentState.selectedStatusMultinames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedStatusMultinames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedStatusMultinames.add(event.selectedTitle);
      }
      emit(StatusMultiSuccess(
        statusMulti: currentState.statusMulti,
        selectedIndices: selectedIndices,
        selectedStatusMultinames: selectedStatusMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _onToggleStatusMultiSelection(ToggleStatusMultiSelection event, Emitter<StatusMultiState> emit) {
    if (state is StatusMultiSuccess) {
      final currentState = state as StatusMultiSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedStatusMultiIds = List<int>.from(currentState.selectedIndices);
      final updatedSelectedStatusMultinames = List<String>.from(currentState.selectedStatusMultinames);

      // Check if the StatusMulti is already selected based on StatusMultiId
      final isSelected = updatedSelectedStatusMultiIds.contains(event.statusMultiId);

      if (isSelected) {
        // Find the index of the StatusMultiId in the selectedIndices list
        final removeIndex = updatedSelectedStatusMultiIds.indexOf(event.statusMultiId);

        // Remove StatusMultiId and corresponding StatusMultiname
        updatedSelectedStatusMultiIds.removeAt(removeIndex);
        updatedSelectedStatusMultinames.removeAt(removeIndex);
      } else {
        // Add StatusMultiId and corresponding StatusMultiname
        updatedSelectedStatusMultiIds.add(event.statusMultiId);
        updatedSelectedStatusMultinames.add(event.statusMultiName);
      }

      // Emit the updated state
      emit(StatusMultiSuccess(
        statusMulti: currentState.statusMulti,
        selectedIndices: updatedSelectedStatusMultiIds,
        selectedStatusMultinames: updatedSelectedStatusMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }


}
