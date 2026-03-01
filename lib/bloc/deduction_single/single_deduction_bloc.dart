import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/deduction_single/single_deduction_event.dart';
import 'package:taskify/bloc/deduction_single/single_deduction_state.dart';
import '../../data/model/payslip/deduction-model.dart';
import '../../data/repositories/Deduction/Deduction_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class SingleDeductionBloc extends Bloc<SingleDeductionEvent, SingleDeductionState> {
  int _offset = 0;
  final int _limit = 15;
  bool _hasReachedMax = false;

  SingleDeductionBloc() : super(SingleDeductionInitial()) {
    on<SingleDeductionList>(_getSingleDeductionList);
    on<SelectSingleDeduction>(_onSelectSingleDeduction);
    on<SingleDeductionLoadMore>(_onLoadMoreSingleDeductions);
  }

  Future<void> _getSingleDeductionList(
      SingleDeductionList event, Emitter<SingleDeductionState> emit) async {
    try {
      emit(SingleDeductionLoading());
      _offset = 0; // Reset offset
      _hasReachedMax = false;

      final result = await DeductionRepo().DeductionList(

        offset: _offset,
        limit: _limit,
      );

      if (result['error'] == false) {
        final Deductions = List<DeductionModel>.from(result['data']
            .map((DeductionJson) => DeductionModel.fromJson(DeductionJson)));

        _offset += Deductions.length;
        _hasReachedMax = Deductions.length < _limit;

        emit(SingleDeductionSuccess(Deductions, -1, '', _hasReachedMax));
      } else {
        emit(SingleDeductionError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(SingleDeductionError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreSingleDeductions(
      SingleDeductionLoadMore event, Emitter<SingleDeductionState> emit) async {
    if (state is SingleDeductionSuccess && !_hasReachedMax) {
      final currentState = state as SingleDeductionSuccess;
      try {
        final result = await DeductionRepo().DeductionList(
          offset: _offset,
          limit: _limit,
        );

        if (result['error'] == false) {
          final moreDeductions = List<DeductionModel>.from(result['data']
              .map((DeductionJson) => DeductionModel.fromJson(DeductionJson)));

          _offset += moreDeductions.length;
          _hasReachedMax = moreDeductions.length < _limit;

          emit(SingleDeductionSuccess(
            [...currentState.Deduction, ...moreDeductions],
            currentState.selectedIndex,
            currentState.selectedTitle,
            _hasReachedMax,
          ));
        } else {
          emit(SingleDeductionError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) print(e);
        emit(SingleDeductionError("Error: $e"));
      }
    }
  }

  void _onSelectSingleDeduction(
      SelectSingleDeduction event, Emitter<SingleDeductionState> emit) {
    if (state is SingleDeductionSuccess) {
      final currentState = state as SingleDeductionSuccess;
      emit(SingleDeductionSuccess(
        currentState.Deduction,
        event.selectedIndex,
        event.selectedTitle,
        currentState.isLoadingMore,
      ));
    }
  }
}
