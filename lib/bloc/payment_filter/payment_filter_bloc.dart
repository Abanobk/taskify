import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/payment_filter/payment_filter_event.dart';
import 'package:taskify/bloc/payment_filter/payment_filter_state.dart';




class PaymentFilterCountBloc extends Bloc<PaymentFilterCountEvent, PaymentFilterCountState> {
  PaymentFilterCountBloc() : super(PaymentFilterCountState.initial()) {
    on<PaymentUpdateFilterCount>(_onUpdateFilterCount);
    on<PaymentResetFilterCount>(_onResetFilterCount);
    on<SetPaymentUsers>(_onSetUsers);
    on<SetPaymentInvoices>(_onSetInvoices);
    on<SetPaymentMethods>(_onSetPaymentMethods);
    on<SetPaymentDate>(_onSetDate);
  }

  void _onUpdateFilterCount(
      PaymentUpdateFilterCount event,
      Emitter<PaymentFilterCountState> emit,
      ) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters[event.filterType.toLowerCase()] = event.isSelected;

    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      activeFilters: updatedFilters,
      count: newCount,
    ));
  }

  void _onResetFilterCount(
      PaymentResetFilterCount event,
      Emitter<PaymentFilterCountState> emit,
      ) {
    final resetFilters = {
      'users': false,
      'invoice': false,
      'Payment Method': false,
      'date': false,
    };

    emit(state.copyWith(
      activeFilters: resetFilters,
      count: 0,
      selectedUserIds: [],
      selectedInvoiceIds: [],
      selectedPaymentMethodIds: [],
      fromDate: "",
      toDate: "",
    ));
  }

  void _onSetUsers(SetPaymentUsers event, Emitter<PaymentFilterCountState> emit) {
    emit(state.copyWith(selectedUserIds: event.userIds));
    print("Selected user IDs: ${event.userIds}");
  }

  void _onSetInvoices(SetPaymentInvoices event, Emitter<PaymentFilterCountState> emit) {
    emit(state.copyWith(selectedInvoiceIds: event.invoiceIds));
    print("Selected invoice IDs: ${event.invoiceIds}");
  }

  void _onSetPaymentMethods(SetPaymentMethods event, Emitter<PaymentFilterCountState> emit) {
    emit(state.copyWith(selectedPaymentMethodIds: event.paymentMethodIds));
    print("Selected payment method IDs: ${event.paymentMethodIds}");
  }

  void _onSetDate(SetPaymentDate event, Emitter<PaymentFilterCountState> emit) {
    emit(state.copyWith(fromDate: event.fromDate, toDate: event.toDate));
    print("Date set from ${event.fromDate} to ${event.toDate}");
  }
}
