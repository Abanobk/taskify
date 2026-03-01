abstract class FilterCountOfMilestoneEvent {}

class ProjectUpdateFilterCountOfMileStone extends FilterCountOfMilestoneEvent {
  final String filterType;
  final bool isSelected;

  ProjectUpdateFilterCountOfMileStone({required this.filterType, required this.isSelected});
}

class ProjectResetFilterCountOfMilestone extends FilterCountOfMilestoneEvent {}

// filter_count_state.dart

