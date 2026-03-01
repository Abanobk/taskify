import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../api_helper/api.dart';
import '../../../data/model/allowance.dart';
import '../../../data/repositories/allowance/allowance_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

import 'allowance_event.dart';
import 'allowance_state.dart';

class AllowanceBloc extends Bloc<AllowancesEvent, AllowancesState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingItem = "";

  AllowanceBloc() : super(AllowancesInitial()) {
    on<CreateAllowances>(_onAllowancesCreate);
    on<AllowancesList>(_getListOfAllowances);
    on<AddAllowances>(_onAddItem);
    on<UpdateAllowances>(_onUpdateItem);
    on<DeleteAllowances>(_onDeleteItem);
    on<SearchAllowances>(_onSearchAllowances);
    on<LoadMoreAllowances>(_onLoadMoreAllowances);
  }

  Future<void> _onAllowancesCreate(CreateAllowances event, Emitter<AllowancesState> emit) async {
    try {
      emit(AllowancesLoading());

      Map<String,dynamic> result = await AllowancesRepo().createAllowance(

          title: event.title,
           amount: event.amount,

         );

      if (result['error'] == false) {
        emit(const AllowancesCreateSuccess());

      }
      if (result['error'] == true) {
        emit((AllowancesCreateError(result['message'])));

        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(AllowancesError("Error: $e"));
    }
  }


  Future<void> _getListOfAllowances(AllowancesList event, Emitter<AllowancesState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(AllowancesLoading());
      List<AllowanceModel> Allowances =[];
      Map<String,dynamic> result
      = await AllowancesRepo().allowanceList(limit: _limit, offset: _offset, search: '');
      Allowances = List<AllowanceModel>.from(result['data'].map((projectData) =>
          AllowanceModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Allowances.length  >= result['total'];
      if (result['error'] == false) {
        emit(AllowancesPaginated(Allowances: Allowances, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((AllowancesError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(AllowancesError("Error: $e"));
    }
  }
  Future<void> _onAddItem(AddAllowances event, Emitter<AllowancesState> emit) async {
    if (state is AllowancesPaginated) {
      final Item = event.Allowances;
      final title = Item.title;
      final amount = Item.amount;


      //
      try {
         emit(AllowancesCreateSuccessLoading());

        Map<String,dynamic> result
    = await AllowancesRepo().createAllowance(
          title: title!,  amount: amount.toString()


        );


        if (result['error'] == false) {

          emit(const AllowancesCreateSuccess());
        }
        if (result['error'] == true) {
          emit((AllowancesCreateError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }


      } catch (e) {
        print('Error while creating Item: $e');
        // Optionally, handle the error state
      }
    }
  }
  void _onUpdateItem(UpdateAllowances event, Emitter<AllowancesState> emit) async {
    if (state is AllowancesPaginated) {
      final Item = event.Allowances;
      final id = Item.id;
      final title = Item.title;

      final amount = Item.amount;



      // Update the Item in the list
      try {


        emit(AllowancesEditSuccessLoading());
        Map<String,dynamic> result = await AllowancesRepo().updateAllowance(
          id: id!,
          title: title!,
         amount : amount.toString(),


        ) ; // Cast to AllowancesModel

        // Replace the Item in the list with the updated one
        if (result['error'] == false) {
          emit(const AllowancesEditSuccess());

        }
        if (result['error'] == true) {
          emit((AllowancesEditError(result['message'])));

          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((AllowancesEditError("$e")));

        print('Error while updating Item: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteItem(DeleteAllowances event, Emitter<AllowancesState> emit) async {
    // if (emit is AllowancesSuccess) {
    final Item = event.Allowances;
    try {
      Map<String,dynamic> result
    =  await AllowancesRepo().deleteAllowance(
        id: Item,

      );
      if(result['error']== false) {
        emit(const AllowancesDeleteSuccess());
      }
      if(result['error'] == true){
        emit(AllowancesDeleteError(result['message']));
      }
    } catch (e) {
      emit(AllowancesDeleteError(e.toString()));
    }
    // }
  }

  Future<void> _onSearchAllowances(
      SearchAllowances event, Emitter<AllowancesState> emit) async {
    try {
      emit(AllowancesLoading());
      List<AllowanceModel> Allowances =[];
      Map<String,dynamic> result = await AllowancesRepo()
          .allowanceList(limit: _limit, offset: 0, search: event.searchQuery);
      Allowances = List<AllowanceModel>.from(result['data']
          .map((projectData) => AllowanceModel.fromJson(projectData)));
      bool hasReachedMax = Allowances.length < _limit;
      if (result['error'] == false) {
        emit(AllowancesPaginated(Allowances:Allowances,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((AllowancesError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(AllowancesError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreAllowances(
      LoadMoreAllowances event, Emitter<AllowancesState> emit) async {
    if (state is AllowancesPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as AllowancesPaginated;
        final updatedAllowances = List<AllowanceModel>.from(currentState.Allowances);

        List<AllowanceModel> additionalAllowances = [];
        Map<String, dynamic> result = await AllowancesRepo().allowanceList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalAllowances = List<AllowanceModel>.from(
            result['data'].map((projectData) => AllowanceModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Allowances has been reached
        if (updatedAllowances.length + additionalAllowances.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Allowances to the updated list
        updatedAllowances.addAll(additionalAllowances);

        if (result['error'] == false) {
          emit(AllowancesPaginated(Allowances: updatedAllowances, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(AllowancesError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(AllowancesError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
