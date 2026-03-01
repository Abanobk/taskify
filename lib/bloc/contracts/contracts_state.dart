import 'package:equatable/equatable.dart';

import '../../data/model/contract/contract_model.dart';

abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {}

class ContractSuccess extends ContractState {
  const ContractSuccess([this.Contract=const []]);

  final List<ContractModel> Contract;

  @override
  List<Object> get props => [Contract];
}

class ContractError extends ContractState {
  final String errorMessage;
  const ContractError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class ContractPaginated extends ContractState {
  final List<ContractModel> Contract;
  final bool hasReachedMax;

  const ContractPaginated({
    required this.Contract,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Contract, hasReachedMax];
}
class ContractCreateError extends ContractState {
  final String errorMessage;

  const ContractCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ContractEditError extends ContractState {
  final String errorMessage;

  const ContractEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ContractEditSuccessLoading extends ContractState {}
class ContractCreateSuccessLoading extends ContractState {}
class ContractEditSuccess extends ContractState {
  const ContractEditSuccess();
  @override
  List<Object> get props => [];
}
class ContractCreateSuccess extends ContractState {
  const ContractCreateSuccess();
  @override
  List<Object> get props => [];
}class ContractSignCreateSuccess extends ContractState {
  const ContractSignCreateSuccess();
  @override
  List<Object> get props => [];
}
class ContractDeleteError extends ContractState {
  final String errorMessage;

  const ContractDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}class ContractSignDeleteError extends ContractState {
  final String errorMessage;

  const ContractSignDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class ContractSignCreateError extends ContractState {
  final String errorMessage;

  const ContractSignCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ContractDeleteSuccess extends ContractState {
  const ContractDeleteSuccess();
  @override
  List<Object> get props => [];
}class ContractSignDeleteSuccess extends ContractState {
  const ContractSignDeleteSuccess();
  @override
  List<Object> get props => [];
}