import 'package:equatable/equatable.dart';

import '../../data/model/finance/payment_method_model.dart';


abstract class PaymentMethdState extends Equatable{
  @override
  List<Object?> get props => [];
}

class PaymentMethdInitial extends PaymentMethdState {}
class  PaymentMethdEditSuccessLoading extends  PaymentMethdState {}
class  PaymentMethdCreateSuccessLoading extends  PaymentMethdState {}
class PaymentMethdLoading extends PaymentMethdState {}
class PaymentMethdSuccess extends PaymentMethdState {
  PaymentMethdSuccess(this.PaymentMethd,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<PaymentMethodModel> PaymentMethd;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [PaymentMethd,selectedIndex!,selectedTitle,isLoadingMore];
}

class PaymentMethdError extends PaymentMethdState {
  final String errorMessage;
  PaymentMethdError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentMethdEditLoading extends PaymentMethdState {}
class PaymentMethdCreateLoading extends PaymentMethdState {}
class PaymentMethdCreateSuccess extends PaymentMethdState {}
class PaymentMethdDeleteSuccess extends PaymentMethdState {}

class PaymentMethdEditSuccess extends PaymentMethdState {

  PaymentMethdEditSuccess();
  @override
  List<Object> get props =>
      [];
}

class PaymentMethdCreateError extends PaymentMethdState {
  final String errorMessage;
  PaymentMethdCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentMethdEditError extends PaymentMethdState {
  final String errorMessage;
  PaymentMethdEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentMethdDeleteError extends PaymentMethdState {
  final String errorMessage;
  PaymentMethdDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
