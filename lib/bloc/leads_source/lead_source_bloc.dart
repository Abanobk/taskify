import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/model/leads/lead_Source.dart';

import '../../api_helper/api.dart';
import '../../data/repositories/lead/lead_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'lead_source_event.dart';
import 'lead_source_state.dart';

class LeadSourceBloc extends Bloc<LeadSourceEvent, LeadSourceState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  LeadSourceBloc() : super(LeadSourceInitial()) {
    on<LeadSourceLists>(_getLeadSourceList);
    on<SelectedLeadSource>(_onSelectLeadSource);
    on<LeadSourceLoadMore>(_onLoadMoreLeadSourcees);
    on<SearchLeadSource>(_onSearchLeadSource);
    on<CreateLeadSource>(_onCreateLeadSource);
    on<UpdateLeadSource>(_onUpdateLeadSource);
    on<DeleteLeadSource>(_onDeleteLeadSource);
  }
  void _onDeleteLeadSource(DeleteLeadSource event, Emitter<LeadSourceState> emit) async {
    // if (emit is NotesSuccess) {
    final LeadSource = event.LeadSourceId;

    try {
      Map<String, dynamic> result = await LeadsSourceRepo().deleteLeadsSource(
        id: LeadSource,
        token: true,
      );
      print("fvgbhnj ${result['error']}");
      if (result['error'] == false) {

        emit(LeadSourceDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((LeadSourceDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(LeadSourceError(e.toString()));
    }
    // }
  }
  void _onUpdateLeadSource(UpdateLeadSource event, Emitter<LeadSourceState> emit) async {
    if (state is LeadSourceSuccess) {
      final id = event.id;
      final title = event.title;


      emit(LeadSourceEditLoading());

      try {
        Map<String, dynamic> updatedProject = await LeadsSourceRepo().updateLeadsSource(
            id: id,
            name: title,


        );
        if (updatedProject['error'] == false) {
          emit(LeadSourceEditSuccess());

        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);

          emit(LeadSourceEditError(updatedProject['message']));
        }

      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }
  Future<void> _onCreateLeadSource(
      CreateLeadSource event, Emitter<LeadSourceState> emit) async {
    try {

      emit(LeadSourceCreateLoading());
      var result = await LeadsSourceRepo().createLeadsSource(
        name: event.title,
      );
      if (result['error'] == false) {
        emit(LeadSourceCreateSuccess());
      }
      if (result['error'] == true) {
        emit(LeadSourceCreateError(result['message']));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((LeadSourceError("Error: $e")));
    }
  }
  Future<void> _onSearchLeadSource(
      SearchLeadSource event, Emitter<LeadSourceState> emit) async {
    try {
      List<LeadSourceModel> LeadSources = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await  LeadsSourceRepo().getLeadsSourceList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          );
      LeadSources = List<LeadSourceModel>.from(
          result['data'].map((projectData) => LeadSourceModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =LeadSources.length >= result['total'];
      if (result['error'] == false) {
        emit(LeadSourceSuccess(LeadSources, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(LeadSourceError(result['message']));
      }
    } on ApiException catch (e) {
      emit(LeadSourceError("Error: $e"));
    }
  }
  Future<void> _getLeadSourceList(
      LeadSourceLists event, Emitter<LeadSourceState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<LeadSourceModel> priorities = [];
      emit(LeadSourceLoading());
      Map<String, dynamic> result = await LeadsSourceRepo().getLeadsSourceList(
        offset: _offset,
        limit: _limit,
      );

      priorities = List<LeadSourceModel>.from(
          result['data'].map((projectData) => LeadSourceModel.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];

      if (result['error'] == false) {
        emit(LeadSourceSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(LeadSourceError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(LeadSourceError("Error: $e"));
    }
  }


  Future<void> _onLoadMoreLeadSourcees(
      LeadSourceLoadMore event, Emitter<LeadSourceState> emit) async {
    if (state is LeadSourceSuccess && !_isFetching) {
      final currentState = state as LeadSourceSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;


      try {
        // Fetch more LeadSourcees from the repository
        Map<String, dynamic> result = await LeadsSourceRepo().getLeadsSourceList(
            limit: _limit, offset: _offset, search: event.searchQuery,);

        // Convert the fetched data into a list of LeadSourcees
        List<LeadSourceModel> moreLeadSourcees = List<LeadSourceModel>.from(
            result['data'].map((projectData) => LeadSourceModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreLeadSourcees.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of LeadSourcees
        bool hasReachedMax = (currentState.LeadSource.length + moreLeadSourcees.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of LeadSourcees
          emit(LeadSourceSuccess(
            [...currentState.LeadSource, ...moreLeadSourcees],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(LeadSourceError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(LeadSourceError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(LeadSourceError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectLeadSource(SelectedLeadSource event, Emitter<LeadSourceState> emit) {
    if (state is LeadSourceSuccess) {
      final currentState = state as LeadSourceSuccess;
      emit(LeadSourceSuccess(currentState.LeadSource, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
