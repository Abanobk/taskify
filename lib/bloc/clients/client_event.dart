
import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:taskify/data/model/clients/all_client_model.dart';

abstract class ClientEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientList extends ClientEvent {
  final int? id;
  ClientList({this.id});
  @override
  List<Object> get props => [id!];
}
class ClientLoadMore extends ClientEvent {
  final String searchWord;

  ClientLoadMore(this.searchWord);

  @override
  List<Object?> get props => [searchWord];
}
class ClientListId extends ClientEvent {
  final int? id;

  ClientListId(this.id);

  @override
  List<Object?> get props => [id];
}
class SelectedClient extends ClientEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedClient(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleClientSelection extends ClientEvent {
  final int clientId;
  final String clientName;

  ToggleClientSelection(this.clientId, this.clientName);
}
class ClientsCreated extends ClientEvent {
  final AllClientModel clientList;

  final File? image;
  final String? profileImage;
  // final Client Client;

  ClientsCreated(this.clientList,this.image,this.profileImage);
  @override
  List<Object> get props => [ClientList];
}
class AllClientsList extends ClientEvent {

  AllClientsList();

  @override
  List<Object> get props => [];
}
class UpdateClients extends ClientEvent {
  final AllClientModel client;

  UpdateClients(this.client);
  @override
  List<Object> get props => [client];
}

class DeleteClients extends ClientEvent {
  final int clientId;

  DeleteClients(this.clientId);

  @override
  List<Object?> get props => [clientId];
}
class SearchClients extends ClientEvent {
  final String searchQuery;

  SearchClients(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}class SearchClientsCreator extends ClientEvent {
  final String searchQuery;

  SearchClientsCreator(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
