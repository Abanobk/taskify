import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:taskify/data/repositories/tax/tax_repo.dart';
import '../../api_helper/api.dart';
import '../../data/model/finance/tax_model.dart';
import '../../utils/widgets/toast_widget.dart';
import 'tax_event.dart';
import 'tax_state.dart';

class TaxBloc extends Bloc<TaxesEvent, TaxesState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingItem = "";

  TaxBloc() : super(TaxesInitial()) {
    on<CreateTaxes>(_onTaxesCreate);
    on<TaxesList>(_getListOfTaxes);
    on<AddTaxes>(_onAddItem);
    on<UpdateTaxes>(_onUpdateItem);
    on<DeleteTaxes>(_onDeleteItem);
    on<SearchTaxes>(_onSearchTaxes);
    on<LoadMoreTaxes>(_onLoadMoreTaxes);
  }

  Future<void> _onTaxesCreate(CreateTaxes event, Emitter<TaxesState> emit) async {
    try {
      emit(TaxesLoading());

      Map<String,dynamic> result = await TaxesRepo().createtax(

          title: event.title,
           type: event.type, amount: event.amount, percentage: event.per,

         );

      if (result['error'] == false) {
        emit(const TaxesCreateSuccess());
        add(const TaxesList());
      }
      if (result['error'] == true) {
        emit((TaxesCreateError(result['message'])));
        add(const TaxesList());
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(TaxesError("Error: $e"));
    }
  }


  Future<void> _getListOfTaxes(TaxesList event, Emitter<TaxesState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TaxesLoading());
      List<TaxModel> Taxes =[];
      Map<String,dynamic> result
      = await TaxesRepo().taxList(limit: _limit, offset: _offset, search: '');
      Taxes = List<TaxModel>.from(result['data'].map((projectData) =>
          TaxModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Taxes.length  >= result['total'];
print("fkeh f;k $_hasReachedMax");
print("fkeh f;k ${Taxes.length}");
print("fkeh f;k ${result['total']}");
      if (result['error'] == false) {
        emit(TaxesPaginated(Taxes: Taxes, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((TaxesError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(TaxesError("Error: $e"));
    }
  }
  Future<void> _onAddItem(AddTaxes event, Emitter<TaxesState> emit) async {
    if (state is TaxesPaginated) {
      final Item = event.Taxes;
      final title = Item.title;
      final type = Item.type;
      final amount = Item.amount;
      final per = Item.percentage;

      //
      try {
         emit(TaxesCreateSuccessLoading());

        Map<String,dynamic> result
    = await TaxesRepo().createtax(
          title: title!, type: type!, amount: amount.toString(), percentage: per.toString(),


        );


        if (result['error'] == false) {

          emit(const TaxesCreateSuccess());
          add(const TaxesList());}
        if (result['error'] == true) {
          emit((TaxesCreateError(result['message'])));
          add(const TaxesList());
          flutterToastCustom(msg: result['message']);
        }


      } catch (e) {
        print('Error while creating Item: $e');
        // Optionally, handle the error state
      }
    }
  }
  void _onUpdateItem(UpdateTaxes event, Emitter<TaxesState> emit) async {
    if (state is TaxesPaginated) {
      final Item = event.Taxes;
      final id = Item.id;
      final title = Item.title;
      final type = Item.type;
      final amount = Item.amount;
      final per = Item.percentage;


      // Update the Item in the list
      try {


        emit(TaxesEditSuccessLoading());
        Map<String,dynamic> result = await TaxesRepo().updatetax(
          id: id!,
          title: title!,
           type : type!,
         amount : amount.toString(),
      percentage : per.toString(),

        ) ; // Cast to TaxesModel

        // Replace the Item in the list with the updated one
        if (result['error'] == false) {
          emit(const TaxesEditSuccess());
          add(const TaxesList());


        }
        if (result['error'] == true) {
          emit((TaxesEditError(result['message'])));
          add(const TaxesList());
          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((TaxesEditError("$e")));

        print('Error while updating Item: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteItem(DeleteTaxes event, Emitter<TaxesState> emit) async {
    // if (emit is TaxesSuccess) {
    final Item = event.Taxes;
    try {
      Map<String,dynamic> result
    =  await TaxesRepo().deletetax(
        id: Item,
        token: true,
      );
      if(result['error']== false) {
        emit(const TaxesDeleteSuccess());
        add(const TaxesList());
      }
      if(result['error'] == true){
        emit(TaxesDeleteError(result['message']));
        add(const TaxesList());
      }
    } catch (e) {
      emit(TaxesDeleteError(e.toString()));
      add(const TaxesList());
    }
    // }
  }

  Future<void> _onSearchTaxes(
      SearchTaxes event, Emitter<TaxesState> emit) async {
    try {
      emit(TaxesLoading());
      List<TaxModel> Taxes =[];
      Map<String,dynamic> result = await TaxesRepo()
          .taxList(limit: _limit, offset: 0, search: event.searchQuery,type: event.type);
      Taxes = List<TaxModel>.from(result['data']
          .map((projectData) => TaxModel.fromJson(projectData)));
      bool hasReachedMax = Taxes.length < _limit;
      if (result['error'] == false) {
        emit(TaxesPaginated(Taxes:Taxes,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TaxesError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(TaxesError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreTaxes(
      LoadMoreTaxes event, Emitter<TaxesState> emit) async {
    if (state is TaxesPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as TaxesPaginated;
        final updatedTaxes = List<TaxModel>.from(currentState.Taxes);

        List<TaxModel> additionalTaxes = [];
        Map<String, dynamic> result = await TaxesRepo().taxList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalTaxes = List<TaxModel>.from(
            result['data'].map((projectData) => TaxModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Taxes has been reached
        if (updatedTaxes.length + additionalTaxes.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Taxes to the updated list
        updatedTaxes.addAll(additionalTaxes);

        if (result['error'] == false) {
          emit(TaxesPaginated(Taxes: updatedTaxes, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(TaxesError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(TaxesError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
