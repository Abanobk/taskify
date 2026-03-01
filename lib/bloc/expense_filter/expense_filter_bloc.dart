import 'package:bloc/bloc.dart';
import 'expense_filter_event.dart';
import 'expense_filter_state.dart';

class ExpenseFilterCountBloc extends Bloc<ExpenseFilterCountEvent, ExpenseFilterCountState> {
  ExpenseFilterCountBloc() : super(ExpenseFilterCountState.initial()) {
    on<ExpenseUpdateFilterCount>(_onUpdateFilterCount);
    on<ExpenseResetFilterCount>(_onResetFilterCount);
    on<SetUserIds>(_onSetUserIds);
    on<SetTypeIds>(_onSetTypeIds);
    on<SetDate>(_onSetDate);
  }

  void _onUpdateFilterCount(
      ExpenseUpdateFilterCount event,
      Emitter<ExpenseFilterCountState> emit,
      ) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters[event.filterType.toLowerCase()] = event.isSelected;
    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      activeFilters: updatedFilters,
      count: newCount,
    ));
    print("UpdateFilterCount: FilterType = ${event.filterType}, IsSelected = ${event.isSelected}, Count = $newCount");
  }

  void _onResetFilterCount(
      ExpenseResetFilterCount event,
      Emitter<ExpenseFilterCountState> emit,
      ) {
    emit(ExpenseFilterCountState.initial());
    print("Filters reset. Count: 0");
  }

  void _onSetUserIds(SetUserIds event, Emitter<ExpenseFilterCountState> emit) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    print("fghjnkm ${event.userIds}");
    updatedFilters['users'] = event.userIds.isNotEmpty;
    print("fgvbjnm ${updatedFilters.values}");
    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      selectedUserIds: event.userIds,
      activeFilters: updatedFilters,
      count: newCount,
    ));
    print("SetUserIds: Selected user IDs = ${event.userIds}, Count = $newCount");
  }

  void _onSetTypeIds(SetTypeIds event, Emitter<ExpenseFilterCountState> emit) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters['type'] = event.typeIds.isNotEmpty;
    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      selectedTypeIds: event.typeIds,
      activeFilters: updatedFilters,
      count: newCount,
    ));
    print("SetTypeIds: Selected type IDs = ${event.typeIds}, Count = $newCount");
  }

  void _onSetDate(SetDate event, Emitter<ExpenseFilterCountState> emit) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters['date'] = event.fromDate.isNotEmpty || event.toDate.isNotEmpty;
    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      fromDate: event.fromDate,
      toDate: event.toDate,
      activeFilters: updatedFilters,
      count: newCount,
    ));
    print("SetDate: From = ${event.fromDate}, To = ${event.toDate}, Count = $newCount");
  }
}