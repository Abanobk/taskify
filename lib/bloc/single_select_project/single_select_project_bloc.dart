import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/single_select_project/single_select_project_event.dart';
import 'package:taskify/bloc/single_select_project/single_select_project_state.dart';
import 'package:taskify/data/model/Project/all_project.dart';
import '../../data/repositories/Project/project_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class SingleSelectProjectBloc extends Bloc<SingleSelectProjectEvent, SingleSelectProjectState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 13;
  bool _isFetching = false;

  bool _hasReachedMax = false;

    SingleSelectProjectBloc() : super(SingleProjectInitial()) {
    on<SingleProjectList>(_getSingleProjectList);
    on<SelectSingleProject>(_onSelectProject);
    on<SingleProjectLoadMore>(_onLoadMoreProject);
    on<SearchSingleProject>(_onSearchSingleProject);
  }

  Future<void> _onSearchSingleProject(
      SearchSingleProject event, Emitter<SingleSelectProjectState> emit) async {
    try {
      List<ProjectModel> project = [];
      // emit(UserLoading());
      _offset = 0;
      _hasReachedMax = false;
      print("SEARCH ${event.searchQuery}");
      Map<String, dynamic> result = await  ProjectRepo().getProjects(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
         );
      project = List<ProjectModel>.from(
          result['data'].map((projectData) => ProjectModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =project.length >= result['total'];
      if (result['error'] == false) {
        emit(SingleProjectSuccess(project, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(SingleProjectError(result['message']));
      }
    } on ApiException catch (e) {
      emit(SingleProjectError("Error: $e"));
    }
  }
  Future<void> _getSingleProjectList(
      SingleProjectList event, Emitter<SingleSelectProjectState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<ProjectModel> priorities = [];

      Map<String, dynamic> result = await ProjectRepo().getProjects(

        offset: _offset,
        limit: _limit,
      );

      priorities = List<ProjectModel>.from(result['data'].map((projectData) => ProjectModel.fromJson(projectData)));
print("gyhujiklo;p'${priorities.length}");
      // Increment offset by limit after each fetch
      _offset += _limit;
      print("rftguhyjmk,l; $_offset");

      _hasReachedMax = priorities.length >= result['total'];
      print("rftyghujklwsqwqw ,$_hasReachedMax");

      if (result['error'] == false) {
        emit(SingleProjectSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(SingleProjectError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(SingleProjectError("Error: $e"));
    }
  }


  Future<void> _onLoadMoreProject(
      SingleProjectLoadMore event, Emitter<SingleSelectProjectState> emit) async {
    if (state is SingleProjectSuccess && !_isFetching) {
      final currentState = state as SingleProjectSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;

      print("Loading more Priorityes with offset: $_offset");

      try {
        // Fetch more Priorityes from the repository
        Map<String, dynamic> result = await ProjectRepo().getProjects(
            limit: _limit, offset: _offset, search: event.searchQuery, );

        // Convert the fetched data into a list of Priorityes
        List<ProjectModel> morePriorityes = List<ProjectModel>.from(
            result['data'].map((projectData) => ProjectModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (morePriorityes.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
          print("Updated offset: $_offset");
        }

        // Check if we've reached the total number of Priorityes
        bool hasReachedMax = (currentState.project.length + morePriorityes.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of Priorityes
          emit(SingleProjectSuccess(
            [...currentState.project, ...morePriorityes],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(SingleProjectError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(SingleProjectError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(SingleProjectError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectProject(SelectSingleProject event, Emitter<SingleSelectProjectState> emit) {
    if (state is SingleProjectSuccess) {
      final currentState = state as SingleProjectSuccess;
      // Maintain the hasReachedMax value when selecting a project
      emit(SingleProjectSuccess(
        currentState.project,
        event.selectedIndex,
        event.selectedTitle,
        currentState.hasReachedMax, // Keep the existing hasReachedMax value
      ));
    }
  }
}

