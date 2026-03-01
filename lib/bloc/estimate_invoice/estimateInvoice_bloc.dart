import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../api_helper/api.dart';
import '../../data/model/finance/estimate_invoices_model.dart';
import '../../data/repositories/expense/estimate_invoice_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'estimateInvoice_event.dart';
import 'estimateInvoice_state.dart';

class EstinateInvoiceBloc
    extends Bloc<EstinateInvoicesEvent, EstinateInvoiceState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  String calculatedAmount = '';
  String type = '';
  double taxAmount = 0; // Keep for backward compatibility

  // Lists to store all tax amounts and totals
  List<double> allTaxAmounts = [];
  List<double> allTotals = [];

  // Variables to store the grand totals
  double grandTotalTax = 0.0;
  double subTotal = 0.0;
  double grandTotal = 0.0;

  Map<int, String> itemCalculatedAmounts = {};
  Map<int, double> itemTaxAmounts = {};
  EstinateInvoiceBloc() : super(EstinateInvoiceInitial()) {
    on<EstinateInvoiceLists>(_onListOfEstinateInvoice);
    on<AddEstinateInvoices>(_onAddEstinateInvoice);
    on<EstinateInvoiceUpdateds>(_onUpdateEstinateInvoice);
    on<DeleteEstinateInvoices>(_onDeleteEstinateInvoice);
    on<SearchEstimateInvoices>(_onSearchEstinateInvoice);
    on<LoadMoreEstinateInvoices>(_onLoadMoreEstinateInvoice);
    on<SelectEstinateInvoice>(_onSelectEstinateInvoice);
    on<AmountCalculationEstinateInvoice>(_onAmountCalculationEstinateInvoice);
  }

  String getCalculatedAmountForItem(int itemId) {
    return itemCalculatedAmounts[itemId] ?? '0';
  }
  double setSubTotal(double subTotal) {
    print("ighdxcn $subTotal");
    return subTotal ;
  }
  double setTaxTotal(double taxTotal) {
    print("ighdxcn $taxTotal");
    return taxTotal ;
  }

  double getTaxAmountForItem(int itemId) {
    return itemTaxAmounts[itemId] ?? 0;
  }

  // Method to get the grand total tax
  double getGrandTotalTax() {
    return grandTotalTax;
  }

  // Method to get the grand total amount
  double getGrandTotal() {
    return grandTotal;
  }

  // Method to calculate the grand totals from the stored lists
  void _calculateGrandTotals() {
    grandTotalTax = 0.0;
    grandTotal = 0.0;

    // Sum up all tax amounts
    for (double tax in allTaxAmounts) {
      grandTotalTax += tax;
      print("gsdiydhsjnk $grandTotalTax");
    }

    // Sum up all totals
    for (double total in allTotals) {
      grandTotal += total;
    }
  }

  void _onAmountCalculationEstinateInvoice(
      AmountCalculationEstinateInvoice event,
      Emitter<EstinateInvoiceState> emit,
      ) {
    try {
      type = event.type;

      double baseAmount = event.rate * event.quantity;
      double calculatedTax = 0.0;
      double total = 0.0;
      print("u gdjjkfh ${event.tax}");
      print("u gdjjkfh ${event.type}");
      if (event.tax != "" && event.tax > 0.0) {
        if (event.type == "amount") {
          // Add tax as fixed amount
          calculatedTax = event.tax;
          total = baseAmount + calculatedTax;
          print("ejksffdskfj $total");
        } else if (event.type == "percentage") {
          // Apply tax as percentage
          calculatedTax = baseAmount * event.tax / 100;
          total = baseAmount + calculatedTax;  // Fixed calculation
          print("u gdjjkfher  ${calculatedTax}");
          print("u gdjjkfh ${total}");
        }
      } else {
        total = baseAmount;
        print("ejksffdskfj with out tax  $total");
      }

      String formattedTotal = total.toString();
      calculatedAmount = formattedTotal;
      taxAmount = calculatedTax;

      itemCalculatedAmounts[event.itemId] = formattedTotal;
      itemTaxAmounts[event.itemId] = calculatedTax;

      // Add the calculated values to our lists
      // First check if this itemId already exists in our calculation
      bool itemExists = false;
      for (int i = 0; i < allTotals.length; i++) {
        if (i < event.itemId) continue;
        if (i == event.itemId) {
          // Update existing item
          allTotals[i] = total;
          allTaxAmounts[i] = calculatedTax;
          itemExists = true;
          break;
        }
      }

      // If item doesn't exist, add it to the lists
      if (!itemExists) {
        // Ensure the lists are properly sized
        while (allTotals.length <= event.itemId) {
          allTotals.add(0.0);
          allTaxAmounts.add(0.0);
        }
        allTotals[event.itemId] = total;
        allTaxAmounts[event.itemId] = calculatedTax;
      }

      // Recalculate grand totals
      _calculateGrandTotals();

      emit(AmountCalculatedState(
        calculatedAmount: formattedTotal,
        taxAmount: calculatedTax,
        Itemd: event.itemId,
        grandTotal: grandTotal,
        grandTotalTax: grandTotalTax,
      ));
    } catch (e) {
      print('Error in calculation: $e');
      emit(AmountCalculatedState(
        calculatedAmount: '0.00',
        taxAmount: 0.0,
        Itemd: event.itemId,
        grandTotal: grandTotal,
        grandTotalTax: grandTotalTax,
      ));
    }
  }

  void _onSelectEstinateInvoice(
      SelectEstinateInvoice event,
      Emitter<EstinateInvoiceState> emit,
      ) {
    final currentState = state;
    if (currentState is EstinateInvoicePaginated) {
      emit(EstinateInvoicePaginated(
        EstinateInvoice: currentState.EstinateInvoice,
        hasReachedMax: currentState.hasReachedMax,
        selectedInvoice: event.selectedInvoice,
      ));
    } else {
      emit(EstinateInvoiceSelected(selectedInvoice: event.selectedInvoice));
    }
  }

  Future<void> _onListOfEstinateInvoice(
      EstinateInvoiceLists event, Emitter<EstinateInvoiceState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(EstinateInvoiceLoading());
      List<EstimateInvoicesModel> EstinateInvoice = [];
      Map<String, dynamic> result = await EstinateInvoiceRepo()
          .EstinateInvoiceList(
          limit: _limit,
          offset: _offset,
          search: '',
          clientId: event.clientId,
          clientCreatorId: event.clientCreatorId,
          userCreatorId: event.userCreatorId,
          type: event.type,
          toDate: event.dateTo,
          fromDate: event.dateFrom);
      EstinateInvoice = List<EstimateInvoicesModel>.from(result['data']
          .map((projectData) => EstimateInvoicesModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = EstinateInvoice.length >= result['total'];
      if (result['error'] == false) {
        emit(EstinateInvoicePaginated(
            EstinateInvoice: EstinateInvoice, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((EstinateInvoiceError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(EstinateInvoiceError("Error: $e"));
    }
  }

  Future<void> _onAddEstinateInvoice(
      AddEstinateInvoices event, Emitter<EstinateInvoiceState> emit) async {
    emit(EstinateInvoiceCreateSuccessLoading());
    var invoice = event.estinateInvoice;
    try {
      final List<String> quantities = invoice.items != null
          ? invoice.items!.map((item) => item.quantity?.isNotEmpty == true ? item.quantity! : "1").toList()
          : [];
      Map<String, dynamic> result = await EstinateInvoiceRepo().createInvoice(
        estimateInvoice: invoice.type ?? "",
        client_id: invoice.clientId ?? 0,
        name: invoice.name ?? "",
        address: invoice.address ?? "",
        city: invoice.city ?? "",
        state: invoice.state ?? "",
        country: invoice.country ?? "",
        zip_code: invoice.zipCode ?? "",
        phone: invoice.phone ?? "",
        note: invoice.note ?? "",
        personal_note: invoice.personalNote ?? "",
        from_date: invoice.fromDate ?? "",
        to_date: invoice.toDate ?? "",
        status: invoice.status ?? "",
        total: invoice.total ?? "0",
        tax_amount: invoice.taxAmount ?? "0",
        final_total: invoice.finalTotal ?? "0",
        item_ids: event.item ?? [],
        item: [],
        quantity: quantities,
        unit: event.unit ?? [],
        rate: (event.rate as List?)?.map((e) => e.toString()).toList() ?? [],
        tax: event.tax ?? [],
        amount:
        (event.amount as List?)?.map((e) => e.toString()).toList() ?? [],
      );

      if (result['error'] == false) {
        emit(const EstinateInvoiceCreateSuccess());
        // Reset lists and totals after successful creation
        allTaxAmounts.clear();
        allTotals.clear();
        grandTotalTax = 0.0;
        grandTotal = 0.0;
      }
      if (result['error'] == true) {
        emit((EstinateInvoiceCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      print('Error while creating EstinateInvoice: $e');
    }
  }

  void _onUpdateEstinateInvoice(
      EstinateInvoiceUpdateds event,
      Emitter<EstinateInvoiceState> emit,
      ) async {
    if (state is EstinateInvoicePaginated) {
      emit(EstinateInvoiceEditSuccessLoading());

      final invoice = event.estinateInvoice;
      try {
        print("dnfglk ${invoice.type}");
        Map<String, dynamic> result = await EstinateInvoiceRepo().updateInvoice(
          estimateInvoice: invoice.type ?? "",
          id: invoice.id!,
          clientId: invoice.clientId!,
          name: invoice.name ?? "",
          address: invoice.address ?? "",
          city: invoice.city ?? "",
          state: invoice.state ?? "",
          country: invoice.country ?? "",
          zip_code: invoice.zipCode ?? "",
          phone: invoice.phone ?? "",
          note: invoice.note ?? "",
          personal_note: invoice.personalNote ?? "",
          from_date: invoice.fromDate ?? "",
          to_date: invoice.toDate ?? "",
          status: invoice.status ?? "",
          total: invoice.total!,
          tax_amount: invoice.taxAmount!,
          final_total: invoice.finalTotal!,
          item_ids: event.itemIds ?? [],
          item: invoice.items!,
          quantity: event.quantity ?? [],
          unit: event.unit ?? [],
          rate: event.rate ?? [],
          tax: event.tax ?? [],
          amount: event.amount ?? [],
        );

        if (result['error'] == false) {
          emit(const EstinateInvoiceEditSuccess());
          // Reset lists and totals after successful update
          allTaxAmounts.clear();
          allTotals.clear();
          grandTotalTax = 0.0;
          grandTotal = 0.0;
        } else if (result['error'] == true) {
          emit(EstinateInvoiceEditError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating EstinateInvoice: $e');
        emit(EstinateInvoiceEditError(
            "Something went wrong. Please try again."));
      }
    }
  }

  void _onDeleteEstinateInvoice(
      DeleteEstinateInvoices event, Emitter<EstinateInvoiceState> emit) async {
    final EstinateInvoices = event.EstinateInvoice;
    try {
      Map<String, dynamic> result =
      await EstinateInvoiceRepo().deleteEstinateInvoice(
        id: EstinateInvoices,
        token: true,
      );
      print("fhugi $result");
      print("fhugi ${result['data']['error']}");
      if (result['data']['error'] == false) {
        emit(const EstinateInvoiceDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((EstinateInvoiceDeleteError(result['data']['message'])));

        flutterToastCustom(msg: result['datat']['message']);
      }
      print("ioj gkhk $state");
    } catch (e) {
      emit(EstinateInvoiceDeleteError(e.toString()));
    }
  }

  Future<void> _onSearchEstinateInvoice(
      SearchEstimateInvoices event, Emitter<EstinateInvoiceState> emit) async {
    try {
      List<EstimateInvoicesModel> EstinateInvoice = [];
      _offset = 0;
      emit(EstinateInvoiceLoading());

      Map<String, dynamic> result = await EstinateInvoiceRepo()
          .EstinateInvoiceList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          clientId: event.clientId,
          clientCreatorId: event.clientCreatorId,
          userCreatorId: event.userCreatorId,
          type: event.type,
          toDate: event.dateTo,
          fromDate: event.dateFrom);

      if (result['error'] == false) {
        EstinateInvoice = List<EstimateInvoicesModel>.from(result['data']
            .map((projectData) => EstimateInvoicesModel.fromJson(projectData)));
        bool hasReachedMax = EstinateInvoice.length >= result['total'];

        emit(EstinateInvoicePaginated(
            EstinateInvoice: EstinateInvoice, hasReachedMax: hasReachedMax));
      } else if (result['error'] == true) {
        emit(EstinateInvoiceError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(EstinateInvoiceError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreEstinateInvoice(LoadMoreEstinateInvoices event,
      Emitter<EstinateInvoiceState> emit) async {
    if (state is EstinateInvoicePaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent concurrent API calls
      try {
        final currentState = state as EstinateInvoicePaginated;
        final updatedEstinateInvoice =
        List<EstimateInvoicesModel>.from(currentState.EstinateInvoice);

        // Fetch additional EstinateInvoices
        Map<String, dynamic> result = await EstinateInvoiceRepo()
            .EstinateInvoiceList(
            limit: _limit,
            offset: _offset,
            search: event.searchQuery,
            clientId: event.clientId,
            clientCreatorId: event.clientCreatorId,
            userCreatorId: event.userCreatorId,
            type: event.type,
            toDate: event.dateTo,
            fromDate: event.dateFrom);

        final additionalEstinateInvoice = List<EstimateInvoicesModel>.from(
            result['data'].map(
                    (projectData) => EstimateInvoicesModel.fromJson(projectData)));

        if (additionalEstinateInvoice.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedEstinateInvoice.addAll(additionalEstinateInvoice);
        }

        if (result['error'] == false) {
          emit(EstinateInvoicePaginated(
            EstinateInvoice: updatedEstinateInvoice,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(EstinateInvoiceError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(EstinateInvoiceError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag
      }
    }
  }

  // Method to reset all calculations
  void resetCalculations() {
    allTaxAmounts.clear();
    allTotals.clear();
    grandTotalTax = 0.0;
    grandTotal = 0.0;
    itemCalculatedAmounts.clear();
    itemTaxAmounts.clear();
  }
}