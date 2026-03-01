import 'package:equatable/equatable.dart';

import '../../data/model/finance/expense_type_model.dart';


abstract class ExpenseTypeState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ExpenseTypeInitial extends ExpenseTypeState {}
class  ExpenseTypeEditSuccessLoading extends  ExpenseTypeState {}
class  ExpenseTypeCreateSuccessLoading extends  ExpenseTypeState {}
class ExpenseTypeLoading extends ExpenseTypeState {}
class ExpenseTypeSuccess extends ExpenseTypeState {
  ExpenseTypeSuccess(this.ExpenseType,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<ExpenseTypeModel> ExpenseType;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [ExpenseType,selectedIndex!,selectedTitle,isLoadingMore];
}

class ExpenseTypeError extends ExpenseTypeState {
  final String errorMessage;
  ExpenseTypeError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpenseTypeEditLoading extends ExpenseTypeState {}
class ExpenseTypeCreateLoading extends ExpenseTypeState {}
class ExpenseTypeCreateSuccess extends ExpenseTypeState {}
class ExpenseTypeDeleteSuccess extends ExpenseTypeState {}

class ExpenseTypeEditSuccess extends ExpenseTypeState {

  ExpenseTypeEditSuccess();
  @override
  List<Object> get props =>
      [];
}

class ExpenseTypeCreateError extends ExpenseTypeState {
  final String errorMessage;
  ExpenseTypeCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpenseTypeEditError extends ExpenseTypeState {
  final String errorMessage;
  ExpenseTypeEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ExpenseTypeDeleteError extends ExpenseTypeState {
  final String errorMessage;
  ExpenseTypeDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
