abstract class TaskFilterCountEvent {}

class UpdateFilterCount extends TaskFilterCountEvent {
  final String filterType;
  final bool isSelected;

  UpdateFilterCount({required this.filterType, required this.isSelected});
}

class TaskResetFilterCount extends TaskFilterCountEvent {}

// filter_count_state.dart

