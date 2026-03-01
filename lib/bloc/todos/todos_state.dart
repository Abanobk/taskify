import 'package:equatable/equatable.dart';
import '../../data/model/todos/todo_model.dart';


abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object?> get props => [];
}

class TodosInitial extends TodosState {}

class TodosLoading extends TodosState {}

class TodosSuccess extends TodosState {
  const TodosSuccess([this.todos=const []]);

  final List<TodosModel> todos;

  @override
  List<Object> get props => [todos];
}

class TodosError extends TodosState {
  final String errorMessage;
  const TodosError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TodosPaginated extends TodosState {
  final List<TodosModel> todos;
  final bool hasReachedMax;

  const TodosPaginated({
    required this.todos,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [todos, hasReachedMax];
}


class  TodosCreateError extends  TodosState {
  final String errorMessage;

   const TodosCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  TodosEditError extends  TodosState {
  final String errorMessage;

   const TodosEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  TodosEditSuccess extends  TodosState {
   const TodosEditSuccess();
  @override
  List<Object> get props => [];
}
class  TodosCreateSuccessLoading extends  TodosState {}
class  TodosEditSuccessLoading extends  TodosState {}
class  TodosCreateSuccess extends  TodosState {
   const TodosCreateSuccess();
  @override
  List<Object> get props => [];
}
class  TodosDeleteError extends  TodosState {
  final String errorMessage;

  const TodosDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  TodosDeleteSuccess extends  TodosState {
  const TodosDeleteSuccess();
  @override
  List<Object> get props => [];
}