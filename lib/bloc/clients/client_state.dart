import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';




abstract class ClientState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientSuccess extends ClientState {
  final List<AllClientModel> client;
  final List<int> selectedIndices;
  final List<String> selectedClientnames;
  final bool isLoadingMore;

  ClientSuccess({
    required this.client,
    this.selectedIndices = const [],
    this.selectedClientnames = const [],
    this.isLoadingMore = false,
  });
}
class ClientWithId extends ClientState {
  final List<AllClientModel> client;

  ClientWithId(
      this.client,

      );
  @override
  List<Object> get props => [client];
}
class ClientPaginated extends ClientState {
  final List<AllClientModel> client;
  final bool hasReachedMax;
  final bool isLoading;

  ClientPaginated({
    required this.client,
    required this.hasReachedMax,
    this.isLoading = false,
  });

  ClientPaginated copyWith({
    List<AllClientModel>? client,
    bool? hasReachedMax,
    bool? isLoading,
  }) {
    return ClientPaginated(
      client: client ?? this.client,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [client, hasReachedMax, isLoading];
}

class ClientLoadingCreate extends ClientState {}
class ClientSuccessCreate extends ClientState {


  ClientSuccessCreate();

  @override
  List<Object> get props => [];
}

class ClientError extends ClientState {
  final String errorMessage;
  ClientError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ClientCreateError extends ClientState {
  final String errorMessage;

  ClientCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ClientEditError extends ClientState {

  final String errorMessage;

  ClientEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ClientLoadingEdit extends ClientState {}
class ClientEditSuccess extends ClientState {
  ClientEditSuccess();
  @override
  List<Object> get props => [];
}
class ClientCreateSuccess extends ClientState {
  ClientCreateSuccess();
  @override
  List<Object> get props => [];
}

class ClientDeleteError extends ClientState {
  final String errorMessage;

  ClientDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ClientDeleteSuccess extends ClientState {
  ClientDeleteSuccess();
  @override
  List<Object> get props => [];
}