import 'package:equatable/equatable.dart';

import '../../data/model/status_model.dart';
abstract class StatusMultiState extends Equatable{
  @override
  List<Object?> get props => [];
}

class StatusMultiInitial extends StatusMultiState {}

class StatusMultiLoading extends StatusMultiState {}

class StatusMultiSuccess extends StatusMultiState {
  final List<Statuses> statusMulti;
  final List<int> selectedIndices;
  final List<String> selectedStatusMultinames;
  final bool isLoadingMore;

  StatusMultiSuccess({
    required this.statusMulti,
    this.selectedIndices = const [],
    this.selectedStatusMultinames = const [],
    this.isLoadingMore = false,
  });
}

class StatusMultiPaginated extends StatusMultiState {
  final List<Statuses> statusMulti;
  final bool hasReachedMax;

  StatusMultiPaginated({
    required this.statusMulti,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [statusMulti, hasReachedMax];
}

class StatusMultiSuccessCreate extends StatusMultiState {


  StatusMultiSuccessCreate();

  @override
  List<Object> get props => [];
}

class StatusMultiError extends StatusMultiState {
  final String errorMessage;
  StatusMultiError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusMultiCreateError extends StatusMultiState {
  final String errorMessage;

  StatusMultiCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusMultiEditError extends StatusMultiState {
  final String errorMessage;

  StatusMultiEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusMultiEditSuccess extends StatusMultiState {
  StatusMultiEditSuccess();
  @override
  List<Object> get props => [];
}
class StatusMultiCreateSuccess extends StatusMultiState {
  StatusMultiCreateSuccess();
  @override
  List<Object> get props => [];
}

class StatusMultiDeleteError extends StatusMultiState {
  final String errorMessage;

  StatusMultiDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusMultiDeleteSuccess extends StatusMultiState {
  StatusMultiDeleteSuccess();
  @override
  List<Object> get props => [];
}