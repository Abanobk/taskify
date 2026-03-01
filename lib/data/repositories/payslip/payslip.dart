import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';

class PayslipRepo {
  Future<Map<String, dynamic>> createPayslip({
    required int userId,
    required String month,
    required double basicSalary,
    required int workingDays,
    required int lopDays,
    required int paidDays,
    required double bonus,
    required double incentives,
    required int leaveDeduction,
    required int otHours,
    required double otRate,
    required double otPayment,
    required int totalAllowance,
    required int totalDeductions,
    required double totalEarnings,
    required double netPay,
    required int? paymentMethodId,
    required String paymentDate,
    required int status,
    required String note,
    required List<int> allowances,
    required List<int> deductions,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": userId,
        "month": month,
        "basic_salary": basicSalary,
        "working_days": workingDays,
        "lop_days": lopDays,
        "paid_days": paidDays,
        "bonus": bonus,
        "incentives": incentives,
        "leave_deduction": leaveDeduction,
        "ot_hours": otHours,
        "ot_rate": otRate,
        "ot_payment": otPayment,
        "total_allowance": totalAllowance,
        "total_deductions": totalDeductions,
        "total_earnings": totalEarnings,
        "net_pay": netPay,
        if (paymentMethodId != 0) "payment_method_id": paymentMethodId,
        "payment_date": paymentDate,
        "status": status,
        "note": note,
        "allowances": allowances,
        "deductions": deductions,
        "isApi": true,
      });

      final response = await ApiBaseHelper.formPost(
        url: createPayslipUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> PayslipList(
      {int? limit, int? offset, String? search = "", String? type}) async {
    try {
      print("dfgvhbjkm,lqsa $limit");
      print("dfgvhbjkm,l$offset");
      Map<String, dynamic> body = {};
      if (search != null) {
        body["search"] = search;
      }
      if (type != null) {
        body["types[]"] = type;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      print("dfgvhbjkm,l rt $body");
      final response = await ApiBaseHelper.getApi(
          url: payslipUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deletePayslip({
    required int id,
    required bool token,
  }) async {
    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deletePayslipUrl/$id", useAuthToken: true, body: {});

      // for (var row in rows) {
      //   Payslip.add(PayslipModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updatePayslip({
    required int id,
    required int userId,
    required String month,
    required double basicSalary,
    required int workingDays,
    required int lopDays,
    required int paidDays,
    required double bonus,
    required double incentives,
    required int leaveDeduction,
    required int otHours,
    required double otRate,
    required double otPayment,
    required int totalAllowance,
    required int totalDeductions,
    required double totalEarnings,
    required double netPay,
    required int paymentMethodId,
    required String paymentDate,
    required int status,
    required String note,
    required List<int> allowances,
    required List<int> deductions,
  }) async {
    try {
      Map<String, dynamic> body = {
        "id": id,
        "user_id": userId,
        "month": month,
        "basic_salary": basicSalary,
        "working_days": workingDays,
        "lop_days": lopDays,
        "paid_days": paidDays,
        "bonus": bonus,
        "incentives": incentives,
        "leave_deduction": leaveDeduction,
        "ot_hours": otHours,
        "ot_rate": otRate,
        "ot_payment": otPayment,
        "total_allowance": totalAllowance,
        "total_deductions": totalDeductions,
        "total_earnings": totalEarnings,
        "net_pay": netPay,
        "payment_method_id": paymentMethodId,
        "payment_date": paymentDate,
        "status": status,
        "note": note,
        "allowances": allowances,
        "deductions": deductions,
        "isApi": true,
      };

      final response = await ApiBaseHelper.post(
        url: updatePayslipUrl,
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
