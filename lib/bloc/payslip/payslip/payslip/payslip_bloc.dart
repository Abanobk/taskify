import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:taskify/bloc/payslip/payslip/payslip/payslip_event.dart';
import 'package:taskify/bloc/payslip/payslip/payslip/payslip_state.dart';
import 'package:taskify/data/model/payslip/payslip_model.dart';

import '../../../../api_helper/api.dart';
import '../../../../data/repositories/payslip/payslip.dart';
import '../../../../utils/widgets/toast_widget.dart';


class PayslipBloc extends Bloc<PayslipEvent, PayslipState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  PayslipBloc() : super(PayslipInitial()) {
    on<PayslipCreated>(_onCreatePayslip);
    on<AllPayslipList>(_getAllPayslip);
    on<AllPayslipListOnPayslip>(_getAllPayslipListOnProject);
    on<UpdatePayslip>(_onUpdatePayslip);
    on<SearchPayslips>(_onSearchPayslip);
    on<DeletePayslip>(_onDeletePayslips);
    on<LoadMore>(_onLoadMorePayslip);

  }
  Future<void> _onCreatePayslip(PayslipCreated event, Emitter<PayslipState> emit) async {
    try {
      emit(PayslipCreateSuccessLoading());

      Map<String, dynamic> result = await PayslipRepo().createPayslip(
        userId: event.userId,
        month: event.month,
        basicSalary: event.basicSalary,
        workingDays: event.workingDays,
        lopDays: event.lopDays,
        paidDays: event.paidDays,
        bonus: event.bonus,
        incentives: event.incentives,
        leaveDeduction: event.leaveDeduction,
        otHours: event.otHours,
        otRate: event.otRate,
        otPayment: event.otPayment,
        totalAllowance: event.totalAllowance,
        totalDeductions: event.totalDeductions,
        totalEarnings: event.totalEarnings,
        netPay: event.netPay,
        paymentMethodId: event.paymentMethodId??0,
        paymentDate: event.paymentDate??"",
        status: event.status,
        note: event.note,
        allowances: event.allowances,
        deductions: event.deductions,
      );

      if (result['error'] == false) {
        emit(PayslipCreateSuccess());
      } else {
        emit(PayslipCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(PayslipError("Error: $e"));
    }
  }



  Future<void> _getAllPayslipListOnProject(
      AllPayslipListOnPayslip event, Emitter<PayslipState> emit) async {
    try {
      List<PayslipModel> Payslip = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      Map<String, dynamic> result = {};
      emit(PayslipLoading());
      print("njfvkml,c ${event.id}");
      _offset = 0;
      result = await PayslipRepo().PayslipList(
          // subPayslip: event.isSubPayslip,
          limit: _limit,
          offset: _offset,
          search: '',
          // token: true,
          // id: event.id,
          // userId: event.userId,
          // clientId: event.clientId,
          // projectId: event.projectId,
          // statusId: event.statusId,
          // priorityId: event.priorityId,
          // fromDate: event.fromDate,
          // toDate: event.toDate);
      );
      Payslip = List<PayslipModel>.from(
          result['data'].map((projectData) => PayslipModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = Payslip.length < _limit;

      if (result['error'] == false) {
        emit(PayslipPaginated(Payslip: Payslip, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((PayslipError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PayslipError("Error: $e")));
    }
  }

  Future<void> _onSearchPayslip(SearchPayslips event, Emitter<PayslipState> emit) async {
    try {
      List<PayslipModel> Payslip = [];
      emit(PayslipLoading());
      _offset = 0;
      _hasReachedMax = false;

      Map<String, dynamic> result = await PayslipRepo().PayslipList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
         );
      Payslip = List<PayslipModel>.from(
          result['data'].map((projectData) => PayslipModel.fromJson(projectData)));
      bool hasReachedMax = Payslip.length < _limit;
      if (result['error'] == false) {
        emit(PayslipPaginated(Payslip: Payslip, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((PayslipError(result['message'])));
      }
    } on ApiException catch (e) {
      emit(PayslipError("Error: $e"));
    }
  }

  Future<void> _getAllPayslip(AllPayslipList event, Emitter<PayslipState> emit) async {
    try {
      List<PayslipModel> Payslip = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(PayslipLoading());
      Map<String, dynamic> result = await PayslipRepo()
          .PayslipList(limit: _limit, offset: _offset, search: '',);
      Payslip = List<PayslipModel>.from(
          result['data'].map((projectData) => PayslipModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = Payslip.length < _limit;
      if (result['error'] == false) {
        emit(PayslipPaginated(Payslip: Payslip, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((PayslipError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PayslipError("Error: $e")));
    }
  }



  void _onDeletePayslips(DeletePayslip event, Emitter<PayslipState> emit) async {
    final int id = event.PayslipId;
    try {
      Map<String, dynamic> result = await PayslipRepo().deletePayslip(
        id: id,
        token: true,
      );
      if (result['error'] == false) {
        emit(PayslipDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((PayslipDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(PayslipError(e.toString()));
    }
  }

  void _onUpdatePayslip(UpdatePayslip event, Emitter<PayslipState> emit) async {
    if (state is PayslipPaginated) {
      emit(PayslipEditSuccessLoading());
      try {
        Map<String, dynamic> result = await PayslipRepo().updatePayslip(
          id: event.id,
          userId: event.userId,
          month: event.month,
          basicSalary: event.basicSalary,
          workingDays: event.workingDays,
          lopDays: event.lopDays,
          paidDays: event.paidDays,
          bonus: event.bonus,
          incentives: event.incentives,
          leaveDeduction: event.leaveDeduction,
          otHours: event.otHours,
          otRate: event.otRate,
          otPayment: event.otPayment,
          totalAllowance: event.totalAllowance,
          totalDeductions: event.totalDeductions,
          totalEarnings: event.totalEarnings,
          netPay: event.netPay,
          paymentMethodId: event.paymentMethodId,
          paymentDate: event.paymentDate??"",
          status: event.status,
          note: event.note,
          allowances: event.allowances,
          deductions: event.deductions,
        );

        if (result['error'] == false) {
          emit(PayslipEditSuccess());
          add(AllPayslipList());
        } else {
          emit(PayslipEditError(result['message']));
          flutterToastCustom(msg: result['message']);
          add(AllPayslipList());
        }
      } catch (e) {
        print(e.toString());
        emit(PayslipEditError("Update failed: $e"));
      }
    }
  }


  Future<void> _onLoadMorePayslip(LoadMore event, Emitter<PayslipState> emit) async {
    if (state is PayslipPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Start loading
      try {
        final currentState = state as PayslipPaginated;
        final updatedNotes = List<PayslipModel>.from(currentState.Payslip);

        // Fetch additional Payslips
        Map<String, dynamic> result = await PayslipRepo().PayslipList(
            limit: _limit,
            offset: _offset,
            search: event.searchQuery,
            // token: true,
            // userId: event.userId,
            // clientId: event.clientId,
            // projectId: event.projectId,
            // statusId: event.statusId,
            // priorityId: event.priorityId,
            // fromDate: event.fromDate,
            // toDate: event.toDate,
            // isFav: event.isFav
        );

        if (result['error'] == false) {
          final additionalNotes = List<PayslipModel>.from(
            result['data'].map((projectData) => PayslipModel.fromJson(projectData)),
          );

          // Increment the offset only if new items are fetched
          if (additionalNotes.isNotEmpty) {
            _offset += additionalNotes.length; // Update offset
          }
          if (updatedNotes.length >= result['total']) {
            _hasReachedMax = true;
          } else {
            _hasReachedMax = false;
          }

          updatedNotes.addAll(additionalNotes);
        } else if (result['error'] == true) {
          emit(PayslipError(result['message']));
          flutterToastCustom(msg: result['message']);
        }

        emit(PayslipPaginated(Payslip: updatedNotes, hasReachedMax: _hasReachedMax));
      } on ApiException catch (e) {
        emit(PayslipError("Error: $e"));
      } finally {
        _isLoading = false; // End loading
      }
    }
  }


}
