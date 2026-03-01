import 'package:equatable/equatable.dart';
import '../../data/model/finance/expense_model.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseSuccess extends ExpenseState {
  const ExpenseSuccess([this.Expense=const []]);

  final List<ExpenseModel> Expense;

  @override
  List<Object> get props => [Expense];
}

class ExpenseError extends ExpenseState {
  final String errorMessage;
  const ExpenseError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpensePaginated extends ExpenseState {
  final List<ExpenseModel> Expense;
  final bool hasReachedMax;

  const ExpensePaginated({
    required this.Expense,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Expense, hasReachedMax];
}
class ExpenseCreateError extends ExpenseState {
  final String errorMessage;

  const ExpenseCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpenseEditError extends ExpenseState {
  final String errorMessage;

  const ExpenseEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpenseDeleteError extends ExpenseState {
  final String errorMessage;

  const ExpenseDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpenseEditSuccessLoading extends ExpenseState {}
class ExpenseCreateSuccessLoading extends ExpenseState {}
class ExpenseEditSuccess extends ExpenseState {
  const ExpenseEditSuccess();
  @override
  List<Object> get props => [];
}
class ExpenseCreateSuccess extends ExpenseState {
  const ExpenseCreateSuccess();
  @override
  List<Object> get props => [];
}
class ExpenseDeleteSuccess extends ExpenseState {
  const ExpenseDeleteSuccess();
  @override
  List<Object> get props => [];
}