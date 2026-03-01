import 'package:equatable/equatable.dart';

class ExpenseFilterCountState extends Equatable {
  final int count;
  final Map<String, bool> activeFilters;
  final List<int> selectedUserIds;
  final List<int> selectedTypeIds;
  final String fromDate;
  final String toDate;

  ExpenseFilterCountState({
    required this.count,
    required this.activeFilters,
    List<int>? selectedUserIds,
    List<int>? selectedTypeIds,
    this.fromDate = "",
    this.toDate = "",
  })  : selectedUserIds = selectedUserIds ?? [],
        selectedTypeIds = selectedTypeIds ?? [];

  factory ExpenseFilterCountState.initial() {
    return ExpenseFilterCountState(
      count: 0,
      activeFilters: {
        'users': false,
        'type': false,
        'date': false,
      },
      selectedUserIds: [],
      selectedTypeIds: [],
      fromDate: "",
      toDate: "",
    );
  }

  ExpenseFilterCountState copyWith({
    int? count,
    Map<String, bool>? activeFilters,
    List<int>? selectedUserIds,
    List<int>? selectedTypeIds,
    String? fromDate,
    String? toDate,
  }) {
    return ExpenseFilterCountState(
      count: count ?? this.count,
      activeFilters: activeFilters ?? this.activeFilters,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      selectedTypeIds: selectedTypeIds ?? this.selectedTypeIds,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  @override
  List<Object> get props => [
    count,
    activeFilters,
    selectedUserIds,
    selectedTypeIds,
    fromDate,
    toDate,
  ];

  @override
  String toString() {
    return 'ExpenseFilterCountState(count: $count, filters: $activeFilters, users: $selectedUserIds, types: $selectedTypeIds, from: $fromDate, to: $toDate)';
  }
}