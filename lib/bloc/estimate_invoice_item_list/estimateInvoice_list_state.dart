import '../../data/model/finance/estimate_invoices_model.dart';

class ItemState {
  final Map<int, List<InvoicesItems>> itemsPerInvoice;

  ItemState({required this.itemsPerInvoice});

  ItemState copyWith({Map<int, List<InvoicesItems>>? itemsPerInvoice}) {
    return ItemState(
      itemsPerInvoice: itemsPerInvoice ?? this.itemsPerInvoice,
    );
  }
}

