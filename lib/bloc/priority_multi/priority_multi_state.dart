import 'package:equatable/equatable.dart';

import '../../data/model/priority_model.dart';





abstract class PriorityMultiState extends Equatable{
  @override
  List<Object?> get props => [];
}

class PriorityMultiInitial extends PriorityMultiState {}

class PriorityMultiLoading extends PriorityMultiState {}

class PriorityMultiSuccess extends PriorityMultiState {
  final List<Priorities> priorityMulti;
  final List<int> selectedIndices;
  final List<String> selectedPriorityMultinames;
  final bool isLoadingMore;

  PriorityMultiSuccess({
    required this.priorityMulti,
    this.selectedIndices = const [],
    this.selectedPriorityMultinames = const [],
    this.isLoadingMore = false,
  });
}

class PriorityMultiPaginated extends PriorityMultiState {
  final List<Priorities> priorityMulti;
  final bool hasReachedMax;

  PriorityMultiPaginated({
    required this.priorityMulti,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [priorityMulti, hasReachedMax];
}

class PriorityMultiSuccessCreate extends PriorityMultiState {


  PriorityMultiSuccessCreate();

  @override
  List<Object> get props => [];
}

class PriorityMultiError extends PriorityMultiState {
  final String errorMessage;
  PriorityMultiError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityMultiCreateError extends PriorityMultiState {
  final String errorMessage;

  PriorityMultiCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityMultiEditError extends PriorityMultiState {
  final String errorMessage;

  PriorityMultiEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityMultiEditSuccess extends PriorityMultiState {
  PriorityMultiEditSuccess();
  @override
  List<Object> get props => [];
}
class PriorityMultiCreateSuccess extends PriorityMultiState {
  PriorityMultiCreateSuccess();
  @override
  List<Object> get props => [];
}

class PriorityMultiDeleteError extends PriorityMultiState {
  final String errorMessage;

  PriorityMultiDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityMultiDeleteSuccess extends PriorityMultiState {
  PriorityMultiDeleteSuccess();
  @override
  List<Object> get props => [];
}