import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/allowance_single/single_allowance_event.dart';
import 'package:taskify/bloc/allowance_single/single_allowance_state.dart';
import 'package:taskify/data/model/allowance.dart';
import '../../data/repositories/Allowance/Allowance_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class SingleAllowanceBloc extends Bloc<SingleAllowanceEvent, SingleAllowanceState> {
  int _offset = 0;
  final int _limit = 15;
  bool _hasReachedMax = false;

  SingleAllowanceBloc() : super(SingleAllowanceInitial()) {
    on<SingleAllowanceList>(_getSingleAllowanceList);
    on<SelectSingleAllowance>(_onSelectSingleAllowance);
    on<SingleAllowanceLoadMore>(_onLoadMoreSingleAllowances);
  }

  Future<void> _getSingleAllowanceList(
      SingleAllowanceList event, Emitter<SingleAllowanceState> emit) async {
    try {
      emit(SingleAllowanceLoading());
      _offset = 0; // Reset offset
      _hasReachedMax = false;

      final result = await AllowancesRepo().allowanceList(

        offset: _offset,
        limit: _limit,
      );

      if (result['error'] == false) {
        final Allowances = List<AllowanceModel>.from(result['data']
            .map((AllowanceJson) => AllowanceModel.fromJson(AllowanceJson)));

        _offset += Allowances.length;
        _hasReachedMax = Allowances.length < _limit;

        emit(SingleAllowanceSuccess(Allowances, -1, '', _hasReachedMax));
      } else {
        emit(SingleAllowanceError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(SingleAllowanceError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreSingleAllowances(
      SingleAllowanceLoadMore event, Emitter<SingleAllowanceState> emit) async {
    if (state is SingleAllowanceSuccess && !_hasReachedMax) {
      final currentState = state as SingleAllowanceSuccess;
      try {
        final result = await AllowancesRepo().allowanceList(
          offset: _offset,
          limit: _limit,
        );

        if (result['error'] == false) {
          final moreAllowances = List<AllowanceModel>.from(result['data']
              .map((AllowanceJson) => AllowanceModel.fromJson(AllowanceJson)));

          _offset += moreAllowances.length;
          _hasReachedMax = moreAllowances.length < _limit;

          emit(SingleAllowanceSuccess(
            [...currentState.Allowance, ...moreAllowances],
            currentState.selectedIndex,
            currentState.selectedTitle,
            _hasReachedMax,
          ));
        } else {
          emit(SingleAllowanceError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) print(e);
        emit(SingleAllowanceError("Error: $e"));
      }
    }
  }

  void _onSelectSingleAllowance(
      SelectSingleAllowance event, Emitter<SingleAllowanceState> emit) {
    if (state is SingleAllowanceSuccess) {
      final currentState = state as SingleAllowanceSuccess;
      emit(SingleAllowanceSuccess(
        currentState.Allowance,
        event.selectedIndex,
        event.selectedTitle,
        currentState.isLoadingMore,
      ));
    }
  }
}
