import 'package:equatable/equatable.dart';
import '../../data/model/finance/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  const PaymentSuccess([this.Payment=const []]);

  final List<PaymentModel> Payment;

  @override
  List<Object> get props => [Payment];
}

class PaymentError extends PaymentState {
  final String errorMessage;
  const PaymentError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentPaginated extends PaymentState {
  final List<PaymentModel> Payment;
  final bool hasReachedMax;

  const PaymentPaginated({
    required this.Payment,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Payment, hasReachedMax];
}
class PaymentCreateError extends PaymentState {
  final String errorMessage;

  const PaymentCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentEditError extends PaymentState {
  final String errorMessage;

  const PaymentEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentDeleteError extends PaymentState {
  final String errorMessage;

  const PaymentDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PaymentEditSuccessLoading extends PaymentState {}
class PaymentCreateSuccessLoading extends PaymentState {}
class PaymentEditSuccess extends PaymentState {
  const PaymentEditSuccess();
  @override
  List<Object> get props => [];
}
class PaymentCreateSuccess extends PaymentState {
  const PaymentCreateSuccess();
  @override
  List<Object> get props => [];
}
class PaymentDeleteSuccess extends PaymentState {
  const PaymentDeleteSuccess();
  @override
  List<Object> get props => [];
}