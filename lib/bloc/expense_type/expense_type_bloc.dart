import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/model/finance/expense_type_model.dart';
import '../../api_helper/api.dart';
import '../../data/repositories/expense/expense_type.dart';
import '../../utils/widgets/toast_widget.dart';
import 'expense_type_event.dart';
import 'expense_type_state.dart';

class ExpenseTypeBloc extends Bloc<ExpenseTypeEvent, ExpenseTypeState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  ExpenseTypeBloc() : super(ExpenseTypeInitial()) {
    on<ExpenseTypeLists>(_getExpenseList);
    on<SelectedExpenseType>(_onSelectExpense);
    on<ExpenseTypeLoadMore>(_onLoadMoreExpensees);
    on<SearchExpenseType>(_onSearchExpense);
    on<CreateExpenseType>(_onCreateExpense);
    on<UpdateExpenseType>(_onUpdateExpense);
    on<DeleteExpenseType>(_onDeleteExpense);
  }
  void _onDeleteExpense(DeleteExpenseType event, Emitter<ExpenseTypeState> emit) async {
    // if (emit is NotesSuccess) {
    final Expense = event.ExpenseTypeId;

    try {
      Map<String, dynamic> result = await ExpenseTypeRepo().deleteExpenseType(
        id: Expense,
        token: true,
      );
      if (result['data']['error'] == false) {

        emit(ExpenseTypeDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ExpenseTypeDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(ExpenseTypeError(e.toString()));
    }
    // }
  }
  void _onUpdateExpense(UpdateExpenseType event, Emitter<ExpenseTypeState> emit) async {
    if (state is ExpenseTypeSuccess) {
      final id = event.id;
      final title = event.title;
      final desc = event.desc;


      emit(ExpenseTypeEditLoading());

      try {
        Map<String, dynamic> updatedProject = await ExpenseTypeRepo().updateExpenseType(
            id: id,
            title: title,
            desc: desc,

        );
        if (updatedProject['error'] == false) {
          emit(ExpenseTypeEditSuccess());

        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);

          emit(ExpenseTypeEditError(updatedProject['message']));
        }

      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }
  Future<void> _onCreateExpense(
      CreateExpenseType event, Emitter<ExpenseTypeState> emit) async {
    try {

      emit(ExpenseTypeCreateLoading());
      var result = await ExpenseTypeRepo().createExpenseType(
        title: event.title,
        desc: event.desc,
      );
      if (result['error'] == false) {
        emit(ExpenseTypeCreateSuccess());
      }
      if (result['error'] == true) {
        emit(ExpenseTypeCreateError(result['message']));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ExpenseTypeError("Error: $e")));
    }
  }
  Future<void> _onSearchExpense(
      SearchExpenseType event, Emitter<ExpenseTypeState> emit) async {
    try {
      List<ExpenseTypeModel> Expensees = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await  ExpenseTypeRepo().getExpenseType(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          token: true);
      Expensees = List<ExpenseTypeModel>.from(
          result['data'].map((projectData) => ExpenseTypeModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =Expensees.length >= result['total'];
      if (result['error'] == false) {
        emit(ExpenseTypeSuccess(Expensees, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(ExpenseTypeError(result['message']));
      }
    } on ApiException catch (e) {
      emit(ExpenseTypeError("Error: $e"));
    }
  }
  Future<void> _getExpenseList(
      ExpenseTypeLists event, Emitter<ExpenseTypeState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<ExpenseTypeModel> priorities = [];
emit(ExpenseTypeLoading());
      Map<String, dynamic> result = await ExpenseTypeRepo().getExpenseType(
        token: true,
        offset: _offset,
        limit: _limit,
      );

      priorities = List<ExpenseTypeModel>.from(
          result['data'].map((projectData) => ExpenseTypeModel.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];

      if (result['error'] == false) {
        emit(ExpenseTypeSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(ExpenseTypeError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(ExpenseTypeError("Error: $e"));
    }
  }


  Future<void> _onLoadMoreExpensees(
      ExpenseTypeLoadMore event, Emitter<ExpenseTypeState> emit) async {
    if (state is ExpenseTypeSuccess && !_isFetching) {
      final currentState = state as ExpenseTypeSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;


      try {
        // Fetch more Expensees from the repository
        Map<String, dynamic> result = await ExpenseTypeRepo().getExpenseType(
            limit: _limit, offset: _offset, search: event.searchQuery, token: true);

        // Convert the fetched data into a list of Expensees
        List<ExpenseTypeModel> moreExpensees = List<ExpenseTypeModel>.from(
            result['data'].map((projectData) => ExpenseTypeModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreExpensees.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of Expensees
        bool hasReachedMax = (currentState.ExpenseType.length + moreExpensees.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of Expensees
          emit(ExpenseTypeSuccess(
            [...currentState.ExpenseType, ...moreExpensees],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(ExpenseTypeError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(ExpenseTypeError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(ExpenseTypeError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectExpense(SelectedExpenseType event, Emitter<ExpenseTypeState> emit) {
    if (state is ExpenseTypeSuccess) {
      final currentState = state as ExpenseTypeSuccess;
      emit(ExpenseTypeSuccess(currentState.ExpenseType, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
