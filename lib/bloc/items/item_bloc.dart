import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../api_helper/api.dart';
import '../../data/model/finance/estimate_invoices_model.dart';
import '../../data/repositories/item/item_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'item_event.dart';
import 'item_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingItem = "";

  ItemsBloc() : super(ItemsInitial()) {
    on<CreateItems>(_onItemsCreate);
    on<ItemsList>(_getListOfItems);
    on<AddItems>(_onAddItem);
    on<UpdateItems>(_onUpdateItem);
    on<DeleteItems>(_onDeleteItem);
    on<SearchItems>(_onSearchItems);
    on<LoadMoreItems>(_onLoadMoreItems);
  }

  Future<void> _onItemsCreate(
      CreateItems event, Emitter<ItemsState> emit) async {
    try {
      emit(ItemsLoading());

      Map<String, dynamic> result = await ItemsRepo().createItem(
        token: true,
        title: event.title,
        price: event.price,
        desc: event.desc,
        unitId: event.unitId,
      );

      if (result['error'] == false) {
        emit(const ItemsCreateSuccess());
        add(const ItemsList());
      }
      if (result['error'] == true) {
        emit((ItemsCreateError(result['message'])));
        add(const ItemsList());
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ItemsError("Error: $e"));
    }
  }

  Future<void> _getListOfItems(
      ItemsList event, Emitter<ItemsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ItemsLoading());
      List<InvoicesItems> Items = [];
      Map<String, dynamic> result = await ItemsRepo()
          .ItemList(limit: _limit, offset: _offset, search: '');
      Items = List<InvoicesItems>.from(result['data']
          .map((projectData) => InvoicesItems.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Items.length < _limit;
      print("ffg;nd $_hasReachedMax");
      if (result['error'] == false) {
        emit(ItemsPaginated(Items: Items, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ItemsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ItemsError("Error: $e"));
    }
  }

  Future<void> _onAddItem(AddItems event, Emitter<ItemsState> emit) async {
    if (state is ItemsPaginated) {
      final Item = event.Items;
      final title = Item.title;
      final desc = Item.description;
      final unitId = Item.unitId;
      final price = Item.price;
      //
      try {
        emit(ItemsCreateSuccessLoading());

        Map<String, dynamic> result = await ItemsRepo().createItem(
          title: title!,
          desc: desc!,
            price:int.parse(price!),
          unitId: int.parse(unitId!),
          token: true,
        );

        if (result['error'] == false) {
          emit(const ItemsCreateSuccess());
          add(const ItemsList());
        }
        if (result['error'] == true) {
          emit((ItemsCreateError(result['message'])));
          add(const ItemsList());
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while creating Item: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onUpdateItem(UpdateItems event, Emitter<ItemsState> emit) async {
    if (state is ItemsPaginated) {
      final InvoicesItems Item = event.Items;
      final int? id = Item.id;
      final String? title = Item.title;
      final String? desc = Item.description;
      final String? price = Item.price;
      final String? unitId = Item.unitId;

      // Update the Item in the list
      try {
        emit(ItemsEditSuccessLoading());
        Map<String, dynamic> result = await ItemsRepo().updateItem(
          id: id!,
          title: title!,
          price: price ?? "",
          unitId: int.parse(unitId!),
          desc: desc!,
          token: true,
        ); // Cast to ItemsModel

        // Replace the Item in the list with the updated one
        if (result['error'] == false) {
          emit(const ItemsEditSuccess());
          add(const ItemsList());
        }
        if (result['error'] == true) {
          emit((ItemsEditError(result['message'])));
          add(const ItemsList());
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        emit((ItemsEditError("$e")));

        print('Error while updating Item: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteItem(DeleteItems event, Emitter<ItemsState> emit) async {
    // if (emit is ItemsSuccess) {
    final Item = event.Items;
    try {
      Map<String, dynamic> result = await ItemsRepo().deleteItem(
        id: Item,
        token: true,
      );
      if (result['error'] == false) {
        emit(const ItemsDeleteSuccess());
        add(const ItemsList());
      }
      if (result['error'] == true) {
        emit(ItemsDeleteError(result['message']));
        add(const ItemsList());
      }
    } catch (e) {
      emit(ItemsDeleteError(e.toString()));
      add(const ItemsList());
    }
    // }
  }

  Future<void> _onSearchItems(
      SearchItems event, Emitter<ItemsState> emit) async {
    try {
      emit(ItemsLoading());
      List<InvoicesItems> Items = [];
      Map<String, dynamic> result = await ItemsRepo().ItemList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          unitId: event.unitId);
      Items = List<InvoicesItems>.from(result['data']
          .map((projectData) => InvoicesItems.fromJson(projectData)));
      bool hasReachedMax = Items.length < _limit;
      if (result['error'] == false) {
        emit(ItemsPaginated(Items: Items, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ItemsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ItemsError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreItems(
      LoadMoreItems event, Emitter<ItemsState> emit) async {
    if (state is ItemsPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as ItemsPaginated;
        final updatedItems = List<InvoicesItems>.from(currentState.Items);

        List<InvoicesItems> additionalItems = [];
        Map<String, dynamic> result = await ItemsRepo().ItemList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalItems = List<InvoicesItems>.from(result['data'].map((projectData) => InvoicesItems.fromJson(projectData)));
        // Update the offset after each call, increment it by the limit
        _offset += _limit;
        // Check if total number of Items has been reached
        if (updatedItems.length + additionalItems.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Items to the updated list
        updatedItems.addAll(additionalItems);

        if (result['error'] == false) {
          emit(ItemsPaginated(
              Items: updatedItems, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(ItemsError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ItemsError("Error: $e"));
      } finally {
        _isLoading =
            false; // Reset the loading flag after the API call finishes
      }
    }
  }
}
