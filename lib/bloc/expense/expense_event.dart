import "package:equatable/equatable.dart";
import "../../data/model/finance/expense_model.dart";

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();
  @override
  List<Object?> get props => [];
}

class CreateExpenses extends ExpensesEvent {
  final String title;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final List<int> userId;
  final List<int> clientIds;
  final String token;

  const CreateExpenses(
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

class ExpenseLists extends ExpensesEvent {
  final  List<int> type;
  final List<int> userId;
  final String dateFrom;
  final String dateTo;
  const ExpenseLists(this.type,this.userId,this.dateFrom,this.dateTo);

  @override
  List<Object?> get props => [];
}

class AddExpenses extends ExpensesEvent {
  final ExpenseModel Expense;

  const AddExpenses(this.Expense);

  @override
  List<Object?> get props => [Expense];
}

class ExpenseUpdateds extends ExpensesEvent {
  final ExpenseModel Expense;

  const ExpenseUpdateds(this.Expense);

  @override
  List<Object> get props => [Expense];

}

class DeleteExpenses extends ExpensesEvent {
  final int Expense;

  const DeleteExpenses(this.Expense);

  @override
  List<Object?> get props => [Expense];
}

class SearchExpenses extends ExpensesEvent {
  final String searchQuery;
  final String dateFrom;
  final String dateTo;
  final  List<int> type;
  final List<int> userId;

  const SearchExpenses(this.searchQuery,this.type,this.userId,this.dateFrom,this.dateTo);

  @override
  List<Object?> get props => [searchQuery];
}

class LoadMoreExpenses extends ExpensesEvent {
  final String searchQuery;
  final String dateFrom;
  final String dateTo;
  final  List<int> type;
  final List<int> userId;
  const LoadMoreExpenses(this.searchQuery,this.type,this.userId,this.dateFrom,this.dateTo);

  @override
  List<Object?> get props => [searchQuery];
}
