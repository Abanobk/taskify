abstract class PaymentFilterCountEvent {}
class SetPaymentUsers extends PaymentFilterCountEvent {
  final List<int> userIds;

  SetPaymentUsers({required this.userIds});
}


class PaymentUpdateFilterCount extends PaymentFilterCountEvent {
  final String filterType;
  final bool isSelected;

  PaymentUpdateFilterCount({
    required this.filterType,
    required this.isSelected,
  });
}

class PaymentResetFilterCount extends PaymentFilterCountEvent {}


class SetPaymentInvoices extends PaymentFilterCountEvent {
  final List<int> invoiceIds;

  SetPaymentInvoices({required this.invoiceIds});
}

class SetPaymentMethods extends PaymentFilterCountEvent {
  final List<int> paymentMethodIds;

  SetPaymentMethods({required this.paymentMethodIds});
}

class SetPaymentDate extends PaymentFilterCountEvent {
  final String fromDate;
  final String toDate;

  SetPaymentDate({
    required this.fromDate,
    required this.toDate,
  });
}
