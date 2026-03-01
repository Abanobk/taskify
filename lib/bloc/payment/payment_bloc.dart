import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../api_helper/api.dart';
import '../../data/model/finance/payment_model.dart';
import '../../data/repositories/Payment/Payment_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentsEvent, PaymentState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  PaymentBloc() : super(PaymentInitial()) {
    on<PaymentLists>(_onListOfPayment);
    on<AddPayments>(_onAddPayment);
    on<PaymentUpdateds>(_onUpdatePayment);
    on<DeletePayments>(_onDeletePayment);
    on<SearchPayments>(_onSearchPayment);
    on<LoadMorePayments>(_onLoadMorePayment);
  }

  Future<void> _onListOfPayment(
      PaymentLists event, Emitter<PaymentState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(PaymentLoading());
      List<PaymentModel> Payment = [];
      Map<String, dynamic> result = await PaymentRepo()
          .paymentList(limit: _limit, offset: _offset, search: '',userIds:event.userIds ,
          invoiceIds: event.invoiceIds,
          paymentMethodIds: event.paymentMethodIds,fromDate: event.fromDate,toDate: event.toDate);
      Payment = List<PaymentModel>.from(result['data']
          .map((projectData) => PaymentModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = Payment.length >= result['total'];
      if (result['error'] == false) {
        emit(PaymentPaginated(Payment: Payment, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((PaymentError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(PaymentError("Error: $e"));
    }
  }

  Future<void> _onAddPayment(
      AddPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentCreateSuccessLoading());
    var Payment = event.Payment;
    try {
      Map<String, dynamic> result = await PaymentRepo().createPayment(
          userId: Payment.userId??0,
          invoice: Payment.invoice??"",
          invoiceId: Payment.invoiceId??0,
          paymentMethodId: Payment.paymentMethodId??0,
          paymentMethod: Payment.paymentMethod??"",
          amount: Payment.amount??"",
          paymentDate: Payment.paymentDate??"",
          note: Payment.note??"",
         );

      if (result['error'] == false) {
        emit(const PaymentCreateSuccess());
        ;
      }
      if (result['error'] == true) {
        emit((PaymentCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      print('Error while creating Payment: $e');
    }
  }

  void _onUpdatePayment(
      PaymentUpdateds event, Emitter<PaymentState> emit)
  async {
    if (state is PaymentPaginated) {
      emit(PaymentEditSuccessLoading());
      final Payment = event.Payment;
      debugPrint('Parameter: event = $event');
      debugPrint('Parameter: emit = $emit');
      debugPrint('Parameter: Payment.id = ${Payment.id}');
      debugPrint('Parameter: Payment.userId = ${Payment.userId}');
      debugPrint('Parameter: Payment.invoice = ${Payment.invoice}');
      debugPrint('Parameter: Payment.invoiceId = ${Payment.invoiceId}');
      debugPrint('Parameter: Payment.paymentMethodId = ${Payment.paymentMethodId}');
      debugPrint('Parameter: Payment.paymentMethod = ${Payment.paymentMethod}');
      debugPrint('Parameter: Payment.amount = ${Payment.amount}');
      debugPrint('Parameter: Payment.paymentDate = ${Payment.paymentDate}');
      debugPrint('Parameter: Payment.note = ${Payment.note}');

      try {
        // Assuming updatePayment returns a single PaymentModel
        Map<String, dynamic> result = await PaymentRepo().updatePayment(
            id: Payment.id!,
            userId: Payment.userId!,
            invoice: Payment.invoice!,
            invoiceId: Payment.invoiceId,
            paymentMethodId: Payment.paymentMethodId!,
            paymentMethod: Payment.paymentMethod!,
            amount: Payment.amount!,
            paymentDate: Payment.paymentDate!,
            note: Payment.note??"",
           ); // Cast to PaymentModel
        if (result['error'] == false) {
          emit(const PaymentEditSuccess());
          // add(const PaymentLists());
        }
        if (result['error'] == true) {
          emit((PaymentEditError(result['message'])));

          flutterToastCustom(msg: result['message']);
        }

        // emit(PaymentSuccess(PaymentWithUpdatedPayment));
      } catch (e) {
        print('Error while updating Payment: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeletePayment(
      DeletePayments event, Emitter<PaymentState> emit) async {
    // if (emit is PaymentSuccess) {
    final Payments = event.Payment;
    try {
      Map<String, dynamic> result = await PaymentRepo().deletePayment(
        id: Payments,
        token: true,
      );
      print("fhugi $result");
      print("fhugi ${result['data']['error']}");
      if (result['error'] == false) {
        emit(const PaymentDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((PaymentDeleteError(result['message'])));

        flutterToastCustom(msg: result['message']);
      }
      print("ioj gkhk $state");
    } catch (e) {
      emit(PaymentDeleteError(e.toString()));
    }
    // }
  }

  Future<void> _onSearchPayment(
      SearchPayments event, Emitter<PaymentState> emit) async {
    try {
      List<PaymentModel> Payment = [];
      _offset = 0;
      emit(PaymentLoading());

      Map<String, dynamic> result = await PaymentRepo().paymentList(
          limit: _limit, offset: _offset, search: event.searchQuery,userIds:event.userIds ,invoiceIds: event.invoiceIds,
          paymentMethodIds: event.paymentMethodIds,fromDate: event.fromDate,toDate: event.toDate);

      if (result['error'] == false) {
        Payment = List<PaymentModel>.from(result['data']
            .map((projectData) => PaymentModel.fromJson(projectData)));
        bool hasReachedMax = Payment.length >= result['total'];

        emit(PaymentPaginated(Payment: Payment, hasReachedMax: hasReachedMax));
      } else if (result['error'] == true) {
        emit(PaymentError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(PaymentError("Error: $e"));
    }
  }

  Future<void> _onLoadMorePayment(
      LoadMorePayments event, Emitter<PaymentState> emit) async {
    if (state is PaymentPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent concurrent API calls
      try {
        final currentState = state as PaymentPaginated;
        final updatedPayment = List<PaymentModel>.from(currentState.Payment);

        // Fetch additional Payments
        Map<String, dynamic> result = await PaymentRepo().paymentList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
            userIds:event.userIds ,invoiceIds: event.invoiceIds,
            paymentMethodIds: event.paymentMethodIds,fromDate: event.fromDate,toDate: event.toDate
        );

        final additionalPayment = List<PaymentModel>.from(result['data']
            .map((projectData) => PaymentModel.fromJson(projectData)));

        if (additionalPayment.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedPayment.addAll(additionalPayment);
        }

        // Determine if all data is loaded
        // _hasReachedMax = updatedPayment.length + additionalPayment.length >= result['total'];

        // Add the new data to the existing list
        // updatedPayment.addAll(additionalPayment);

        if (result['error'] == false) {
          emit(PaymentPaginated(
            Payment: updatedPayment,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(PaymentError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(PaymentError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag
      }
    }
  }
}
