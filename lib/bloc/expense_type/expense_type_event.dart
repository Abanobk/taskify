
import 'package:equatable/equatable.dart';

abstract class ExpenseTypeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseTypeLists extends ExpenseTypeEvent {

  // final int offset;
  // final int limit;

  ExpenseTypeLists();
  @override
  List<Object> get props => [];
}
class ExpenseTypeLoadMore extends ExpenseTypeEvent {
  final String searchQuery;

  ExpenseTypeLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedExpenseType extends ExpenseTypeEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedExpenseType(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchExpenseType extends ExpenseTypeEvent {
  final String searchQuery;


  SearchExpenseType(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreateExpenseType extends ExpenseTypeEvent {
  final String title;
  final String desc;


  CreateExpenseType(
      {required this.title,
        required this.desc,

     });
  @override
  List<Object> get props => [title, desc];
}

class DeleteExpenseType extends ExpenseTypeEvent {
  final int ExpenseTypeId;

  DeleteExpenseType(this.ExpenseTypeId );

  @override
  List<Object?> get props => [ExpenseTypeId];
}

class UpdateExpenseType extends ExpenseTypeEvent {
  final int id;
  final String title;
  final String desc;


  UpdateExpenseType(
      {
        required  this.id,
        required this.title,
        required this.desc,

      });
  @override
  List<Object> get props => [
    id,
    title,
    desc,

  ];
}
