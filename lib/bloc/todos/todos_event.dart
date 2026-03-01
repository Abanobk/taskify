import "package:equatable/equatable.dart";

import "../../data/model/todos/todo_model.dart";


abstract class TodosEvent extends Equatable{
 const TodosEvent();

 @override
 List<Object?> get props => [];
}
 class CreateTodos extends TodosEvent{
 final String title;
  final String desc;
  final String priority;
  final bool token;
 const CreateTodos({required this.desc,required this.token,required this.title,required this.priority});

 @override
 List<Object> get props => [title,desc,token];
}

class TodosList extends TodosEvent {

 const TodosList();

 @override
 List<Object?> get props => [];
}
class AddTodos extends TodosEvent {
 final TodosModel todos;

 const AddTodos(this.todos);

 @override
 List<Object?> get props => [todos];
}

class UpdateTodos extends TodosEvent {
 final TodosModel todos;

 const UpdateTodos(this.todos);

 @override
 List<Object?> get props => [todos];
}
class ReadStatusTodos extends TodosEvent {
 final int id;
 final int status;

 const ReadStatusTodos(this.id,this.status);

 @override
 List<Object?> get props => [id];
}
class DeleteTodos extends TodosEvent {
 final TodosModel todos;

 const DeleteTodos(this.todos );

 @override
 List<Object?> get props => [todos];
}
class SearchTodos extends TodosEvent {
 final String searchQuery;

 const SearchTodos(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreTodos extends TodosEvent {
 final String searchQuery;

 const LoadMoreTodos(this.searchQuery);

 @override
 List<Object?> get props => [];
}
