import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/end_points.dart';
import '../../config/strings.dart';
import '../../data/localStorage/hive.dart';
import '../../data/repositories/clients/client_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  int _offset = 0; // Start with the initial offset
  bool _isLoading = false;

  final int _limit = 10;
  bool _hasReachedMax = false;
  ClientBloc() : super(ClientInitial()) {
    on<ClientList>(_getClientList);
    on<ClientListId>(_getClientListId);
    on<SelectedClient>(_onSelectClient);
    on<ClientLoadMore>(_onLoadMore);
    on<ToggleClientSelection>(_onToggleClientSelection);
    on<ClientsCreated>(_onCreateClient);
    on<UpdateClients>(_onUpdateClient);
    on<DeleteClients>(_onDeleteClient);
    on<SearchClients>(_onSearchClient);
    on<SearchClientsCreator>(_onSearchClientCreator);
  }
  Future<void> _getClientList(ClientList event, Emitter<ClientState> emit) async {
    // if (state is ClientLoading || _hasReachedMax) return; // Prevent duplicate calls

    try {
      List<AllClientModel> clients = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ClientLoading());

      Map<String, dynamic> result = await ClientRepo().getClients(
        id: event.id,
        token: true,
        limit: _limit,
        offset: _offset,
      );

      clients = List<AllClientModel>.from(
        result['data'].map((projectData) => AllClientModel.fromJson(projectData)),
      );

      _offset += _limit;
      _hasReachedMax = clients.length >= result['total'];
      _isLoading = !_hasReachedMax;

      emit(ClientPaginated(
        client: clients,
        hasReachedMax: _hasReachedMax,
        isLoading: _isLoading,
      ));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(ClientError("Error: $e"));
    }
  }


  Future<void> _getClientListId(
      ClientListId event, Emitter<ClientState> emit) async {
    try {



      List<AllClientModel> clients = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<AllClientModel> existingClients = [];
      if(state is  ClientWithId){
        var oldData = state as  ClientWithId;
        existingClients = oldData.client;
      }else{
        emit(ClientLoading());
      }








      Map<String, dynamic> result = await ClientRepo().getClients(
        id: event.id,
        token: true,
        limit: _limit,
        offset: _offset,
      );
      clients = List<AllClientModel>.from(result['data']
          .map((projectData) => AllClientModel.fromJson(projectData)));

      if(state is ClientWithId){
        bool flag = false;
        for(var i = 0; i< existingClients.length; i++){
          if(event.id == existingClients[i].id){
            existingClients[i] = clients[0];

            flag = true;
          }
        }
        for(var i = 0; i< existingClients.length; i++){

        }
        if(!flag){

          existingClients.addAll(clients);
        }
        emit(ClientWithId(
          existingClients,
        ));
        return;
      }
      emit(ClientWithId(
        clients,
      ));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ClientError("Error: $e")));
    }
  }

  Future<void> _onSearchClient(
      SearchClients event, Emitter<ClientState> emit) async {
    _isLoading = true; // Set loading state to true
    emit(ClientLoading()); // Optionally emit a loading state if needed

    try {
      List<AllClientModel> client = [];


      // Fetch clients based on the search query
      Map<String, dynamic> result = await ClientRepo().getClients(
        limit: _limit,
        offset: 0,
        search: event.searchQuery,
        token: true,
      );

      client = List<AllClientModel>.from(result['data']
          .map((clientData) => AllClientModel.fromJson(clientData)));

      // Check if the end of the list is reached
      bool hasReachedMax = client.length >= result['total'];

      _isLoading = !_hasReachedMax;

      if (result['error'] == false) {
        // Emit the new paginated state with the search results
        emit(ClientPaginated(
          client: client,
          hasReachedMax: hasReachedMax,
          isLoading: _isLoading,
        ));
      } else {
        // Handle error response
        emit(ClientError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      // Handle API exceptions
      emit(ClientError("Error: $e"));
      flutterToastCustom(msg: "$e");
    } finally {
      _isLoading = false; // Reset loading state
    }
  }
  Future<void> _onSearchClientCreator(
      SearchClientsCreator event, Emitter<ClientState> emit) async {
    _isLoading = true; // Set loading state to true
    emit(ClientLoading()); // Optionally emit a loading state if needed

    try {
      List<AllClientModel> client = [];


      // Fetch clients based on the search query
      Map<String, dynamic> result = await ClientRepo().getClients(
        limit: _limit,
        offset: 0,
        search: event.searchQuery,
        token: true,
      );

      client = List<AllClientModel>.from(result['data']
          .map((clientData) => AllClientModel.fromJson(clientData)));

      // Check if the end of the list is reached
      bool hasReachedMax = client.length >= result['total'];

      _isLoading = !_hasReachedMax;

      if (result['error'] == false) {
        // Emit the new paginated state with the search results
        emit(ClientPaginated(
          client: client,
          hasReachedMax: hasReachedMax,
          isLoading: _isLoading,
        ));
      } else {
        // Handle error response
        emit(ClientError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      // Handle API exceptions
      emit(ClientError("Error: $e"));
      flutterToastCustom(msg: "$e");
    } finally {
      _isLoading = false; // Reset loading state
    }
  }

  Future<void> _onLoadMore(
      ClientLoadMore event, Emitter<ClientState> emit) async {
    if (state is ClientPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Set loading state to true
      emit((state as ClientPaginated)
          .copyWith(isLoading: true)); // Emit loading state

      try {
        final currentState = state as ClientPaginated;
        final updated = List<AllClientModel>.from(currentState.client);

        // Fetch additional clients from the repository
        Map<String, dynamic> result = await ClientRepo().getClients(
          token: true,
          limit: _limit,
          offset: _offset,
          search: event.searchWord,
        );

        final additionalClients = List<AllClientModel>.from(result['data']
            .map((clientData) => AllClientModel.fromJson(clientData)));

        print(
            "Loaded ${additionalClients.length} items. Offset Before: $_offset");

        if (result['error'] == false) {
          // Append new clients
          updated.addAll(additionalClients);

          // Check if the total fetched clients have reached or exceeded the total available
          final totalFetched = updated.length;
          final totalAvailable = result['total'];

          if (totalFetched >= totalAvailable) {
            _hasReachedMax = true;
          } else {
            _offset += _limit; // Increment the offset for the next load
          }
          _isLoading = !_hasReachedMax;
          // Emit updated state with loaded clients
          emit((state as ClientPaginated).copyWith(
            client: updated,
            hasReachedMax: _hasReachedMax,
            isLoading: _isLoading,
          ));
        } else {
          // Handle API error
          emit(ClientError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        // Handle API exceptions
        emit(ClientError("Error: $e"));
      } finally {
        _isLoading = false; // Reset loading state
      }
    }
  }

  void _onSelectClient(SelectedClient event, Emitter<ClientState> emit) {
    if (state is ClientSuccess) {
      final currentState = state as ClientSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedClientnames =
          List<String>.from(currentState.selectedClientnames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedClientnames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedClientnames.add(event.selectedTitle);
      }

      emit(ClientSuccess(
        client: currentState.client,
        selectedIndices: selectedIndices,
        selectedClientnames: selectedClientnames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _onToggleClientSelection(
      ToggleClientSelection event, Emitter<ClientState> emit) {
    if (state is ClientSuccess) {
      final currentState = state as ClientSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedClientIds =
          List<int>.from(currentState.selectedIndices);
      final updatedSelectedClientnames =
          List<String>.from(currentState.selectedClientnames);

      // Check if the Client is already selected based on ClientId
      final isSelected = updatedSelectedClientIds.contains(event.clientId);

      if (isSelected) {
        // Find the index of the ClientId in the selectedIndices list
        final removeIndex = updatedSelectedClientIds.indexOf(event.clientId);

        // Remove ClientId and corresponding Clientname
        updatedSelectedClientIds.removeAt(removeIndex);
        updatedSelectedClientnames.removeAt(removeIndex);
      } else {
        // Add ClientId and corresponding Clientname
        updatedSelectedClientIds.add(event.clientId);
        updatedSelectedClientnames.add(event.clientName);
      }

      // Emit the updated state
      emit(ClientSuccess(
        client: currentState.client,
        selectedIndices: updatedSelectedClientIds,
        selectedClientnames: updatedSelectedClientnames,
        isLoadingMore: currentState.isLoadingMore,
      ));

    }
  }

  void _onCreateClient(ClientsCreated event, Emitter<ClientState> emit) async {
    try {
      emit(ClientLoadingCreate());
      // Map<String,dynamic> result = await ClientRepo().createClient( Client:event.ClientList, );
      // String fileName = event.image!.path.split('/').last;
      // Map<String, dynamic> result = await UserRepo().createUser(user: event.userList);
      FormData formData = FormData.fromMap({
        "id": event.clientList.id,
        "first_name": event.clientList.firstName,
        "last_name": event.clientList.lastName,
        "role": event.clientList.role,
        "company": event.clientList.company,
        "email": event.clientList.email,
        "phone": event.clientList.phone,
        "country_code": event.clientList.countryCode,
        "country_iso_code": event.clientList.countryIsoCode,
        "password": event.clientList.password,
        "password_confirmation": event.clientList.passwordConfirmation,
        "type": event.clientList.type,
        "address": event.clientList.address,
        "city": event.clientList.type,
        "state": event.clientList.state,
        "country": event.clientList.country,
        "zip": event.clientList.zip,
        "status": event.clientList.status,
        "internal_purpose": event.clientList.internalPurpose,
        "email_verification_mail_sent":
            event.clientList.emailVerificationMailSent,
        "email_verified_at": event.clientList.emailVerificationMailSent,
        "created_at": event.clientList.createdAt,
        "updated_at": event.clientList.updatedAt,
        "assigned": event.clientList.assigned
      });

      var token = await HiveStorage.getToken();
      var userbox = await Hive.openBox(userBox);
      var workspace = userbox.get(workSpaceId);


      final response = await Dio().post(createClientUrl,
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            // Replace with actual token if needed
            'Content-Type': 'application/json',
            // Replace with actual token if needed
            'Accept': 'application/json',
            // Replace with actual token if needed
            'workspace-id': '$workspace',
            // Replace with actual token if needed
          }));
      // Ensure result['data'] is a List before mapping
      var result = response.data;


      if (result['error'] == false) {

        emit(ClientSuccessCreate());
        add(ClientList());
      }
      if (result['error'] == true) {
        emit((ClientCreateError(result['message'])));
        add(ClientList());
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ClientError("Error: $e")));
    }
  }

  void _onUpdateClient(UpdateClients event, Emitter<ClientState> emit) async {
    try {
      // Assuming `updateClient` is a method in your `ClientRepo` to handle Client updates.
      emit(ClientLoadingEdit());
      Map<String, dynamic> result =
          await ClientRepo().updateClient(client: event.client);
      // updatedClient = List<AllClientModel>.from(result['data']
      //     .map((projectData) => AllClientModel.fromJson(projectData)));
      if (result['error'] == false) {
        emit(ClientEditSuccess());
        // add(ClientList()); // Emit the updated Client
      }
      if (result['error'] == true) {
        emit((ClientEditError(result['message'])));
        // add(ClientList());
        flutterToastCustom(msg: result['message']);
      } // Emit the updated Client
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      flutterToastCustom(msg: "$e");
    }
  }

  void _onDeleteClient(DeleteClients event, Emitter<ClientState> emit) async {

    final client = event.clientId;
    try {
      Map<String, dynamic> result = await ClientRepo().getDeleteClient(
        id: client,
        token: true,
      );

      if (result['data']['error'] == false) {
        emit(ClientDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ClientDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    }  catch (e) {

      emit((ClientError("Error: $e")));
    }
    // }
  }
}
