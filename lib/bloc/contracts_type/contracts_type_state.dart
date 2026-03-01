import 'package:equatable/equatable.dart';

import '../../data/model/contract/contract_type_model.dart';

abstract class ContractTypeState extends Equatable {
  const ContractTypeState();

  @override
  List<Object?> get props => [];
}

class ContractTypeInitial extends ContractTypeState {}

class ContractTypeLoading extends ContractTypeState {}

class ContractTypeSuccess extends ContractTypeState {
  const ContractTypeSuccess([this.ContractType=const []]);

  final List<ContractTypeModel> ContractType;

  @override
  List<Object> get props => [ContractType];
}

class ContractTypeError extends ContractTypeState {
  final String errorMessage;
  const ContractTypeError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DrawingNoteUpdated extends ContractTypeState {
  final String drawing;
  const DrawingNoteUpdated(this.drawing);

  @override
  List<Object> get props => [drawing];
}
class ContractTypePaginated extends ContractTypeState {
  final List<ContractTypeModel> ContractType;
  final bool hasReachedMax;
  const ContractTypePaginated({
    required this.ContractType,
    required this.hasReachedMax,
  });
  @override
  List<Object> get props => [ContractType, hasReachedMax];
}
class ContractTypeCreateError extends ContractTypeState {
  final String errorMessage;

  const ContractTypeCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ContractTypeEditError extends ContractTypeState {
  final String errorMessage;

  const ContractTypeEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ContractTypeEditSuccessLoading extends ContractTypeState {}
class ContractTypeCreateSuccessLoading extends ContractTypeState {}
class ContractTypeEditSuccess extends ContractTypeState {
  const ContractTypeEditSuccess();
  @override
  List<Object> get props => [];
}
class ContractTypeCreateSuccess extends ContractTypeState {
  const ContractTypeCreateSuccess();
  @override
  List<Object> get props => [];
}
class ContractTypeDeleteError extends ContractTypeState {
  final String errorMessage;

  const ContractTypeDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ContractTypeDeleteSuccess extends ContractTypeState {
  const ContractTypeDeleteSuccess();
  @override
  List<Object> get props => [];
}