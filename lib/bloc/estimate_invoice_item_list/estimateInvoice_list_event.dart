import '../../data/model/finance/estimate_invoices_model.dart';

abstract class ItemEvent {}

class AddItemEvent extends ItemEvent {
  final int estimateInvoiceId;
  final InvoicesItems newItem;
  final List<InvoicesItems>? itemListWidget; // it's a list now


  AddItemEvent({required this.estimateInvoiceId, required this.newItem, this.itemListWidget,
  });
}

class EditItemEvent extends ItemEvent {
  final int estimateInvoiceId;
  final String id;
  final InvoicesItems updatedItem;

  EditItemEvent({
    required this.estimateInvoiceId,
    required this.id,
    required this.updatedItem,
  });
}
class RemoveItemEvent extends ItemEvent {
  final int itemId;
  final int estimateInvoiceId;

  RemoveItemEvent({required this.itemId, required this.estimateInvoiceId});
}
