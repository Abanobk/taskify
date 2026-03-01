class FilterCountState {
  final int count;
  final Map<String, bool> activeFilters;

  FilterCountState({
    required this.count,
    required this.activeFilters,
  });

  factory FilterCountState.initial() {
    return FilterCountState(
      count: 0,
      activeFilters: {
        'clients': false,
        'users': false,
        'status': false,
        'priorities': false,
        'tags': false,
        'date': false,
      },
    );
  }

  FilterCountState copyWith({
    int? count,
    Map<String, bool>? activeFilters,
  }) {
    return FilterCountState(
      count: count ?? this.count,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}