abstract class FilterCountEvent {}

class ProjectUpdateFilterCount extends FilterCountEvent {
  final String filterType;
  final bool isSelected;

  ProjectUpdateFilterCount({required this.filterType, required this.isSelected});
}

class ProjectResetFilterCount extends FilterCountEvent {}

// filter_count_state.dart

