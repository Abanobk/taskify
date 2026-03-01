import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/model/leads/lead_stage.dart';
import 'package:taskify/data/repositories/lead/lead_repo.dart';

import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'lead_stage_event.dart';
import 'lead_stage_state.dart';

class LeadStageBloc extends Bloc<LeadStageEvent, LeadStageState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  LeadStageBloc() : super(LeadStageInitial()) {
    on<LeadStageLists>(_getLeadStageList);
    on<SelectedLeadStage>(_onSelectLeadStage);
    on<LeadStageLoadMore>(_onLoadMoreLeadStagees);
    on<SearchLeadStage>(_onSearchLeadStage);
    on<CreateLeadStage>(_onCreateLeadStage);
    on<UpdateLeadStage>(_onUpdateLeadStage);
    on<DeleteLeadStage>(_onDeleteLeadStage);
  }
  void _onDeleteLeadStage(DeleteLeadStage event, Emitter<LeadStageState> emit) async {
    // if (emit is NotesSuccess) {
    final LeadStage = event.LeadStageId;

    try {
      Map<String, dynamic> result = await LeadsStageRepo().deleteLeadsStage(
        id: LeadStage,
        token: true,
      );
      if (result['error'] == false) {

        emit(LeadStageDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((LeadStageDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(LeadStageError(e.toString()));
    }
    // }
  }
  void _onUpdateLeadStage(UpdateLeadStage event, Emitter<LeadStageState> emit) async {
    if (state is LeadStageSuccess) {
      final id = event.id;
      final title = event.title;
      final color = event.color;


      emit(LeadStageEditLoading());

      try {
        Map<String, dynamic> updatedProject = await LeadsStageRepo().updateLeadsStage(
            id: id,
            name: title,
            color: color,

        );
        if (updatedProject['error'] == false) {
          emit(LeadStageEditSuccess());

        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);

          emit(LeadStageEditError(updatedProject['message']));
        }

      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }
  Future<void> _onCreateLeadStage(
      CreateLeadStage event, Emitter<LeadStageState> emit) async {
    try {

      emit(LeadStageCreateLoading());
      var result = await LeadsStageRepo().createLeadsStage(
        name: event.title,
        color: event.color,
      );
      if (result['error'] == false) {
        emit(LeadStageCreateSuccess());
      }
      if (result['error'] == true) {
        emit(LeadStageCreateError(result['message']));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((LeadStageError("Error: $e")));
    }
  }
  Future<void> _onSearchLeadStage(
      SearchLeadStage event, Emitter<LeadStageState> emit) async {
    try {
      List<LeadStageModel> LeadStages = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await  LeadsStageRepo().getLeadsStageList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          );
      LeadStages = List<LeadStageModel>.from(
          result['data'].map((projectData) => LeadStageModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =LeadStages.length >= result['total'];
      if (result['error'] == false) {
        emit(LeadStageSuccess(LeadStages, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(LeadStageError(result['message']));
      }
    } on ApiException catch (e) {
      emit(LeadStageError("Error: $e"));
    }
  }
  Future<void> _getLeadStageList(
      LeadStageLists event, Emitter<LeadStageState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<LeadStageModel> priorities = [];
      emit(LeadStageLoading());
      Map<String, dynamic> result = await LeadsStageRepo().getLeadsStageList(
        offset: _offset,
        limit: _limit,
      );

      priorities = List<LeadStageModel>.from(
          result['data'].map((projectData) => LeadStageModel.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];

      if (result['error'] == false) {
        emit(LeadStageSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(LeadStageError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(LeadStageError("Error: $e"));
    }
  }


  Future<void> _onLoadMoreLeadStagees(
      LeadStageLoadMore event, Emitter<LeadStageState> emit) async {
    if (state is LeadStageSuccess && !_isFetching) {
      final currentState = state as LeadStageSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;


      try {
        // Fetch more LeadStagees from the repository
        Map<String, dynamic> result = await LeadsStageRepo().getLeadsStageList(
            limit: _limit, offset: _offset, search: event.searchQuery,);

        // Convert the fetched data into a list of LeadStagees
        List<LeadStageModel> moreLeadStagees = List<LeadStageModel>.from(
            result['data'].map((projectData) => LeadStageModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreLeadStagees.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of LeadStagees
        bool hasReachedMax = (currentState.LeadStage.length + moreLeadStagees.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of LeadStagees
          emit(LeadStageSuccess(
            [...currentState.LeadStage, ...moreLeadStagees],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(LeadStageError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(LeadStageError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(LeadStageError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectLeadStage(SelectedLeadStage event, Emitter<LeadStageState> emit) {
    if (state is LeadStageSuccess) {
      final currentState = state as LeadStageSuccess;
      emit(LeadStageSuccess(currentState.LeadStage, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
