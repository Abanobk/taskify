class EstimateInvoiceFilterCountState {
  final int count;
  final Map<String, bool> activeFilters;
  final List<int> selectedClientIds;
  final List<String> selectedTypeIds;
  final List<int> selectedUserCreatorIds;
  final List<int> selectedClientCreatorIds;
  final String fromDate;
  final String toDate;

  EstimateInvoiceFilterCountState({
    required this.count,
    required this.activeFilters,
    required this.selectedClientIds,
    required this.selectedTypeIds,
    required this.selectedUserCreatorIds,
    required this.selectedClientCreatorIds,
    required this.fromDate,
    required this.toDate,
  });

  factory EstimateInvoiceFilterCountState.initial() {
    return EstimateInvoiceFilterCountState(
      count: 0,
      activeFilters: {
        'clients': false,
        'type': false,
        'usercreator': false,
        'clientcreator': false,
        'date': false,
      },
      selectedClientIds: [],
      selectedTypeIds: [],
      selectedUserCreatorIds: [],
      selectedClientCreatorIds: [],
      fromDate: "",
      toDate: "",
    );
  }

  EstimateInvoiceFilterCountState copyWith({
    int? count,
    Map<String, bool>? activeFilters,
    List<int>? selectedClientIds,
    List<String>? selectedTypeIds,
    List<int>? selectedUserCreatorIds,
    List<int>? selectedClientCreatorIds,
    String? fromDate,
    String? toDate,
  }) {
    return EstimateInvoiceFilterCountState(
      count: count ?? this.count,
      activeFilters: activeFilters ?? this.activeFilters,
      selectedClientIds: selectedClientIds ?? this.selectedClientIds,
      selectedTypeIds: selectedTypeIds ?? this.selectedTypeIds,
      selectedUserCreatorIds: selectedUserCreatorIds ?? this.selectedUserCreatorIds,
      selectedClientCreatorIds: selectedClientCreatorIds ?? this.selectedClientCreatorIds,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
