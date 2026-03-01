import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/repositories/lead/lead_repo.dart';

import '../../api_helper/api.dart';
import '../../data/model/leads/leads_model.dart';
import '../../utils/widgets/toast_widget.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  LeadBloc() : super(LeadInitial()) {
    on<LeadLists>(_getLeadList);
    on<SelectedLead>(_onSelectLead);
    on<LeadLoadMore>(_onLoadMoreLeades);
    on<SearchLead>(_onSearchLead);
    on<CreateLead>(_onCreateLead);
    on<UpdateLead>(_onUpdateLead);
    on<DeleteLead>(_onDeleteLead);

    on<CreateLeadFollow>(_onCreateLeadFollowUp);
    on<UpdateLeadFollowUp>(_onUpdateLeadFollow);
    on<DeleteLeadFollowUp>(_onDeleteLeadFollow);
  }
  void _onDeleteLead(DeleteLead event, Emitter<LeadState> emit) async {
    // if (emit is NotesSuccess) {
    final Lead = event.LeadId;

    try {
      Map<String, dynamic> result = await LeadsRepo().deleteLeads(
        id: Lead,
        token: true,
      );
      if (result['error'] == false) {
        emit(LeadDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((LeadDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(LeadError(e.toString()));
    }
    // }
  }

  void _onDeleteLeadFollow(
      DeleteLeadFollowUp event, Emitter<LeadState> emit) async {
    // if (emit is NotesSuccess) {
    final Lead = event.LeadId;

    try {
      Map<String, dynamic> result =
          await LeadsFollowUpRepo().deleteLeadsFollowUp(
        id: Lead,
        token: true,
      );
      if (result['error'] == false) {
        emit(LeadDeleteFollowUpSuccess());
        add(LeadLists());
      }
      if (result['error'] == true) {
        emit((LeadDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(LeadError(e.toString()));
    }
    // }
  }

  void _onUpdateLead(UpdateLead event, Emitter<LeadState> emit) async {
    if (state is LeadSuccess) {
      final id = event.id;

      emit(LeadEditLoading());

      try {
        Map<String, dynamic> updatedProject = await LeadsRepo().updateLeads(
          id: id,
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          phone: event.phone,
          countryCode: event.countryCode,
          countryIsoCode: event.countryIsoCode,
          leadSourceId: event.leadSourceId,
          leadSource: event.leadSource,
          leadStageId: event.leadStageId,
          leadStage: event.leadStage,
          assignedTo: event.assignedTo,
          assignedUser: event.assignedUser,
          jobTitle: event.jobTitle,
          industry: event.industry,
          company: event.company,
          website: event.website,
          linkedin: event.linkedin,
          instagram: event.instagram,
          facebook: event.facebook,
          pinterest: event.pinterest,
          city: event.city,
          state: event.state,
          zip: event.zip,
          country: event.country,
        );

        if (updatedProject['error'] == false) {
          emit(LeadEditSuccess());
        } else {
          flutterToastCustom(msg: updatedProject['message']);
          emit(LeadEditError(updatedProject['message']));
        }
      } catch (e) {
        print('Error while updating Lead: $e');
      }
    }
  }

  void _onUpdateLeadFollow(
      UpdateLeadFollowUp event, Emitter<LeadState> emit) async {
    if (state is LeadSuccess) {
      final id = event.id;

      emit(LeadEditLoading());

      try {
        FollowUps model = FollowUps(
            status: event.status,
            type: event.type,
            assignedTo: event.assignedTo!,
            followUpAt: event.followupAt,
            note: event.note);
        Map<String, dynamic> updatedProject = await LeadsFollowUpRepo().updateLeadsFollowUp(id: id, model: model);

        if (updatedProject['error'] == false) {
          emit(LeadEditFollowUpSuccess());
        } else {
          flutterToastCustom(msg: updatedProject['message']);
          emit(LeadEditFollowUpError(updatedProject['message']));
        }
      } catch (e) {
        print('Error while updating Lead: $e');
      }
    }
  }

  Future<void> _onCreateLead(CreateLead event, Emitter<LeadState> emit) async {
    try {
      emit(LeadCreateLoading());

      var result = await LeadsRepo().createLead(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        countryCode: event.countryCode,
        countryIsoCode: event.countryIsoCode,
        leadSourceId: event.leadSourceId,
        leadSource: event.leadSource,
        leadStageId: event.leadStageId,
        leadStage: event.leadStage,
        assignedTo: event.assignedTo,
        assignedUser: event.assignedUser,
        jobTitle: event.jobTitle,
        industry: event.industry,
        company: event.company,
        website: event.website,
        linkedin: event.linkedin,
        instagram: event.instagram,
        facebook: event.facebook,
        pinterest: event.pinterest,
        city: event.city,
        state: event.state,
        zip: event.zip,
        country: event.country,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
      );

      if (result['error'] == false) {
        emit(LeadCreateSuccess());
      }
      if (result['error'] == true) {
        emit(LeadCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((LeadError("Error: $e")));
    }
  }

  Future<void> _onCreateLeadFollowUp(
      CreateLeadFollow event, Emitter<LeadState> emit) async {
    try {
      emit(LeadCreateLoading());
      FollowUps model = FollowUps(
          status: event.status,
          type: event.type,
          assignedTo: event.assignedTo,
          followUpAt: event.followupAt,
          note: event.note,
      );

      var result = await LeadsFollowUpRepo().createLeadsFollowUp(model: model,leadId:event.leadId);

      if (result['error'] == false) {
        emit(LeadCreateFollowUpSuccess());
      }
      if (result['error'] == true) {
        emit(LeadCreateFollowUpError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((LeadError("Error: $e")));
    }
  }

  Future<void> _onSearchLead(SearchLead event, Emitter<LeadState> emit) async {
    try {
      List<LeadModel> Leads = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await LeadsRepo().getLeadsList(
        limit: _limit,
        offset: _offset,
        search: event.searchQuery,
      );
      Leads = List<LeadModel>.from(
          result['data'].map((projectData) => LeadModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax = Leads.length >= result['total'];
      if (result['error'] == false) {
        emit(LeadSuccess(Leads, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(LeadError(result['message']));
      }
    } on ApiException catch (e) {
      emit(LeadError("Error: $e"));
    }
  }

  Future<void> _getLeadList(LeadLists event, Emitter<LeadState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<LeadModel> priorities = [];
      emit(LeadLoading());
      Map<String, dynamic> result = await LeadsRepo().getLeadsList(
        offset: _offset,
        limit: _limit,
      );

      priorities = List<LeadModel>.from(
          result['data'].map((projectData) => LeadModel.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];

      if (result['error'] == false) {
        emit(LeadSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(LeadError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(LeadError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreLeades(
      LeadLoadMore event, Emitter<LeadState> emit) async {
    if (state is LeadSuccess && !_isFetching) {
      final currentState = state as LeadSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;

      try {
        // Fetch more Leades from the repository
        Map<String, dynamic> result = await LeadsRepo().getLeadsList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        // Convert the fetched data into a list of Leades
        List<LeadModel> moreLeades = List<LeadModel>.from(result['data']
            .map((projectData) => LeadModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreLeades.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of Leades
        bool hasReachedMax =
            (currentState.Lead.length + moreLeades.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of Leades
          emit(LeadSuccess(
            [...currentState.Lead, ...moreLeades],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(LeadError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(LeadError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(LeadError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }

  void _onSelectLead(SelectedLead event, Emitter<LeadState> emit) {
    if (state is LeadSuccess) {
      final currentState = state as LeadSuccess;
      emit(LeadSuccess(
          currentState.Lead, event.selectedIndex, event.selectedTitle, false));
    }
  }
}
