import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/model/todos/todo_model.dart';
import '../../data/repositories/todo/todo_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'todos_event.dart';
import 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  TodosBloc() : super(TodosInitial()) {
    on<CreateTodos>(_onTodosCreate);
    on<TodosList>(_getListOfTodos);
    on<AddTodos>(_onAddTodo);
    on<UpdateTodos>(_onUpdateTodo);
    on<DeleteTodos>(_onDeleteTodo);
    on<SearchTodos>(_onSearchTodos);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<ReadStatusTodos>(_onReadStatusTodos);


  }

  Future<void> _onTodosCreate(CreateTodos event, Emitter<TodosState> emit) async {
    try {
      emit(TodosLoading());
      // List<TodosModel> Todos = [];
      Map<String, dynamic> result = await TodosRepo.createTodo(
          token: true,
          title: event.title,
          desc: event.desc,
          priority: event.priority);
      //
      // Todos = List<TodosModel>.from(result['data']
      //     .map((projectData) => TodosModel.fromJson(projectData)));

      if (result['error'] == false) {
        emit(const TodosCreateSuccess());
      }
      if (result['error'] == true) {
        emit((TodosCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(TodosError("Error: $e"));
    }
  }

  Future<void> _getListOfTodos(
      TodosList event, Emitter<TodosState> emit) async {
    if (_isLoading) return; // Avoid multiple calls
    _isLoading = true;
print("gvbhnjmk,");
    try {
      _offset = 0;
      _hasReachedMax = false;
      emit(TodosLoading());
      List<TodosModel> notification = [];
      Map<String,dynamic> result = await TodosRepo()
          .todoList(limit: _limit, offset: _offset, search: '');
      notification = List<TodosModel>.from(result['data']
          .map((projectData) => TodosModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = notification.length >= result['total'];
      if (result['error'] == false) {
        emit(TodosPaginated(todos: notification, hasReachedMax: _hasReachedMax));
      } else {
        emit(TodosError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(TodosError("Error: $e"));
    } finally {
      _isLoading = false;
    }
  }
  Future<void> _onReadStatusTodos(
      ReadStatusTodos event, Emitter<TodosState> emit) async {

    if (_isLoading) return; // Avoid multiple calls
    _isLoading = true;

    try {
      // emit(TodosLoading());

      // Call the API to update the todo status
      Map<String, dynamic> result = await TodosRepo().todoStatus(
        status: event.status,
        id: event.id,
      );

      if (result['data']['error'] == false) {

        // add(const TodosList());
        // Emit success state with updated todo list

      } else {
        emit(TodosError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(TodosError("Error: $e"));
    } finally {
      _isLoading = false;
    }
  }


  Future<void> _onAddTodo(AddTodos event, Emitter<TodosState> emit) async {
    if (state is TodosPaginated) {

      // final currentState = state as TodosPaginated;

      final todo = event.todos;
      final title = todo.title;
      final desc = todo.description;
      final priority = todo.priority;

      // final updatedTodos = List<TodosModel>.from(currentState.Todos)..add(todo);

      try {
        // List<TodosModel> Todos = [];
emit(TodosCreateSuccessLoading());
        Map<String, dynamic> result = await TodosRepo.createTodo(
          title: title!,
          desc: desc!,
          priority: priority!,
          token: true,
        );
        // Todos = List<TodosModel>.from(result['data']
        //     .map((projectData) => TodosModel.fromJson(projectData)));
        if (result['error'] == false) {
          emit(const TodosCreateSuccess());
          add(const TodosList());
        }
        if (result['error'] == true) {
          emit((TodosCreateError(result['message'])));
          add(const TodosList());
          flutterToastCustom(msg: result['message']);
        }
        // emit(TodosSuccess(updatedTodos + newTodos));
      } catch (e) {
        print('Error while creating todo: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onUpdateTodo(UpdateTodos event, Emitter<TodosState> emit) async {
    // if (state is TodosPaginated) {
    try {
      // final currentState = state as TodosPaginated;

      final todo = event.todos;
      final id = todo.id;
      final title = todo.title;
      final desc = todo.description;
      final priority = todo.priority;
      emit(TodosEditSuccessLoading());
      Map<String, dynamic> result = await TodosRepo().updateTodo(
        id: id!,
        title: title!,
        desc: desc!,
        token: true,
        priority: priority!,
      ); // Cast to TodosModel
      if (result['error'] == false) {
        emit(const TodosEditSuccess());
        add(TodosList());
      }
      if (result['error'] == true) {
        emit((TodosEditError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      print('Error while updating todo: $e');
      // Optionally, handle the error state
    }
    // }
  }

  void _onDeleteTodo(DeleteTodos event, Emitter<TodosState> emit) async {
    // if (emit is TodosSuccess) {
    final todo = event.todos;
    try {
      Map<String, dynamic> result = await TodosRepo().deleteTodo(
        id: todo.id!.toString(),
        token: true,
      );

      if (result['data']['error'] == false) {
        emit(const TodosDeleteSuccess());
        // add(TodosList());
      }
      if (result['data']['error'] == true) {
        emit((TodosError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
      add(const TodosList());
      // emit(TodosPaginated(Todos:Todos,hasReachedMax: _hasReachedMax));
    } catch (e) {


      emit(TodosError(e.toString()));
      add(const TodosList());
    }
    // }
  }

  Future<void> _onSearchTodos(
      SearchTodos event, Emitter<TodosState> emit) async {
    try {
      emit(TodosLoading());
      List<TodosModel> todos = [];
      Map<String, dynamic> result = await TodosRepo()
          .todoList(limit: _limit, offset: 0, search: event.searchQuery);
      todos = List<TodosModel>.from(result['data']
          .map((projectData) => TodosModel.fromJson(projectData)));
      bool hasReachedMax = todos.length < _limit;
      if (result['error'] == false) {
        emit(TodosPaginated(todos: todos, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TodosError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(TodosError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreTodos(
      LoadMoreTodos event, Emitter<TodosState> emit) async {
    if (state is TodosPaginated && !_hasReachedMax) {
      try {
        final currentState = state as TodosPaginated;
        final updatedTodos = List<TodosModel>.from(currentState.todos);

        // Call API to fetch additional todos
        Map<String, dynamic> result = await TodosRepo()
            .todoList(limit: _limit, offset: _offset, search:event.searchQuery);

        if (result['error'] == true) {
          emit(TodosError(result['message']));
          flutterToastCustom(msg: result['message']);
          return;
        }

        List<TodosModel> todo = List<TodosModel>.from(
            result['data'].map((todoData) => TodosModel.fromJson(todoData)));

        // Update offset for the next call
        _offset += todo.length; // Offset increases by the fetched amount

        // Add newly fetched todos to the existing list
        updatedTodos.addAll(todo);

        // Check if all items have been loaded
        _hasReachedMax = updatedTodos.length >= result['total'];
        emit(TodosPaginated(todos: updatedTodos, hasReachedMax: _hasReachedMax));

      } on ApiException catch (e) {
        emit(TodosError("Error: $e"));
      }
    }
  }

}
