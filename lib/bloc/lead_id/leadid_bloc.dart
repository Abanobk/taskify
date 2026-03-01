import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/repositories/lead/lead_repo.dart';


import '../../api_helper/api.dart';
import '../../data/model/leads/leads_model.dart';
import 'leadid_event.dart';
import 'leadid_state.dart';


class LeadIdBloc extends Bloc<LeadidEvent, LeadidState> {
  LeadIdBloc() : super(LeadidInitial()) {
    on<LeadIdListId>(_getLeadListId);
  }
  Future<void> _getLeadListId(
      LeadIdListId event, Emitter<LeadidState> emit) async {
    try {

      // emit(LeadidLoading()); // Ensure UI shows loading state

      List<LeadModel> Leads = [];
      List<LeadModel> existingLeads = [];

      if (state is LeadidWithId) {
        print("Existing Leads found");
        existingLeads = List.from((state as LeadidWithId).Lead); // Deep copy
      }

      // Fetch Leads from API
      Map<String, dynamic> result = await LeadsRepo().getLeadsList(
        id: event.id,
      );

      Leads = List<LeadModel>.from(
        result['data'].map((LeadData) => LeadModel.fromJson(LeadData)),
      );

      // Update existing Leads list
      bool found = false;
      for (int i = 0; i < existingLeads.length; i++) {
        if (existingLeads[i].id == event.id) {
          existingLeads[i] = Leads.first;
          print("Lead updated");
          found = true;
          break;
        }
      }

      if (!found) {
        print("New Lead added");
        existingLeads.addAll(Leads);
      }

      emit(LeadidWithId(existingLeads)); // Emit updated Lead list
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(LeadIdError("Error: $e")); // Emit error state if API fails
    }
  }

}
