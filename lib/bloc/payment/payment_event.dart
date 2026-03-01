import "package:equatable/equatable.dart";
import "../../data/model/finance/payment_model.dart";

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();
  @override
  List<Object?> get props => [];
}

class CreatePayments extends PaymentsEvent {
  final String title;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final List<int> userId;
  final List<int> clientIds;
  final String token;

  const CreatePayments(
      {
        required  this.title,
        required this.startDate,
        required this.endDate,
        required this.startTime,
        required this.endTime,
        required this.userId,
        required this.clientIds,
        required this.token

      });

  @override
  List<Object> get props => [title,startDate,endDate,startTime,endTime,userId,clientIds,token];
}

class PaymentLists extends PaymentsEvent {
  final List<int> userIds;
  final List<int> invoiceIds;
  final List<int> paymentMethodIds;
  final String fromDate;
  final String toDate;

  const PaymentLists({
    required this.userIds,
    required this.invoiceIds,
    required this.paymentMethodIds,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
    userIds,
    invoiceIds,
    paymentMethodIds,
    fromDate,
    toDate,
  ];
}


class AddPayments extends PaymentsEvent {
  final PaymentModel Payment;

  const AddPayments(this.Payment);

  @override
  List<Object?> get props => [Payment];
}

class PaymentUpdateds extends PaymentsEvent {
  final PaymentModel Payment;

  const PaymentUpdateds(this.Payment);

  @override
  List<Object> get props => [Payment];

}

class DeletePayments extends PaymentsEvent {
  final int Payment;

  const DeletePayments(this.Payment);

  @override
  List<Object?> get props => [Payment];
}

class SearchPayments extends PaymentsEvent {
  final String searchQuery;

  final List<int> userIds;
  final List<int> invoiceIds;
  final List<int> paymentMethodIds;
  final String fromDate;
  final String toDate;

  const SearchPayments({
    required this.searchQuery,
    required this.userIds,
    required this.invoiceIds,
    required this.paymentMethodIds,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    userIds,
    invoiceIds,
    paymentMethodIds,
    fromDate,
    toDate,
  ];
}

class LoadMorePayments extends PaymentsEvent {
  final String searchQuery;
  final List<int> userIds;
  final List<int> invoiceIds;
  final List<int> paymentMethodIds;
  final String fromDate;
  final String toDate;

  const LoadMorePayments({
    required this.searchQuery,
    required this.userIds,
    required this.invoiceIds,
    required this.paymentMethodIds,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    userIds,
    invoiceIds,
    paymentMethodIds,
    fromDate,
    toDate,
  ];
}
