class FilterCountStateOfMilestone  {
  final int count;
  final Map<String, bool> activeFilters;

  FilterCountStateOfMilestone ({
    required this.count,
    required this.activeFilters,
  });

  factory FilterCountStateOfMilestone .initial() {
    return FilterCountStateOfMilestone (
      count: 0,
      activeFilters: {
        'statuses': false,
        'users': false,
        'status': false,
        'priorities': false,
        'tags': false,
        'date': false,
      },
    );
  }

  FilterCountStateOfMilestone  copyWith({
    int? count,
    Map<String, bool>? activeFilters,
  }) {
    return FilterCountStateOfMilestone (
      count: count ?? this.count,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}