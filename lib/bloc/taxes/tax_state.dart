import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/finance/tax_model.dart';

abstract class TaxesState extends Equatable {
  const TaxesState();

  @override
  List<Object?> get props => [];
}

class TaxesInitial extends TaxesState {}

class TaxesLoading extends TaxesState {}

class TaxesSuccess extends TaxesState {
  const TaxesSuccess([this.Taxes=const []]);

  final List<TaxModel> Taxes;

  @override
  List<Object> get props => [Taxes];
}

class TaxesError extends TaxesState {
  final String errorMessage;
  const TaxesError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class TaxesPaginated extends TaxesState {
  final List<TaxModel> Taxes;
  final bool hasReachedMax;

  const TaxesPaginated({
    required this.Taxes,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Taxes, hasReachedMax];
}
class TaxesCreateError extends TaxesState {
  final String errorMessage;

  const TaxesCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaxesEditError extends TaxesState {
  final String errorMessage;

  const TaxesEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaxesEditSuccessLoading extends TaxesState {}
class TaxesCreateSuccessLoading extends TaxesState {}
class TaxesEditSuccess extends TaxesState {
  const TaxesEditSuccess();
  @override
  List<Object> get props => [];
}
class TaxesCreateSuccess extends TaxesState {
  const TaxesCreateSuccess();
  @override
  List<Object> get props => [];
}
class TaxesDeleteError extends TaxesState {
  final String errorMessage;

  const TaxesDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaxesDeleteSuccess extends TaxesState {
  const TaxesDeleteSuccess();
  @override
  List<Object> get props => [];
}