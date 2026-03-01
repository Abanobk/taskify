import 'package:equatable/equatable.dart';

import '../../../data/model/payslip/deduction-model.dart';

abstract class DeductionsState extends Equatable {
  const DeductionsState();

  @override
  List<Object?> get props => [];
}

class DeductionsInitial extends DeductionsState {}

class DeductionsLoading extends DeductionsState {}

class DeductionsSuccess extends DeductionsState {
  const DeductionsSuccess([this.Deductions=const []]);

  final List<DeductionModel> Deductions;

  @override
  List<Object> get props => [Deductions];
}

class DeductionsError extends DeductionsState {
  final String errorMessage;
  const DeductionsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class DeductionsPaginated extends DeductionsState {
  final List<DeductionModel> Deductions;
  final bool hasReachedMax;

  const DeductionsPaginated({
    required this.Deductions,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Deductions, hasReachedMax];
}
class DeductionsCreateError extends DeductionsState {
  final String errorMessage;

  const DeductionsCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DeductionsEditError extends DeductionsState {
  final String errorMessage;

  const DeductionsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DeductionsEditSuccessLoading extends DeductionsState {}
class DeductionsCreateSuccessLoading extends DeductionsState {}
class DeductionsEditSuccess extends DeductionsState {
  const DeductionsEditSuccess();
  @override
  List<Object> get props => [];
}
class DeductionsCreateSuccess extends DeductionsState {
  const DeductionsCreateSuccess();
  @override
  List<Object> get props => [];
}
class DeductionsDeleteError extends DeductionsState {
  final String errorMessage;

  const DeductionsDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DeductionsDeleteSuccess extends DeductionsState {
  const DeductionsDeleteSuccess();
  @override
  List<Object> get props => [];
}