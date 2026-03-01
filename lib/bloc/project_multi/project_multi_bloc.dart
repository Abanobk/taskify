import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/project_multi/project_multi_event.dart';
import 'package:taskify/bloc/project_multi/project_multi_state.dart';
import '../../data/model/Project/all_project.dart';
import '../../data/repositories/Project/project_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class ProjectMultiBloc extends Bloc<ProjectMultiEvent, ProjectMultiState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 16;
  bool _hasReachedMax = false;
  ProjectMultiBloc() : super(ProjectMultiInitial()) {
    on<ProjectMultiList>(_getProjectMultiList);
    on<SelectedProjectMulti>(_onSelectProjectMulti);
    on<ProjectMultiLoadMore>(_onLoadMore);
    on<ToggleProjectMultiSelection>(_onToggleProjectMultiSelection);
    on<SearchProjectMultis>(_onSearchProjectMulti);
  }
  Future<void> _getProjectMultiList(ProjectMultiList event, Emitter<ProjectMultiState> emit) async {
    try {
      List<ProjectModel> projectMultis =[];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ProjectMultiLoading());
      Map<String,dynamic> result = await ProjectRepo().getProjects(limit: _limit, offset: _offset,);
      projectMultis = List<ProjectModel>.from(result['data']
          .map((projectData) => ProjectModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = projectMultis.length >= result['total'];

      emit(ProjectMultiPaginated(projectMulti: projectMultis, hasReachedMax: _hasReachedMax));

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectMultiError("Error: $e")));
    }
  }
  Future<void> _onSearchProjectMulti(
      SearchProjectMultis event, Emitter<ProjectMultiState> emit) async {
    try {
      List<ProjectModel> projectMulti=[];
      // emit(ProjectMultiLoading());
      print("SEARCH ${event.searchQuery}");
      Map<String,dynamic> result  = await ProjectRepo().getProjects(limit: _limit, offset: 0, search: event.searchQuery,);
      projectMulti = List<ProjectModel>.from(result['data']
          .map((projectData) => ProjectModel.fromJson(projectData)));

      bool hasReachedMax = projectMulti.length >= result['total'];
      if (result['error'] == false) {
        emit(ProjectMultiPaginated(projectMulti:projectMulti,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ProjectMultiError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      flutterToastCustom(msg:"$e");

      emit(ProjectMultiError("Error: $e"));

    }
  }
  Future<void> _onLoadMore(
      ProjectMultiLoadMore event, Emitter<ProjectMultiState> emit) async {
    if (state is ProjectMultiPaginated && !_hasReachedMax) {
      print("ertfghj $_hasReachedMax");
      try {
        final currentState = state as ProjectMultiPaginated;
        final updatedNotification = List<ProjectModel>.from(currentState.projectMulti);

        // Fetch additional Notifications from the repository
        List<ProjectModel> additionalNotes = [];
        Map<String,dynamic> result = await ProjectRepo().getProjects(limit: _limit, offset: _offset,);
        additionalNotes = List<ProjectModel>.from(result['data']
            .map((projectData) => ProjectModel.fromJson(projectData)));
        // Update the offset for the next load
        _offset= updatedNotification.length;

        // Check if the D number of items has been reached
        print("loading more ${currentState.projectMulti.length} and > = ${result['total']}");
        if (currentState.projectMulti.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Notifications to the existing list
        updatedNotification.addAll(additionalNotes);
        if (result['error'] == false) {
          emit(ProjectMultiPaginated(projectMulti: updatedNotification, hasReachedMax: _hasReachedMax, ));
        }
        if (result['error'] == true) {
          emit((ProjectMultiError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }
        // Emit the new state with the updated Notification list and hasReachedMax flag

      } on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(ProjectMultiError("Error: $e"));
      }
    }

  }

  void _onSelectProjectMulti(SelectedProjectMulti event, Emitter<ProjectMultiState> emit) {
    if (state is ProjectMultiSuccess) {
      final currentState = state as ProjectMultiSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedProjectMultinames =
      List<String>.from(currentState.selectedProjectMultinames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedProjectMultinames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedProjectMultinames.add(event.selectedTitle);
      }

      emit(ProjectMultiSuccess(
        projectMulti: currentState.projectMulti,
        selectedIndices: selectedIndices,
        selectedProjectMultinames: selectedProjectMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _onToggleProjectMultiSelection(ToggleProjectMultiSelection event, Emitter<ProjectMultiState> emit) {
    if (state is ProjectMultiSuccess) {
      final currentState = state as ProjectMultiSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedProjectMultiIds = List<int>.from(currentState.selectedIndices);
      final updatedSelectedProjectMultinames = List<String>.from(currentState.selectedProjectMultinames);

      // Check if the ProjectMulti is already selected based on ProjectMultiId
      final isSelected = updatedSelectedProjectMultiIds.contains(event.projectMultiId);

      if (isSelected) {
        // Find the index of the ProjectMultiId in the selectedIndices list
        final removeIndex = updatedSelectedProjectMultiIds.indexOf(event.projectMultiId);

        // Remove ProjectMultiId and corresponding ProjectMultiname
        updatedSelectedProjectMultiIds.removeAt(removeIndex);
        updatedSelectedProjectMultinames.removeAt(removeIndex);
      } else {
        // Add ProjectMultiId and corresponding ProjectMultiname
        updatedSelectedProjectMultiIds.add(event.projectMultiId);
        updatedSelectedProjectMultinames.add(event.projectMultiName);
      }

      // Emit the updated state
      emit(ProjectMultiSuccess(
        projectMulti: currentState.projectMulti,
        selectedIndices: updatedSelectedProjectMultiIds,
        selectedProjectMultinames: updatedSelectedProjectMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

}
