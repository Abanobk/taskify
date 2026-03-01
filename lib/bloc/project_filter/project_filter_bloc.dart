import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/project_filter/project_filter_event.dart';
import 'package:taskify/bloc/project_filter/project_filter_state.dart';
class FilterCountBloc extends Bloc<FilterCountEvent, FilterCountState> {
  FilterCountBloc() : super(FilterCountState.initial()) {
    on<ProjectUpdateFilterCount>(_onUpdateFilterCount);
    on<ProjectResetFilterCount>(_onResetFilterCount);
  }

  void _onUpdateFilterCount(
      ProjectUpdateFilterCount event,
      Emitter<FilterCountState> emit,
      ) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters[event.filterType.toLowerCase()] = event.isSelected;

    print("jfhjk ${event.isSelected}");

    // Count how many filter types are active
    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      activeFilters: updatedFilters,
      count: newCount,
    ));
  }

  void _onResetFilterCount(
      ProjectResetFilterCount event,
      Emitter<FilterCountState> emit,
      ) {
    // Create a new map with all filters set to false
    final resetFilters = {
      'clients': false,
      'users': false,
      'status': false,
      'priorities': false,
      'tags': false,
      'date': false,
    };

    emit(FilterCountState(
      activeFilters: resetFilters,
      count: 0,
    ));
  }
}