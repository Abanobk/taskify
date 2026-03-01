import 'package:equatable/equatable.dart';

abstract class PayslipEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PayslipCreated extends PayslipEvent {
  final int userId;
  final String month;
  final double basicSalary;
  final int workingDays;
  final int lopDays;
  final int paidDays;
  final double bonus;
  final double incentives;
  final int leaveDeduction;
  final int otHours;
  final double otRate;
  final double otPayment;
  final int totalAllowance;
  final int totalDeductions;
  final double totalEarnings;
  final double netPay;
  final int? paymentMethodId;
  final String? paymentDate;
  final int status;
  final String note;
  final List<int> allowances;
  final List<int> deductions;

  PayslipCreated({
    required this.userId,
    required this.month,
    required this.basicSalary,
    required this.workingDays,
    required this.lopDays,
    required this.paidDays,
    required this.bonus,
    required this.incentives,
    required this.leaveDeduction,
    required this.otHours,
    required this.otRate,
    required this.otPayment,
    required this.totalAllowance,
    required this.totalDeductions,
    required this.totalEarnings,
    required this.netPay,
    required this.paymentMethodId,
    required this.paymentDate,
    required this.status,
    required this.note,
    required this.allowances,
    required this.deductions,
  });

  @override
  List<Object> get props => [
    userId,
    month,
    basicSalary,
    workingDays,
    lopDays,
    paidDays,
    bonus,
    incentives,
    leaveDeduction,
    otHours,
    otRate,
    otPayment,
    totalAllowance,
    totalDeductions,
    totalEarnings,
    netPay,
    paymentMethodId!,
    paymentDate!,
    status,
    note,
    allowances,
    deductions,
  ];
}




class AllPayslipListOnPayslip extends PayslipEvent {
  final List<int>? userId;
  final List<int>? clientId;
  final List<int>? priorityId;
  final List<int>? statusId;
  final List<int>? projectId;
  final String? fromDate;
  final String? toDate;
  final int? id;
  final bool isSubPayslip;
  AllPayslipListOnPayslip(
      {this.id,
      this.projectId,
      this.clientId,
      this.userId,
      this.statusId,
      this.priorityId,
      this.isSubPayslip = false,
      this.fromDate,
      this.toDate});

  @override
  List<Object?> get props =>
      [id, projectId, clientId, userId, statusId, priorityId, fromDate, toDate];
}

class AllPayslipList extends PayslipEvent {
  AllPayslipList();

  @override
  List<Object> get props => [];
}


class UpdatePayslip extends PayslipEvent {
  final int id;
  final int userId;
  final String month;
  final double basicSalary;
  final int workingDays;
  final int lopDays;
  final int paidDays;
  final double bonus;
  final double incentives;
  final int leaveDeduction;
  final int otHours;
  final double otRate;
  final double otPayment;
  final int totalAllowance;
  final int totalDeductions;
  final double totalEarnings;
  final double netPay;
  final int paymentMethodId;
  final String? paymentDate;
  final int status;
  final String note;
  final List<int> allowances;
  final List<int> deductions;

  UpdatePayslip({
    required this.id,
    required this.userId,
    required this.month,
    required this.basicSalary,
    required this.workingDays,
    required this.lopDays,
    required this.paidDays,
    required this.bonus,
    required this.incentives,
    required this.leaveDeduction,
    required this.otHours,
    required this.otRate,
    required this.otPayment,
    required this.totalAllowance,
    required this.totalDeductions,
    required this.totalEarnings,
    required this.netPay,
    required this.paymentMethodId,
    required this.paymentDate,
    required this.status,
    required this.note,
    required this.allowances,
    required this.deductions,
  });

  @override
  List<Object> get props => [
    id,
    userId,
    month,
    basicSalary,
    workingDays,
    lopDays,
    paidDays,
    bonus,
    incentives,
    leaveDeduction,
    otHours,
    otRate,
    otPayment,
    totalAllowance,
    totalDeductions,
    totalEarnings,
    netPay,
    paymentMethodId,
    paymentDate!,
    status,
    note,
    allowances,
    deductions,
  ];
}


class DeletePayslip extends PayslipEvent {
  final int PayslipId;

  DeletePayslip(this.PayslipId);

  @override
  List<Object?> get props => [PayslipId];
}

class SearchPayslips extends PayslipEvent {
  final String searchQuery;
  final int? isFav;
  final bool? isSubPayslip;

  SearchPayslips(this.searchQuery, {this.isFav, this.isSubPayslip});

  @override
  List<Object?> get props => [searchQuery, isFav];
}

class LoadMore extends PayslipEvent {
  final List<int>? userId;
  final List<int>? clientId;
  final List<int>? priorityId;
  final List<int>? statusId;
  final List<int>? projectId;
  final String? fromDate;
  final String? toDate;
  final String? searchQuery;
  final int? id;
  final int? isFav;
  LoadMore(
      {this.id,
      this.projectId,
      this.clientId,
      this.userId,
      this.statusId,
      this.priorityId,
      this.fromDate,
      this.toDate,
      this.searchQuery,
      this.isFav});

  @override
  List<Object?> get props => [
        id,
        projectId,
        searchQuery,
        clientId,
        userId,
        statusId,
        priorityId,
        fromDate,
        toDate
      ];
}


