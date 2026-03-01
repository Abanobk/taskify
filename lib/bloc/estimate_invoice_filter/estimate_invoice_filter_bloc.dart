import 'package:bloc/bloc.dart';
import 'estimate_invoice_filter_event.dart';
import 'estimate_invoice_filter_state.dart';

class EstimateInvoiceFilterCountBloc
    extends Bloc<EstimateInvoiceFilterCountEvent, EstimateInvoiceFilterCountState> {
  EstimateInvoiceFilterCountBloc() : super(EstimateInvoiceFilterCountState.initial()) {
    on<EstimateInvoiceUpdateFilterCount>(_onUpdateFilterCount);
    on<EstimateInvoiceResetFilterCount>(_onResetFilterCount);
    on<SetClients>(_onSetClients);
    on<SetTypes>(_onSetTypes);
    on<SetUserCreator>(_onSetUserCreator);
    on<SetClientCreator>(_onSetClientCreator);
    on<SetDateEstimate>(_onSetDate);
  }

  void _onUpdateFilterCount(
      EstimateInvoiceUpdateFilterCount event,
      Emitter<EstimateInvoiceFilterCountState> emit,
      ) {
    final updatedFilters = Map<String, bool>.from(state.activeFilters);
    updatedFilters[event.filterType.toLowerCase()] = event.isSelected;

    final newCount = updatedFilters.values.where((isActive) => isActive).length;

    emit(state.copyWith(
      activeFilters: updatedFilters,
      count: newCount,
    ));
  }

  void _onResetFilterCount(
      EstimateInvoiceResetFilterCount event,
      Emitter<EstimateInvoiceFilterCountState> emit,
      ) {
    final resetFilters = {
      'clients': false,
      'type': false,
      'usercreator': false,
      'clientcreator': false,
      'date': false,
    };

    emit(state.copyWith(
      activeFilters: resetFilters,
      count: 0,
      selectedClientIds: [],
      selectedTypeIds: [],
      selectedUserCreatorIds: [],
      selectedClientCreatorIds: [],
      fromDate: "",
      toDate: "",
    ));
  }

  void _onSetClients(SetClients event, Emitter<EstimateInvoiceFilterCountState> emit) {
    emit(state.copyWith(selectedClientIds: event.clientIds));
    print("Selected client IDs: ${event.clientIds}");
  }

  void _onSetTypes(SetTypes event, Emitter<EstimateInvoiceFilterCountState> emit) {
    emit(state.copyWith(selectedTypeIds: event.typeIds));
    print("Selected type IDs: ${event.typeIds}");
  }

  void _onSetUserCreator(SetUserCreator event, Emitter<EstimateInvoiceFilterCountState> emit) {
    emit(state.copyWith(selectedUserCreatorIds: event.userCreatorIds));
    print("Selected user creator IDs: ${event.userCreatorIds}");
  }

  void _onSetClientCreator(SetClientCreator event, Emitter<EstimateInvoiceFilterCountState> emit) {
    emit(state.copyWith(selectedClientCreatorIds: event.clientCreatorIds));
    print("Selected client creator IDs: ${event.clientCreatorIds}");
  }

  void _onSetDate(SetDateEstimate event, Emitter<EstimateInvoiceFilterCountState> emit) {
    emit(state.copyWith(fromDate: event.fromDate, toDate: event.toDate));
    print("Date set from ${event.fromDate} to ${event.toDate}");
  }
}
