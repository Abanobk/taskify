class PaymentFilterCountState {
  final int count;
  final Map<String, bool> activeFilters;

  final List<int> selectedUserIds;
  final List<int> selectedInvoiceIds;
  final List<int> selectedPaymentMethodIds;
  final String fromDate;
  final String toDate;

  PaymentFilterCountState({
    required this.count,
    required this.activeFilters,
    required this.selectedUserIds,
    required this.selectedInvoiceIds,
    required this.selectedPaymentMethodIds,
    required this.fromDate,
    required this.toDate,
  });

  factory PaymentFilterCountState.initial() {
    return PaymentFilterCountState(
      count: 0,
      activeFilters: {
        'users': false,
        'invoice': false,
        'paymentmethod': false,
        'date': false,
      },
      selectedUserIds: [],
      selectedInvoiceIds: [],
      selectedPaymentMethodIds: [],
      fromDate: "",
      toDate: "",
    );
  }

  PaymentFilterCountState copyWith({
    int? count,
    Map<String, bool>? activeFilters,
    List<int>? selectedUserIds,
    List<int>? selectedInvoiceIds,
    List<int>? selectedPaymentMethodIds,
    String? fromDate,
    String? toDate,
  }) {
    return PaymentFilterCountState(
      count: count ?? this.count,
      activeFilters: activeFilters ?? this.activeFilters,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      selectedInvoiceIds: selectedInvoiceIds ?? this.selectedInvoiceIds,
      selectedPaymentMethodIds: selectedPaymentMethodIds ?? this.selectedPaymentMethodIds,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
