import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';



abstract class SingleClientState extends Equatable{
  @override
  List<Object?> get props => [];
}

class SingleClientInitial extends SingleClientState {}
class SingleClientLoading extends SingleClientState {}
class SingleClientSuccess extends SingleClientState {
  SingleClientSuccess(this.singleClient,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<AllClientModel> singleClient;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [singleClient,selectedIndex!,selectedTitle,isLoadingMore];
}

class SingleClientError extends SingleClientState {
  final String errorMessage;
  SingleClientError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
