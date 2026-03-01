import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/task_filter/task_filter_event.dart';

import 'package:taskify/bloc/task_filter/task_filter_state.dart';
class TaskFilterCountBloc extends Bloc<TaskFilterCountEvent, TaskFilterCountState> {
  TaskFilterCountBloc() : super(TaskFilterCountState.initial()) {
    on<UpdateFilterCount>(_onUpdateFilterCount);
    on<TaskResetFilterCount>(_onResetFilterCount);
  }

  void _onUpdateFilterCount(
      UpdateFilterCount event,
      Emitter<TaskFilterCountState> emit,
      ) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters[event.filterType.toLowerCase()] = event.isSelected;


    // Count how many filter types are active
    final newCount = updatedFilters.values.where((isActive) => isActive).length;


    emit(state.copyWith(
      activeFilters: updatedFilters,
      count: newCount,
    ));
  }

  void _onResetFilterCount(
      TaskResetFilterCount event,
      Emitter<TaskFilterCountState> emit,
      ) {
    // Create a new map with all filters set to false
    final resetFilters = {
      'clients': false,
      'users': false,
      'status': false,
      'priorities': false,
      'projects': false,
      'date': false,
    };

    emit(TaskFilterCountState(
      activeFilters: resetFilters,
      count: 0,
    ));
  }
}