import 'package:bloc/bloc.dart';

import '../../data/model/finance/estimate_invoices_model.dart';
import 'estimateInvoice_list_event.dart';
import 'estimateInvoice_list_state.dart';

class ItemInvoiceBloc extends Bloc<ItemEvent, ItemState> {
  ItemInvoiceBloc() : super(ItemState(itemsPerInvoice: {})) {
    final Set<int> clearedEstimateIds = {};

    on<AddItemEvent>((event, emit) {
      final estimateId = event.estimateInvoiceId;

      print("🔵 AddItemEvent triggered for Estimate ID: $estimateId");

      final currentItems = state.itemsPerInvoice[estimateId] ?? [];

      // ✅ Check for duplicate
      final exists = currentItems.any((item) => item.id == event.newItem.id);
      if (exists) {
        print("⚠️ Item with ID ${event.newItem.id} already exists. Skipping add.");
        return;
      }

      // ✅ Clear only once for this estimateId
      final updatedMap = Map<int, List<InvoicesItems>>.from(state.itemsPerInvoice);
      if (!clearedEstimateIds.contains(estimateId)) {
        updatedMap[estimateId] = [];
        clearedEstimateIds.add(estimateId);
        print("🧹 Cleared items for Estimate ID: $estimateId");
      }

      // ✅ Add new item
      final updatedItems = [event.newItem, ...?updatedMap[estimateId]];
      updatedMap[estimateId] = updatedItems;

      print("✅ Item added: ${event.newItem.price}, Total items now: ${updatedItems.length}");

      emit(state.copyWith(itemsPerInvoice: updatedMap));
    });

    on<EditItemEvent>((event, emit) {
      print("🟡 EditItemEvent triggered for Estimate ID: ${event.estimateInvoiceId}");

      final currentItems = state.itemsPerInvoice[event.estimateInvoiceId] ?? [];
      print("📦 Existing items: ${currentItems.length}");

      final updatedList = currentItems.map((item) {
        print("➡️ Checking item.id: ${item.id} against event.id: ${event.id}");
        if (item.id.toString() == event.id.toString()) {
          print("✏️ MATCH FOUND: Updating item with id ${item.id}");
          return event.updatedItem;
        }
        return item;
      }).toList();

      final updatedMap = Map<int, List<InvoicesItems>>.from(state.itemsPerInvoice);
      updatedMap[event.estimateInvoiceId] = updatedList;

      emit(state.copyWith(itemsPerInvoice: updatedMap));
    });

    on<RemoveItemEvent>((event, emit) {
      print("🔴 RemoveItemEvent triggered for Estimate ID: ${event.estimateInvoiceId}, Item ID: ${event.itemId}");

      final currentItems = state.itemsPerInvoice[event.estimateInvoiceId] ?? [];
      print("📦 Existing items: ${currentItems.length}");

      // Remove the item with the matching itemId
      final updatedList = currentItems.where((item) => item.id != event.itemId).toList();

      final updatedMap = Map<int, List<InvoicesItems>>.from(state.itemsPerInvoice);
      updatedMap[event.estimateInvoiceId] = updatedList;

      print("🗑️ Item with ID ${event.itemId} removed. Total items now: ${updatedList.length}");

      // If the list is empty, optionally remove the estimateId key from the map
      if (updatedList.isEmpty) {
        updatedMap.remove(event.estimateInvoiceId);
        print("🧹 Removed empty item list for Estimate ID: ${event.estimateInvoiceId}");
      }

      emit(state.copyWith(itemsPerInvoice: updatedMap));
    });
  }
}