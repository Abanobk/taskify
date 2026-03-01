import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../api_helper/api.dart';
import '../../data/model/finance/expense_model.dart';
import '../../data/repositories/expense/expense_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpensesEvent, ExpenseState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  ExpenseBloc() : super(ExpenseInitial()) {
    on<ExpenseLists>(_onListOfExpense);
    on<AddExpenses>(_onAddExpense);
    on<ExpenseUpdateds>(_onUpdateExpense);
    on<DeleteExpenses>(_onDeleteExpense);
    on<SearchExpenses>(_onSearchExpense);
    on<LoadMoreExpenses>(_onLoadMoreExpense);
  }

  Future<void> _onListOfExpense(
      ExpenseLists event, Emitter<ExpenseState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ExpenseLoading());
      List<ExpenseModel> Expense = [];
      Map<String, dynamic> result = await ExpenseRepo()
          .ExpenseList(limit: _limit, offset: _offset, search: '',userId:event.userId, type: event.type, toDate: event.dateFrom,
          fromDate:event.dateFrom);
      Expense = List<ExpenseModel>.from(result['data']
          .map((projectData) => ExpenseModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = Expense.length >= result['total'];
      if (result['error'] == false) {
        emit(ExpensePaginated(Expense: Expense, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ExpenseError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ExpenseError("Error: $e"));
    }
  }



  Future<void> _onAddExpense(
      AddExpenses event, Emitter<ExpenseState> emit) async {

    emit(ExpenseCreateSuccessLoading());
    var Expense = event.Expense;
    try {
      Map<String, dynamic> result = await ExpenseRepo().createExpense(
        title: Expense.title!,
        expenseTypeId: Expense.expenseTypeId!,
        amount: Expense.amount!,
        expenseDate: Expense.expenseDate!,
        userId: Expense.userId!,
        note: Expense.note!,

      );

      if (result['error'] == false) {
        emit(const ExpenseCreateSuccess());;
      }
      if (result['error'] == true) {
        emit((ExpenseCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      print('Error while creating Expense: $e');
    }
  }

  void _onUpdateExpense(
      ExpenseUpdateds event, Emitter<ExpenseState> emit) async {
    if (state is ExpensePaginated) {

  emit(ExpenseEditSuccessLoading());
      final Expenses = event.Expense;
      final id = Expenses.id;
      final title = Expenses.title;
      final type = Expenses.expenseTypeId;
      final amount = Expenses.amount;
      final expenseDate = Expenses.expenseDate;
      final userId = Expenses.userId;
      final note = Expenses.note;

      try {
        // Assuming updateExpense returns a single ExpenseModel
        Map<String, dynamic> result = await ExpenseRepo().updateExpense(
          id: id!,
          title: title!,
          expenseTypeId: type!,
          amount: amount!,
          expenseDate: expenseDate!,
          userId:userId!,
          note: note!,
        ); // Cast to ExpenseModel
        if (result['error'] == false) {
          emit(const ExpenseEditSuccess());
          // add(const ExpenseLists());

        }
        if (result['error'] == true) {
          emit((ExpenseEditError(result['message'])));

          flutterToastCustom(msg: result['message']);


        }

        // emit(ExpenseSuccess(ExpenseWithUpdatedExpense));
      } catch (e) {
        print('Error while updating Expense: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteExpense(
      DeleteExpenses event, Emitter<ExpenseState> emit) async {
    // if (emit is ExpenseSuccess) {
    final Expenses = event.Expense;
    try {
      Map<String, dynamic> result = await ExpenseRepo().deleteExpense(
        id: Expenses,
        token: true,
      );
      print("fhugi $result");
      print("fhugi ${result['data']['error']}");
      if (result['error'] == false) {
        emit(const ExpenseDeleteSuccess());

      }
      if (result['data']['error'] == true) {
        emit((ExpenseDeleteError(result['data']['message'])));

        flutterToastCustom(msg: result['datat']['message']);
      }
      print("ioj gkhk $state");
    } catch (e) {
      emit(ExpenseDeleteError(e.toString()));
    }
    // }
  }

  Future<void> _onSearchExpense(
      SearchExpenses event, Emitter<ExpenseState> emit) async {
    try {
      List<ExpenseModel> Expense = [];
      _offset = 0;
      emit(ExpenseLoading());

      Map<String, dynamic> result = await ExpenseRepo().ExpenseList(limit: _limit, offset: _offset,
          search: event.searchQuery, userId: event.userId, type: event.type, toDate: event.dateTo, fromDate: event.dateFrom);


      if (result['error'] == false) {
        Expense = List<ExpenseModel>.from(result['data'].map((projectData) => ExpenseModel.fromJson(projectData)));
        bool hasReachedMax = Expense.length >=  result['total'];

        emit(ExpensePaginated(Expense: Expense, hasReachedMax: hasReachedMax));
      } else if (result['error'] == true) {
        emit(ExpenseError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ExpenseError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreExpense(
      LoadMoreExpenses event, Emitter<ExpenseState> emit) async {
    if (state is ExpensePaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent concurrent API calls
      try {
        final currentState = state as ExpensePaginated;
        final updatedExpense = List<ExpenseModel>.from(currentState.Expense);

        // Fetch additional Expenses
        Map<String, dynamic> result = await ExpenseRepo().ExpenseList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
            userId: event.userId, type: event.type, toDate: event.dateTo, fromDate: event.dateFrom
        );

        final additionalExpense = List<ExpenseModel>.from(result['data']
            .map((projectData) => ExpenseModel.fromJson(projectData)));

        if (additionalExpense.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedExpense.addAll(additionalExpense);
        }

        // Determine if all data is loaded
        // _hasReachedMax = updatedExpense.length + additionalExpense.length >= result['total'];

        // Add the new data to the existing list
        // updatedExpense.addAll(additionalExpense);

        if (result['error'] == false) {
          emit(ExpensePaginated(
            Expense: updatedExpense,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(ExpenseError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ExpenseError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag
      }
    }
  }
}
