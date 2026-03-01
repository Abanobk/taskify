import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/payslip/payslip_model.dart';


abstract class PayslipState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PayslipInitial extends PayslipState {}
class PayslipLoading extends PayslipState {}
class PayslipSuccess extends PayslipState {
  PayslipSuccess(this.Payslip,);

  final List<PayslipModel> Payslip;

  @override
  List<Object> get props => [Payslip];
}
class AllPayslipSuccess extends PayslipState {
  AllPayslipSuccess(this.allPayslip,);

  final List<PayslipModel> allPayslip;

  @override
  List<Object> get props => [allPayslip];
}
class PayslipError extends PayslipState {
  final String errorMessage;

  PayslipError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PayslipPaginated extends PayslipState {
  final List<PayslipModel> Payslip;
  final bool hasReachedMax;

  PayslipPaginated({
    required this.Payslip,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Payslip, hasReachedMax];
}

class PayslipCreateError extends PayslipState {
  final String errorMessage;

  PayslipCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PayslipEditError extends PayslipState {
  final String errorMessage;

  PayslipEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PayslipFavPaginated extends PayslipState {
  final List<PayslipModel> Payslip;
  final bool hasReachedMax;


  PayslipFavPaginated({
    required this.Payslip,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Payslip, hasReachedMax];
}
class PayslipEditSuccessLoading extends PayslipState {}
class PayslipEditSuccess extends PayslipState {
  PayslipEditSuccess();
  @override
  List<Object> get props => [];
}
class PayslipCreateSuccessLoading extends PayslipState {}
class PayslipCreateSuccess extends PayslipState {
  PayslipCreateSuccess();
  @override
  List<Object> get props => [];
}
class PayslipDeleteError extends PayslipState {
  final String errorMessage;

  PayslipDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PayslipDeleteSuccess extends PayslipState {
  PayslipDeleteSuccess();
  @override
  List<Object> get props => [];
}