import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../api_helper/api.dart';
import '../../../data/model/payslip/deduction-model.dart';
import '../../../data/repositories/deduction/deduction_repo.dart';
import '../../../utils/widgets/toast_widget.dart';
import 'deduction_event.dart';
import 'deduction_state.dart';

class DeductionBloc extends Bloc<DeductionsEvent, DeductionsState> {
  int _offset = 0;
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingItem = "";

  DeductionBloc() : super(DeductionsInitial()) {
    on<CreateDeductions>(_onDeductionsCreate);
    on<DeductionsList>(_getListOfDeductions);
    on<AddDeductions>(_onAddItem);
    on<UpdateDeductions>(_onUpdateItem);
    on<DeleteDeductions>(_onDeleteItem);
    on<SearchDeductions>(_onSearchDeductions);
    on<LoadMoreDeductions>(_onLoadMoreDeductions);
  }

  Future<void> _onDeductionsCreate(CreateDeductions event, Emitter<DeductionsState> emit) async {
    try {
      emit(DeductionsLoading());

      Map<String,dynamic> result = await DeductionRepo().createDeduction(

          title: event.title,
           type: event.type, amount: event.amount, percentage: event.per,

         );

      if (result['error'] == false) {
        emit(const DeductionsCreateSuccess());

      }
      if (result['error'] == true) {
        emit((DeductionsCreateError(result['message'])));

        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(DeductionsError("Error: $e"));
    }
  }


  Future<void> _getListOfDeductions(DeductionsList event, Emitter<DeductionsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(DeductionsLoading());
      List<DeductionModel> Deductions =[];
      Map<String,dynamic> result
      = await DeductionRepo().DeductionList(limit: _limit, offset: _offset, search: '');
      Deductions = List<DeductionModel>.from(result['data'].map((projectData) =>
          DeductionModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Deductions.length  >= result['total'];
print("fkeh f;k $_hasReachedMax");
print("fkeh f;k ${Deductions.length}");
print("fkeh f;k ${result['total']}");
      if (result['error'] == false) {
        emit(DeductionsPaginated(Deductions: Deductions, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((DeductionsError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(DeductionsError("Error: $e"));
    }
  }
  Future<void> _onAddItem(AddDeductions event, Emitter<DeductionsState> emit) async {
    if (state is DeductionsPaginated) {
      final Item = event.Deductions;
      final title = Item.title;
      final type = Item.type;
      final amount = Item.amount;
      final per = Item.percentage;

      //
      try {
         emit(DeductionsCreateSuccessLoading());

        Map<String,dynamic> result
    = await DeductionRepo().createDeduction(
          title: title!, type: type!, amount: amount.toString(), percentage: per.toString(),


        );


        if (result['error'] == false) {

          emit(const DeductionsCreateSuccess());
        }
        if (result['error'] == true) {
          emit((DeductionsCreateError(result['message'])));

          flutterToastCustom(msg: result['message']);
        }


      } catch (e) {
        print('Error while creating Item: $e');
        // Optionally, handle the error state
      }
    }
  }
  void _onUpdateItem(UpdateDeductions event, Emitter<DeductionsState> emit) async {
    if (state is DeductionsPaginated) {
      final Item = event.Deductions;
      final id = Item.id;
      final title = Item.title;
      final type = Item.type;
      final amount = Item.amount;
      final per = Item.percentage;


      // Update the Item in the list
      try {


        emit(DeductionsEditSuccessLoading());
        Map<String,dynamic> result = await DeductionRepo().updateDeduction(
          id: id!,
          title: title!,
           type : type!,
         amount : amount.toString(),
      percentage : per.toString(),

        ) ; // Cast to DeductionsModel

        // Replace the Item in the list with the updated one
        if (result['error'] == false) {
          emit(const DeductionsEditSuccess());



        }
        if (result['error'] == true) {
          emit((DeductionsEditError(result['message'])));

          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((DeductionsEditError("$e")));

        print('Error while updating Item: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteItem(DeleteDeductions event, Emitter<DeductionsState> emit) async {
    // if (emit is DeductionsSuccess) {
    final Item = event.Deductions;
    try {
      Map<String,dynamic> result
    =  await DeductionRepo().deleteDeduction(
        id: Item,
        token: true,
      );
      if(result['error']== false) {
        emit(const DeductionsDeleteSuccess());

      }
      if(result['error'] == true){
        emit(DeductionsDeleteError(result['message']));

      }
    } catch (e) {
      emit(DeductionsDeleteError(e.toString()));

    }
    // }
  }

  Future<void> _onSearchDeductions(
      SearchDeductions event, Emitter<DeductionsState> emit) async {
    try {
      emit(DeductionsLoading());
      List<DeductionModel> Deductions =[];
      print("SEARCH TYPE ${event.type}");
      Map<String,dynamic> result = await DeductionRepo()
          .DeductionList(limit: _limit, offset: 0, search: event.searchQuery,type: event.type);
      Deductions = List<DeductionModel>.from(result['data']
          .map((projectData) => DeductionModel.fromJson(projectData)));
      bool hasReachedMax = Deductions.length < _limit;
      if (result['error'] == false) {
        emit(DeductionsPaginated(Deductions:Deductions,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((DeductionsError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(DeductionsError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreDeductions(
      LoadMoreDeductions event, Emitter<DeductionsState> emit) async {
    if (state is DeductionsPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as DeductionsPaginated;
        final updatedDeductions = List<DeductionModel>.from(currentState.Deductions);

        List<DeductionModel> additionalDeductions = [];
        Map<String, dynamic> result = await DeductionRepo().DeductionList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalDeductions = List<DeductionModel>.from(
            result['data'].map((projectData) => DeductionModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Deductions has been reached
        if (updatedDeductions.length + additionalDeductions.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Deductions to the updated list
        updatedDeductions.addAll(additionalDeductions);

        if (result['error'] == false) {
          emit(DeductionsPaginated(Deductions: updatedDeductions, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(DeductionsError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(DeductionsError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
