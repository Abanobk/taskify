import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../api_helper/api.dart';
import '../../data/model/contract/contract_type_model.dart';
import '../../data/repositories/contracts/contract_repo.dart';
import '../../utils/widgets/toast_widget.dart';

import 'contracts_type_event.dart';
import 'contracts_type_state.dart';

class ContractTypeBloc extends Bloc<ContractTypeEvent, ContractTypeState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 6;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  ContractTypeBloc() : super(ContractTypeInitial()) {
    on<CreateContractType>(_onContractTypeCreate);
    on<ContractTypeList>(_getListOfContractType);
    on<UpdateContractType>(_onUpdateNote);
    on<DeleteContractType>(_onDeleteNote);
    on<SearchContractType>(_onSearchContractType);
    on<LoadMoreContractType>(_onLoadMoreContractType);
    on<SelectContractType>(_onSelectContractType);

  }
  Future<void> _onSelectContractType(SelectContractType event, Emitter<ContractTypeState> emit) async {
    if (state is ContractTypePaginated) {
      final currentState = state as ContractTypePaginated;
      emit(ContractTypePaginated(
        ContractType: currentState.ContractType,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }
  Future<void> _onContractTypeCreate(CreateContractType event, Emitter<ContractTypeState> emit) async {
    try {
      emit(ContractTypeLoading());

      Map<String,dynamic> result = await ContractRepo().createContractType(
          type: event.type);

      if (result['error'] == false) {
        emit(const ContractTypeCreateSuccess());

      }
      if (result['error'] == true) {
        emit((ContractTypeCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(ContractTypeError("Error: $e"));
    }
  }


  Future<void> _getListOfContractType(ContractTypeList event, Emitter<ContractTypeState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ContractTypeLoading());
      List<ContractTypeModel> ContractType =[];
      Map<String,dynamic> result
      = await ContractRepo().contractListType(limit: _limit, offset: _offset, search: '');
      ContractType = List<ContractTypeModel>.from(result['data'].map((projectData) => ContractTypeModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = ContractType.length <= _limit;

      if (result['error'] == false) {
        emit(ContractTypePaginated(ContractType: ContractType, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((ContractTypeError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(ContractTypeError("Error: $e"));
    }
  }

  void _onUpdateNote(UpdateContractType event, Emitter<ContractTypeState> emit) async {
    if (state is ContractTypePaginated) {


      // Update the note in the list
      try {


        emit(ContractTypeEditSuccessLoading());
        Map<String,dynamic> result = await ContractRepo().updateContractType(
          id: event.id,
         type: event.type
        ) ; // Cast to ContractTypeModel

        // Replace the note in the list with the updated one
        if (result['error'] == false) {
          emit(const ContractTypeEditSuccess());


        }
        if (result['error'] == true) {
          emit((ContractTypeEditError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((ContractTypeEditError("$e")));

        print('Error while updating note: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteNote(DeleteContractType event, Emitter<ContractTypeState> emit) async {
    // if (emit is ContractTypeSuccess) {
    final note = event.ContractType;
    try {
      Map<String,dynamic> result
    =  await ContractRepo().deleteContractType(
        id: note,
        token: true,
      );
      print("ghjkl ${result['error']}");
      if(result['error']== false) {
        emit(const ContractTypeDeleteSuccess());
      }
      if(result['error'] == true){
        emit(ContractTypeDeleteError(result['message']));

      }
    } catch (e) {
      emit(ContractTypeDeleteError(e.toString()));

    }
    // }
  }

  Future<void> _onSearchContractType(
      SearchContractType event, Emitter<ContractTypeState> emit) async {
    try {
      emit(ContractTypeLoading());
      List<ContractTypeModel> ContractType =[];
      Map<String,dynamic> result = await ContractRepo()
          .contractListType(limit: _limit, offset: 0, search: event.searchQuery);
      ContractType = List<ContractTypeModel>.from(result['data']
          .map((projectData) => ContractTypeModel.fromJson(projectData)));
      bool hasReachedMax = ContractType.length < _limit;
      if (result['error'] == false) {
        emit(ContractTypePaginated(ContractType:ContractType,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ContractTypeError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(ContractTypeError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreContractType(
      LoadMoreContractType event, Emitter<ContractTypeState> emit) async {
    if (state is ContractTypePaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as ContractTypePaginated;
        final updatedContractType = List<ContractTypeModel>.from(currentState.ContractType);

        List<ContractTypeModel> additionalContractType = [];
        Map<String, dynamic> result = await ContractRepo().contractListType(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalContractType = List<ContractTypeModel>.from(
            result['data'].map((projectData) => ContractTypeModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of ContractType has been reached
        if (updatedContractType.length + additionalContractType.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched ContractType to the updated list
        updatedContractType.addAll(additionalContractType);

        if (result['error'] == false) {
          emit(ContractTypePaginated(ContractType: updatedContractType, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(ContractTypeError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ContractTypeError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
