import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:taskify/data/model/contract/contract_model.dart';

import '../../api_helper/api.dart';
import '../../data/repositories/contracts/contract_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'contracts_event.dart';
import 'contracts_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 6;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  ContractBloc() : super(ContractInitial()) {
    on<CreateContract>(_onContractCreate);
    on<ContractList>(_getListOfContract);
    on<UpdateContract>(_onUpdateContract);
    on<DeleteContract>(_onDeleteContract);
    on<DeleteContractSign>(_onDeleteContractSign);
    on<SearchContract>(_onSearchContract);
    on<LoadMoreContract>(_onLoadMoreContract);
    on<SignContract>(_onSignContract);

  }

  Future<void> _onSignContract(SignContract event, Emitter<ContractState> emit) async {
    try {
      emit(ContractLoading());

      Map<String,dynamic> result = await ContractRepo().signContract(
          image: event.contractImage, id: event.id);

      if (result['error'] == false) {
        emit(const ContractSignCreateSuccess());
        add(const ContractList());
      }
      if (result['error'] == true) {
        emit((ContractSignCreateError(result['message'])));
        add(const ContractList());
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(ContractError("Error: $e"));
    }
  }
  Future<void> _onContractCreate(CreateContract event, Emitter<ContractState> emit) async {
    try {
      emit(ContractLoading());
ContractModel model = event.model;
      Map<String,dynamic> result = await ContractRepo().createContract(
          model: model);

      if (result['error'] == false) {
        emit(const ContractCreateSuccess());
        add(const ContractList());
      }
      if (result['error'] == true) {
        emit((ContractCreateError(result['message'])));
        add(const ContractList());
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(ContractError("Error: $e"));
    }
  }


  Future<void> _getListOfContract(ContractList event, Emitter<ContractState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ContractLoading());
      List<ContractModel> Contract =[];
      Map<String,dynamic> result
      = await ContractRepo().contractList(limit: _limit, offset: _offset, search: '');
      Contract = List<ContractModel>.from(result['data'].map((projectData) => ContractModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Contract.length < _limit;

      if (result['error'] == false) {
        emit(ContractPaginated(Contract: Contract, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((ContractError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(ContractError("Error: $e"));
    }
  }

  void _onUpdateContract(UpdateContract event, Emitter<ContractState> emit) async {
    if (state is ContractPaginated) {


      // Update the contract in the list
      try {


        emit(ContractEditSuccessLoading());
        Map<String,dynamic> result = await ContractRepo().updateContract(
       pdfFile: event.contractPdf,
         model: event.model
        ) ; // Cast to ContractModel

        // Replace the contract in the list with the updated one
        if (result['error'] == false) {
          emit(const ContractEditSuccess());
          add(const ContractList());


        }
        if (result['error'] == true) {
          emit((ContractEditError(result['message'])));
          add(const ContractList());
          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((ContractEditError("$e")));

        print('Error while updating contract: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteContract(DeleteContract event, Emitter<ContractState> emit) async {
    // if (emit is ContractSuccess) {
    final contract = event.Contract;
    try {
      Map<String,dynamic> result
    =  await ContractRepo().deleteContract(
        id: contract,
        token: true,
      );
      if(result['error']== false) {
        emit(const ContractDeleteSuccess());
        add(const ContractList());
      }
      if(result['error'] == true){
        emit(ContractDeleteError(result['message']));
        add(const ContractList());
      }
    } catch (e) {
      emit(ContractDeleteError(e.toString()));
      add(const ContractList());
    }
    // }
  }
  void _onDeleteContractSign(DeleteContractSign event, Emitter<ContractState> emit) async {
    final contract = event.Contract;
    try {
      Map<String,dynamic> result
    =  await ContractRepo().deleteSignContract(
        id: contract,

      );
      if(result['error']== false) {
        emit(const ContractSignDeleteSuccess());
        add(const ContractList());
      }
      if(result['error'] == true){
        emit(ContractSignDeleteError(result['message']));
        add(const ContractList());
      }
    } catch (e) {
      emit(ContractDeleteError(e.toString()));
      add(const ContractList());
    }
    // }
  }

  Future<void> _onSearchContract(
      SearchContract event, Emitter<ContractState> emit) async {
    try {
      emit(ContractLoading());
      List<ContractModel> Contract =[];
      Map<String,dynamic> result = await ContractRepo()
          .contractList(limit: _limit, offset: 0, search: event.searchQuery);
      Contract = List<ContractModel>.from(result['data']
          .map((projectData) => ContractModel.fromJson(projectData)));
      bool hasReachedMax = Contract.length < _limit;
      if (result['error'] == false) {
        emit(ContractPaginated(Contract:Contract,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((ContractError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(ContractError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreContract(
      LoadMoreContract event, Emitter<ContractState> emit) async {
    if (state is ContractPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as ContractPaginated;
        final updatedContract = List<ContractModel>.from(currentState.Contract);

        List<ContractModel> additionalContract = [];
        Map<String, dynamic> result = await ContractRepo().contractList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalContract = List<ContractModel>.from(
            result['data'].map((projectData) => ContractModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Contract has been reached
        if (updatedContract.length + additionalContract.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Contract to the updated list
        updatedContract.addAll(additionalContract);

        if (result['error'] == false) {
          emit(ContractPaginated(Contract: updatedContract, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(ContractError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ContractError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
