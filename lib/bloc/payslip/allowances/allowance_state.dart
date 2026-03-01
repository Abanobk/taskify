import 'package:equatable/equatable.dart';

import '../../../data/model/allowance.dart';

abstract class AllowancesState extends Equatable {
  const AllowancesState();

  @override
  List<Object?> get props => [];
}

class AllowancesInitial extends AllowancesState {}

class AllowancesLoading extends AllowancesState {}

class AllowancesSuccess extends AllowancesState {
  const AllowancesSuccess([this.Allowances=const []]);

  final List<AllowanceModel> Allowances;

  @override
  List<Object> get props => [Allowances];
}

class AllowancesError extends AllowancesState {
  final String errorMessage;
  const AllowancesError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class AllowancesPaginated extends AllowancesState {
  final List<AllowanceModel> Allowances;
  final bool hasReachedMax;

  const AllowancesPaginated({
    required this.Allowances,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Allowances, hasReachedMax];
}
class AllowancesCreateError extends AllowancesState {
  final String errorMessage;

  const AllowancesCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class AllowancesEditError extends AllowancesState {
  final String errorMessage;

  const AllowancesEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class AllowancesEditSuccessLoading extends AllowancesState {}
class AllowancesCreateSuccessLoading extends AllowancesState {}
class AllowancesEditSuccess extends AllowancesState {
  const AllowancesEditSuccess();
  @override
  List<Object> get props => [];
}
class AllowancesCreateSuccess extends AllowancesState {
  const AllowancesCreateSuccess();
  @override
  List<Object> get props => [];
}
class AllowancesDeleteError extends AllowancesState {
  final String errorMessage;

  const AllowancesDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class AllowancesDeleteSuccess extends AllowancesState {
  const AllowancesDeleteSuccess();
  @override
  List<Object> get props => [];
}