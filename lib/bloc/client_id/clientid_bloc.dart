import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';


import '../../api_helper/api.dart';
import '../../data/model/clients/all_client_model.dart';
import '../../data/repositories/clients/client_repo.dart';
import 'clientid_event.dart';
import 'clientid_state.dart';


class ClientidBloc extends Bloc<ClientidEvent, ClientidState> {
  ClientidBloc() : super(ClientidInitial()) {
    on<ClientIdListId>(_getClientListId);
  }
  Future<void> _getClientListId(
      ClientIdListId event, Emitter<ClientidState> emit) async {
    try {

      // emit(ClientidLoading()); // Ensure UI shows loading state

      List<AllClientModel> clients = [];
      List<AllClientModel> existingClients = [];

      if (state is ClientidWithId) {
        print("Existing clients found");
        existingClients = List.from((state as ClientidWithId).client); // Deep copy
      }

      // Fetch clients from API
      Map<String, dynamic> result = await ClientRepo().getClients(
        id: event.id,
        token: true,
      );

      clients = List<AllClientModel>.from(
        result['data'].map((clientData) => AllClientModel.fromJson(clientData)),
      );

      // Update existing clients list
      bool found = false;
      for (int i = 0; i < existingClients.length; i++) {
        if (existingClients[i].id == event.id) {
          existingClients[i] = clients.first;
          print("Client updated");
          found = true;
          break;
        }
      }

      if (!found) {
        print("New client added");
        existingClients.addAll(clients);
      }

      emit(ClientidWithId(existingClients)); // Emit updated client list
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(ClientIdError("Error: $e")); // Emit error state if API fails
    }
  }

}
