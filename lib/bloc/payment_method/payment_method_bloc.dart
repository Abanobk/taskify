import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/repositories/payment.dart';
import '../../api_helper/api.dart';
import '../../data/model/finance/payment_method_model.dart';
import '../../utils/widgets/toast_widget.dart';
import 'payment_method_event.dart';
import 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethdEvent, PaymentMethdState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  PaymentMethodBloc() : super(PaymentMethdInitial()) {
    on<PaymentMethdLists>(_getExpenseList);
    on<SelectedPaymentMethd>(_onSelectExpense);
    on<PaymentMethdLoadMore>(_onLoadMoreExpensees);
    on<SearchPaymentMethd>(_onSearchExpense);
    on<CreatePaymentMethd>(_onCreateExpense);
    on<UpdatePaymentMethd>(_onUpdateExpense);
    on<DeletePaymentMethd>(_onDeleteExpense);
  }
  void _onDeleteExpense(
      DeletePaymentMethd event, Emitter<PaymentMethdState> emit) async {
    // if (emit is NotesSuccess) {
    final Expense = event.PaymentMethdId;

    try {
      Map<String, dynamic> result =
          await PaymentMethodRepo().deletePaymentMethod(
        id: Expense,
        token: true,
      );
      print("tgyhuij ${result['error']}");
      print("tgyhuij ${result['error']}");
      if (result['error'] == false) {
        emit(PaymentMethdDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((PaymentMethdDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(PaymentMethdError(e.toString()));
    }
    // }
  }

  void _onUpdateExpense(
      UpdatePaymentMethd event, Emitter<PaymentMethdState> emit) async {
    if (state is PaymentMethdSuccess) {
      final id = event.id;
      final title = event.title;

      emit(PaymentMethdEditLoading());

      try {
        Map<String, dynamic> updatedProject =
            await PaymentMethodRepo().updatePaymentMethod(
          id: id,
          title: title,
        );
        if (updatedProject['error'] == false) {
          emit(PaymentMethdEditSuccess());
        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);

          emit(PaymentMethdEditError(updatedProject['message']));
        }
      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }

  Future<void> _onCreateExpense(
      CreatePaymentMethd event, Emitter<PaymentMethdState> emit) async {
    try {
      emit(PaymentMethdCreateLoading());
      var result = await PaymentMethodRepo().createPaymentMethod(
        title: event.title,
      );
      if (result['error'] == false) {
        emit(PaymentMethdCreateSuccess());
      }
      if (result['error'] == true) {
        emit(PaymentMethdCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PaymentMethdError("Error: $e")));
    }
  }

  Future<void> _onSearchExpense(
      SearchPaymentMethd event, Emitter<PaymentMethdState> emit) async {
    try {
      List<PaymentMethodModel> payment = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result =
          await PaymentMethodRepo().paymentPaymentMethodList(
        limit: _limit,
        offset: _offset,
        search: event.searchQuery,
      );
      payment = List<PaymentMethodModel>.from(result['data']
          .map((projectData) => PaymentMethodModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax = payment.length >= result['total'];
      if (result['error'] == false) {
        emit(PaymentMethdSuccess(payment, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(PaymentMethdError(result['message']));
      }
    } on ApiException catch (e) {
      emit(PaymentMethdError("Error: $e"));
    }
  }

  Future<void> _getExpenseList(
      PaymentMethdLists event, Emitter<PaymentMethdState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<PaymentMethodModel> priorities = [];
      emit(PaymentMethdLoading());
      Map<String, dynamic> result =
          await PaymentMethodRepo().paymentPaymentMethodList(
        offset: _offset,
        limit: _limit,
      );

      priorities = List<PaymentMethodModel>.from(result['data']
          .map((projectData) => PaymentMethodModel.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];
      print("eglsrb z${priorities.length}");
      print("eglsrb z${_hasReachedMax}");
      if (result['error'] == false) {
        emit(PaymentMethdSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(PaymentMethdError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(PaymentMethdError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreExpensees(
      PaymentMethdLoadMore event, Emitter<PaymentMethdState> emit) async {
    if (state is PaymentMethdSuccess && !_isFetching) {
      final currentState = state as PaymentMethdSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;

      try {
        // Fetch more Expensees from the repository
        Map<String, dynamic> result =
            await PaymentMethodRepo().paymentPaymentMethodList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        // Convert the fetched data into a list of Expensees
        List<PaymentMethodModel> moreExpensees = List<PaymentMethodModel>.from(
            result['data'].map(
                (projectData) => PaymentMethodModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreExpensees.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of Expensees
        bool hasReachedMax =
            (currentState.PaymentMethd.length + moreExpensees.length) >=
                result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of Expensees
          emit(PaymentMethdSuccess(
            [...currentState.PaymentMethd, ...moreExpensees],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(PaymentMethdError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(PaymentMethdError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(PaymentMethdError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }

  void _onSelectExpense(
      SelectedPaymentMethd event, Emitter<PaymentMethdState> emit) {
    if (state is PaymentMethdSuccess) {
      final currentState = state as PaymentMethdSuccess;
      emit(PaymentMethdSuccess(currentState.PaymentMethd, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
