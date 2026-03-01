class ChartDataModel {
  final String totalIncome;
  final String totalExpenses;
  final String profitOrLoss;
  final List<Invoice> invoices;
  final List<Expense> expenses;

  ChartDataModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.profitOrLoss,
    required this.invoices,
    required this.expenses,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      totalIncome: json['total_income'],
      totalExpenses: json['total_expenses'],
      profitOrLoss: json['profit_or_loss'],
      invoices: (json['invoices'] as List)
          .map((item) => Invoice.fromJson(item))
          .toList(),
      expenses: (json['expenses'] as List)
          .map((item) => Expense.fromJson(item))
          .toList(),
    );
  }
}

class Invoice {
  final int id;
  final String viewRoute;
  final String amount; // Keep the amount as a string to maintain format
  final double amountValue; // Store numeric value separately
  final String fromDate;
  final String toDate;

  Invoice({
    required this.id,
    required this.viewRoute,
    required this.amount,
    required this.amountValue,
    required this.fromDate,
    required this.toDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json["id"] ?? 0,
      viewRoute: json["view_route"] ?? "",
      amount: json["amount"] ?? "", // Keep original string
      amountValue: _parseAmount(json["amount"]),
      fromDate: json["from_date"] ?? "",
      toDate: json["to_date"] ?? "",
    );
  }

  static double _parseAmount(String amount) {
    // Remove currency symbols and convert to double
    return double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }
}


class Expense {
  final int id;
  final String title;
  final String amount;
  final double amountValue;
  final String expenseDate;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.amountValue,
    required this.expenseDate,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      amount: json["amount"] ?? "", // Keep formatted amount
      amountValue: _parseAmount(json["amount"]),
      expenseDate: json["expense_date"] ?? "",
    );
  }

  static double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }
}