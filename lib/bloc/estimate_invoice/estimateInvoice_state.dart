import 'package:equatable/equatable.dart';
import '../../data/model/finance/estimate_invoices_model.dart';

abstract class EstinateInvoiceState extends Equatable {
  const EstinateInvoiceState();

  @override
  List<Object?> get props => [];
}
class EstinateInvoiceSelected extends EstinateInvoiceState {
  final EstimateInvoicesModel selectedInvoice;

  const EstinateInvoiceSelected({required this.selectedInvoice});
}
class AmountCalculatedState extends EstinateInvoiceState {
  final String calculatedAmount;
  final double taxAmount;
  final int Itemd;
  final double grandTotal;
  final double grandTotalTax;

  const AmountCalculatedState({
    required this.calculatedAmount,
    required this.taxAmount,
    required this.Itemd,
    this.grandTotal = 0.0,
    this.grandTotalTax = 0.0,
  });

  @override
  List<Object> get props => [calculatedAmount, taxAmount, Itemd, grandTotal, grandTotalTax];
}



class EstinateInvoiceInitial extends EstinateInvoiceState {}

class EstinateInvoiceLoading extends EstinateInvoiceState {}

class EstinateInvoiceSuccess extends EstinateInvoiceState {
  const EstinateInvoiceSuccess([this.EstinateInvoice=const []]);

  final List<EstimateInvoicesModel> EstinateInvoice;

  @override
  List<Object> get props => [EstinateInvoice];
}

class EstinateInvoiceError extends EstinateInvoiceState {
  final String errorMessage;
  const EstinateInvoiceError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class EstinateInvoicePaginated extends EstinateInvoiceState {
  final List<EstimateInvoicesModel> EstinateInvoice;
  final bool hasReachedMax;
  final EstimateInvoicesModel? selectedInvoice;

  const EstinateInvoicePaginated({
    required this.EstinateInvoice,
    required this.hasReachedMax,
    this.selectedInvoice,
  });

  EstinateInvoicePaginated copyWith({
    List<EstimateInvoicesModel>? EstinateInvoice,
    bool? hasReachedMax,
    EstimateInvoicesModel? selectedInvoice,
  }) {
    return EstinateInvoicePaginated(
      EstinateInvoice: EstinateInvoice ?? this.EstinateInvoice,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
    );
  }

  @override
  List<Object?> get props => [EstinateInvoice, hasReachedMax, selectedInvoice];
}

class EstinateInvoiceCreateError extends EstinateInvoiceState {
  final String errorMessage;

  const EstinateInvoiceCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class EstinateInvoiceEditError extends EstinateInvoiceState {
  final String errorMessage;

  const EstinateInvoiceEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class EstinateInvoiceDeleteError extends EstinateInvoiceState {
  final String errorMessage;

  const EstinateInvoiceDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class EstinateInvoiceEditSuccessLoading extends EstinateInvoiceState {}
class EstinateInvoiceCreateSuccessLoading extends EstinateInvoiceState {}
class EstinateInvoiceEditSuccess extends EstinateInvoiceState {
  const EstinateInvoiceEditSuccess();
  @override
  List<Object> get props => [];
}
class EstinateInvoiceCreateSuccess extends EstinateInvoiceState {
  const EstinateInvoiceCreateSuccess();
  @override
  List<Object> get props => [];
}
class EstinateInvoiceDeleteSuccess extends EstinateInvoiceState {
  const EstinateInvoiceDeleteSuccess();
  @override
  List<Object> get props => [];
}