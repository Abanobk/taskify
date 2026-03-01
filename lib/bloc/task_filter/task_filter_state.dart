class TaskFilterCountState {
  final int count;
  final Map<String, bool> activeFilters;

  TaskFilterCountState({
    required this.count,
    required this.activeFilters,
  });

  factory TaskFilterCountState.initial() {
    return TaskFilterCountState(
      count: 0,
      activeFilters: {
        'clients': false,
        'users': false,
        'status': false,
        'priorities': false,
        'projects': false,
        'date': false,
      },
    );
  }

  TaskFilterCountState copyWith({
    int? count,
    Map<String, bool>? activeFilters,
  }) {
    return TaskFilterCountState(
      count: count ?? this.count,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}