import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';




abstract class ClientidState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ClientidInitial extends ClientidState {}
class ClientIdError extends ClientidState {
  final String errorMessage;
  ClientIdError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ClientidLoading extends ClientidState {}
class ClientidWithId extends ClientidState {
  final List<AllClientModel> client;

  ClientidWithId(
      this.client,

      );
  @override
  List<Object> get props => [client];
}
