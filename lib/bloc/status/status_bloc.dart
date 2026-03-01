import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/status/status_event.dart';
import 'package:taskify/bloc/status/status_state.dart';
import 'package:taskify/data/model/status_model.dart';

import '../../data/repositories/Status/status_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class StatusBloc extends Bloc<StatusEvent, StatusState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  StatusBloc() : super(StatusInitial()) {
    on<StatusList>(_getStatusList);
    on<SelectedStatus>(_onSelectStatus);
    on<StatusLoadMore>(_onLoadMoreStatuses);
    on<SearchStatus>(_onSearchStatus);
    on<CreateStatus>(_onCreateStatus);
    on<UpdateStatus>(_onUpdateStatus);
    on<DeleteStatus>(_onDeleteStatus);
  }
  void _onDeleteStatus(DeleteStatus event, Emitter<StatusState> emit) async {
    // if (emit is NotesSuccess) {
    emit(StatusEditLoading());
    final status = event.statusId;

    try {
      Map<String, dynamic> result = await StatusRepo().deleteStatus(
        id: status,
        token: true,
      );
      if (result['data']['error'] == false) {

        emit(StatusDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((StatusDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(StatusError(e.toString()));
    }
    // }
  }
  void _onUpdateStatus(UpdateStatus event, Emitter<StatusState> emit) async {
    if (state is StatusSuccess) {
      List<Statuses> status = [];
      final id = event.id;
      final title = event.title;
      final color = event.color;


      emit(StatusEditLoading());
      // Try to update the task via the repository
      try {
        Map<String, dynamic> updatedProject = await StatusRepo().updateStatus(
            id: id,
            title: title,
          color: color,
          roleId:event.roleId!
       );
        // project = List<ProjectModel>.from(updatedProject['data']
        //     .map((projectData) => ProjectModel.fromJson(projectData)));
        if (updatedProject['error'] == false) {
          emit(StatusEditSuccess(status));
          // add(ProjectDashBoardList());
          // add(ProjectList());
        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);
          // add(ProjectDashBoardList());
          emit(StatusEditError(updatedProject['message']));
        }

      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }
  Future<void> _onCreateStatus(
      CreateStatus event, Emitter<StatusState> emit) async {
    try {


      emit(StatusCreateLoading());
      var result = await StatusRepo().createStatus(
          title: event.title,
          color: event.color,
        roleId: event.roleId
      );
      if (result['error'] == false) {
        emit(StatusCreateSuccess());
        // add(ProjectDashBoardList());
      }
      if (result['error'] == true) {
        emit(StatusCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
        // add(ProjectDashBoardList());
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((StatusError("Error: $e")));
    }
  }
  Future<void> _onSearchStatus(
      SearchStatus event, Emitter<StatusState> emit) async {
    try {
      List<Statuses> statuses = [];
      // emit(UserLoading());
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await StatusRepo().getStatuses(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
         );
      statuses = List<Statuses>.from(
          result['data'].map((projectData) => Statuses.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =statuses.length >= result['total'];
      if (result['error'] == false) {
        emit(StatusSuccess(statuses, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit((StatusError(result['message'])));
      }
    } on ApiException catch (e) {
      emit(StatusError("Error: $e"));
    }
  }
  Future<void> _getStatusList(
      StatusList event, Emitter<StatusState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<Statuses> statuses = [];

      Map<String, dynamic> result = await StatusRepo().getStatuses(
        offset: _offset,
        limit: _limit,
      );

      statuses = List<Statuses>.from(
          result['data'].map((projectData) => Statuses.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = statuses.length >= result['total'];

      if (result['error'] == false) {
        emit(StatusSuccess(statuses, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(StatusError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(StatusError("Error: $e"));
    }
  }


  Future<void> _onLoadMoreStatuses(
      StatusLoadMore event, Emitter<StatusState> emit) async {
    if (state is StatusSuccess && !_isFetching) {
      final currentState = state as StatusSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;

      try {
        // Fetch more statuses from the repository
        Map<String, dynamic> result = await StatusRepo().getStatuses(
            limit: _limit, offset: _offset, search: event.searchQuery);

        // Convert the fetched data into a list of Statuses
        List<Statuses> moreStatuses = List<Statuses>.from(
            result['data'].map((projectData) => Statuses.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreStatuses.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of statuses
        bool hasReachedMax = (currentState.status.length + moreStatuses.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of statuses
          emit(StatusSuccess(
            [...currentState.status, ...moreStatuses],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(StatusError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(StatusError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(StatusError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectStatus(SelectedStatus event, Emitter<StatusState> emit) {
    if (state is StatusSuccess) {
      final currentState = state as StatusSuccess;
      emit(StatusSuccess(currentState.status, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
