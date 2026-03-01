import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/project_discussion/project_milestone_filter/project_milestone_filter_event.dart';
import 'package:taskify/bloc/project_discussion/project_milestone_filter/project_milestone_filter_state.dart';

class FilterCountOfMilestoneBloc extends Bloc<FilterCountOfMilestoneEvent, FilterCountStateOfMilestone> {
  FilterCountOfMilestoneBloc() : super(FilterCountStateOfMilestone.initial()) {
    on<ProjectUpdateFilterCountOfMileStone>(_onUpdateFilterCountOfMilestone);
    on<ProjectResetFilterCountOfMilestone>(_onResetFilterCountOfMilestone);
  }

  void _onUpdateFilterCountOfMilestone(
      ProjectUpdateFilterCountOfMileStone event,
      Emitter<FilterCountStateOfMilestone> emit,
      ) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters[event.filterType.toLowerCase()] = event.isSelected;

    print("jfhjk ${event.isSelected}");
    print("jfhjk ${event.filterType}");

    // Count how many filter types are active
    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      activeFilters: updatedFilters,
      count: newCount,
    ));
  }

  void _onResetFilterCountOfMilestone(
      ProjectResetFilterCountOfMilestone event,
      Emitter<FilterCountStateOfMilestone> emit,
      ) {
    // Create a new map with all filters set to false
    final resetFilters = {
      'dateBetweenStart': false,
      // 'dateBetweenEnd': false,
      'startDateBetweenStart': false,
      // 'startDateBetweenEnd': false,
      'endDateBetweenStart': false,
      // 'endDateBetweenEnd': false,
      'status': false,
    };

    emit(FilterCountStateOfMilestone(
      activeFilters: resetFilters,
      count: 0,
    ));
  }
}