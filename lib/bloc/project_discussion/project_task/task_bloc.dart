import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/task/task_event.dart';
import 'package:taskify/bloc/task/task_state.dart';

import '../../../api_helper/api.dart';
import '../../../data/model/task/task_model.dart';
import '../../../data/repositories/Task/Task_repo.dart';
import '../../../utils/widgets/toast_widget.dart';


class TaskBloc extends Bloc<TaskEvent, TaskState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  TaskBloc() : super(TaskInitial()) {
    on<TaskCreated>(_onCreateTask);
    on<AllTaskList>(_getAllTask);
    on<AllTaskListOnTask>(_getAllTaskListOnProject);
    on<TodaysTaskList>(_onTodaysTask);
    on<UpdateTask>(_onUpdateTask);
    on<SearchTasks>(_onSearchTask);
    on<DeleteTask>(_onDeleteTasks);
    on<LoadMore>(_onLoadMoreTask);
    on<LoadMoreToday>(_onLoadMoreTodaysTask);
    on<TaskDashBoardFavList>(_getTaskFavLists);
  }
  Future<void> _onCreateTask(TaskCreated event, Emitter<TaskState> emit) async {
    try {
      emit(TaskCreateSuccessLoading());
print("fhuodfx ${event.recurringFrequencyType}");
      Map<String, dynamic> result = await TaskRepo().createTask(
        canClientDiscuss: event.canClientDiscuss,
        title: event.title,
        statusId: event.statusId,
        priorityId: event.priorityId,
        startDate: event.startDate,
        dueDate: event.dueDate,
        desc: event.desc,
        project: event.project,
        note: event.note,
        userId: event.userId,
        enableReminder: event.enableReminder,
        enableRecurringTask: event.enableRecurringTask,
        billingType: event.billingType,
        completionPercentage: event.completionPercentage,
        frequencyType: event.frequencyType,
        recurrenceFrequency: event.recurringFrequencyType,
        // Recurrence Fields
        dayOfWeek: event.dayOfWeek,
        dayOfMonth: event.dayOfMonth,
        timeOfDay: event.timeOfDay,
        recurrenceDayOfWeek: event.recurrenceDayOfWeek,
        recurrenceDayOfMonth: event.recurrenceDayOfMonth,
        recurrenceMonthOfYear: event.recurrenceMonthOfYear,
        recurrrenceStartsFrom: event.recurrenceStartsFrom,
        recurenceOccurences: event.recurrenceOccurrences, customFieldValues: event.customFieldValues,
      );

      if (result['error'] == false) {
        emit(TaskCreateSuccess());
        add(AllTaskList());
      }
      if (result['error'] == true) {
        emit(TaskCreateError(result['message']));
        add(AllTaskList());

        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _getTaskFavLists(
      TaskDashBoardFavList event, Emitter<TaskState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TaskLoading());
      List<Tasks> fav = [];
      Map<String, dynamic> result = await TaskRepo().getTasksFav(
        isFav: event.isFav,
        limit: _limit,
        offset: _offset,
        search: '',
      );
      fav = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = fav.length >= result['total'];

      if (result['error'] == false) {
        emit(TaskFavPaginated(
          task: fav,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _getAllTaskListOnProject(
      AllTaskListOnTask event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      Map<String, dynamic> result = {};
      emit(TaskLoading());
      print("njfvkml,c ${event.id}");
      _offset = 0;
      result = await TaskRepo().getTask(
          subtask: event.isSubtask,
          limit: _limit,
          offset: _offset,
          search: '',
          token: true,
          id: event.id,
          userId: event.userId,
          clientId: event.clientId,
          projectId: event.projectId,
          statusId: event.statusId,
          priorityId: event.priorityId,
          fromDate: event.fromDate,
          toDate: event.toDate);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = task.length < _limit;

      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: _hasReachedMax,isToday: false));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _onSearchTask(SearchTasks event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      emit(TaskLoading());
      _offset = 0;
      _hasReachedMax = false;

      Map<String, dynamic> result = await TaskRepo().getTask(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          token: true);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));
      bool hasReachedMax = task.length < _limit;
      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: hasReachedMax,isToday: false));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      emit(TaskError("Error: $e"));
    }
  }

  Future<void> _getAllTask(AllTaskList event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TaskLoading());
      Map<String, dynamic> result = await TaskRepo()
          .getTask(limit: _limit, offset: _offset, search: '', token: true);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = task.length < _limit;
      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: _hasReachedMax,isToday: false));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _onTodaysTask(
      TodaysTaskList event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TodaysTaskLoading());
      Map<String, dynamic> result = await TaskRepo().getTask(
          limit: _limit,
          offset: _offset,
          search: '',
          token: true,
          fromDate: event.fromDate,
          toDate: event.fromDate);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));
      _offset += _limit;

      _hasReachedMax = result['total'] < _limit;
      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: _hasReachedMax,isToday: true));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  void _onDeleteTasks(DeleteTask event, Emitter<TaskState> emit) async {
    final int note = event.taskId;
    try {
      Map<String, dynamic> result = await TaskRepo().getDeleteTask(
        id: note.toString(),
        token: true,
      );
      if (result['error'] == false) {
        emit(TaskDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((TaskDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskPaginated) {
      emit(TaskEditSuccessLoading());
print("bhnjkml, ${event.recurringFrequencyType}");
      try {
        Map<String, dynamic> result = await TaskRepo().updateTask(
          id: event.id,
          title: event.title,
          statusId: event.statusId,
          priorityId: event.priorityId,
          startDate: event.startDate,
          dueDate: event.dueDate,
          desc: event.desc,
          note: event.note,
          frequencyType: event.frequencyType,
          recurrenceFrequency: event.recurringFrequencyType,
          userId: event.userId,
          enableReminder: event.enableReminder,
          enableRecurringTask: event.enableRecurringTask,
          billingType: event.billingType,
          completionPercentage: event.completionPercentage,
          canClientDiscuss: event.canClientDiscuss,

          // Recurrence Fields
          dayOfWeek: event.dayOfWeek,
          dayOfMonth: event.dayOfMonth,
          timeOfDay: event.timeOfDay,
          recurrenceDayOfWeek: event.recurrenceDayOfWeek,
          recurrenceDayOfMonth: event.recurrenceDayOfMonth,
          recurrenceMonthOfYear: event.recurrenceMonthOfYear,
          recurrrenceStartsFrom: event.recurrenceStartsFrom,
          recurenceOccurences: event.recurrenceOccurrences,
          customFieldValues: event.customFieldValues,
        );

        if (result['error'] == false) {
          emit(TaskEditSuccess());
          add(AllTaskList());
        } else {
          emit(TaskEditError(result['message']));
          flutterToastCustom(msg: result['message']);
          add(AllTaskList());
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> _onLoadMoreTask(LoadMore event, Emitter<TaskState> emit) async {
    if (state is TaskPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Start loading
      try {
        final currentState = state as TaskPaginated;
        final updatedNotes = List<Tasks>.from(currentState.task);

        // Fetch additional tasks
        Map<String, dynamic> result = await TaskRepo().getTask(
            limit: _limit,
            offset: _offset,
            search: event.searchQuery,
            token: true,
            userId: event.userId,
            clientId: event.clientId,
            projectId: event.projectId,
            statusId: event.statusId,
            priorityId: event.priorityId,
            fromDate: event.fromDate,
            toDate: event.toDate,
            isFav: event.isFav);

        if (result['error'] == false) {
          final additionalNotes = List<Tasks>.from(
            result['data'].map((projectData) => Tasks.fromJson(projectData)),
          );

          // Increment the offset only if new items are fetched
          if (additionalNotes.isNotEmpty) {
            _offset += additionalNotes.length; // Update offset
          }
          if (updatedNotes.length >= result['total']) {
            _hasReachedMax = true;
          } else {
            _hasReachedMax = false;
          }

          updatedNotes.addAll(additionalNotes);
        } else if (result['error'] == true) {
          emit(TaskError(result['message']));
          flutterToastCustom(msg: result['message']);
        }

        emit(TaskPaginated(task: updatedNotes, hasReachedMax: _hasReachedMax,isToday: false));
      } on ApiException catch (e) {
        emit(TaskError("Error: $e"));
      } finally {
        _isLoading = false; // End loading
      }
    }
  }

  Future<void> _onLoadMoreTodaysTask(
      LoadMoreToday event, Emitter<TaskState> emit) async {
    if (state is TaskPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true;
      try {
        final currentState = state as TaskPaginated;
        final updatedTask = List<Tasks>.from(currentState.task);

        // Fetch additional tasks from the repository
        Map<String, dynamic> result = await TaskRepo().getTask(
          limit: _limit,
          offset: _offset, // Use the current offset
          search: '',
          token: true,
          fromDate: event.fromDate,
          toDate: event.toDate,
        );

        final additionalTask = List<Tasks>.from(
          result['data'].map((taskData) => Tasks.fromJson(taskData)),
        );

        // Update the offset only if the fetch is successful
        if (additionalTask.isNotEmpty) {
          _offset += additionalTask.length; // Increment by fetched items
        }

        // Check if the maximum number of items has been reached
        _hasReachedMax = additionalTask.length < _limit;

        updatedTask.addAll(additionalTask);

        if (result['error'] == false) {
          emit(TaskPaginated(task: updatedTask, hasReachedMax: _hasReachedMax,isToday: true));
        } else {
          emit(TaskError(result['message']));
        }
      } on ApiException catch (e) {
        emit(TaskError("Error: $e"));
      } finally {
        _isLoading = false; // End loading
      }
    }
  }
}
