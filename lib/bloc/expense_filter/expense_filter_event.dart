abstract class ExpenseFilterCountEvent {}

class ExpenseUpdateFilterCount extends ExpenseFilterCountEvent {
  final String filterType;
  final bool isSelected;

  ExpenseUpdateFilterCount({required this.filterType, required this.isSelected});
}

class ExpenseResetFilterCount extends ExpenseFilterCountEvent {}
class SetUserIds extends ExpenseFilterCountEvent {
  final List<int> userIds;

  SetUserIds({List<int>? userIds})
      : userIds = userIds ?? [];
}

class SetTypeIds extends ExpenseFilterCountEvent {
  final List<int> typeIds;

  SetTypeIds({List<int>? typeIds})
      : typeIds = typeIds ?? [];
}

class SetDate extends ExpenseFilterCountEvent {
  final String toDate;
  final String fromDate;

  SetDate({this.toDate="",this.fromDate=""});
}



// filter_count_state.dart

