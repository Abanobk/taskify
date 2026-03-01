import "package:equatable/equatable.dart";
import "package:taskify/data/model/finance/estimate_invoices_model.dart";

abstract class EstinateInvoicesEvent extends Equatable {
  const EstinateInvoicesEvent();
  @override
  List<Object?> get props => [];
}

class SelectEstinateInvoice extends EstinateInvoicesEvent {
  final EstimateInvoicesModel selectedInvoice;

  const SelectEstinateInvoice({required this.selectedInvoice});
}

class AmountCalculationEstinateInvoice extends EstinateInvoicesEvent {
  // final int id;
  final double quantity;
  final int itemId;

  final double rate;
  final double tax;
  final String type;

  const AmountCalculationEstinateInvoice(
      {required this.itemId,
      required this.quantity,
      required this.rate,
      required this.tax,
      required this.type});
  @override
  List<Object> get props =>
      [itemId, quantity, rate, tax, type];

}

class CreateEstinateInvoices extends EstinateInvoicesEvent {
  final String title;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final List<int> userId;
  final List<int> clientIds;
  final String token;

  const CreateEstinateInvoices(
      {required this.title,
      required this.startDate,
      required this.endDate,
      required this.startTime,
      required this.endTime,
      required this.userId,
      required this.clientIds,
      required this.token});

  @override
  List<Object> get props =>
      [title, startDate, endDate, startTime, endTime, userId, clientIds, token];
}

class EstinateInvoiceLists extends EstinateInvoicesEvent {
  final  List<String> type;
  final List<int> userCreatorId;
  final List<int> clientId;
  final List<int> clientCreatorId;
  final String dateFrom;
  final String dateTo;
  const EstinateInvoiceLists(this.type,this.userCreatorId,this.clientCreatorId,this.clientId,this.dateFrom,this.dateTo);

  @override
  List<Object?> get props => [type,userCreatorId,clientCreatorId,clientId,dateFrom,dateTo];
}

class AddEstinateInvoices extends EstinateInvoicesEvent {
  final EstimateInvoicesModel estinateInvoice;

  final List<String>? itemIds;
  final List<String>? item;
  final List<double>? quantity;
  final List<String>? unit;
  final List<String>? rate;
  final List<String>? tax;
  final List<String>? amount;

  AddEstinateInvoices(
    this.estinateInvoice, {
    this.itemIds,
    this.item,
    this.quantity,
    this.unit,
    this.rate,
    this.tax,
    this.amount,
  });

  @override
  List<Object?> get props => [
        estinateInvoice,
        itemIds,
        item,
        quantity,
        unit,
        rate,
        tax,
        amount,
      ];
}

class EstinateInvoiceUpdateds extends EstinateInvoicesEvent {
  final EstimateInvoicesModel estinateInvoice;

  final List<int>? itemIds;
  final List<String>? item;
  final List<String>? quantity;
  final List<String>? unit;
  final List<String>? rate;
  final List<String>? tax;
  final List<String>? amount;

  const EstinateInvoiceUpdateds(
    this.estinateInvoice, {
    this.itemIds,
    this.item,
    this.quantity,
    this.unit,
    this.rate,
    this.tax,
    this.amount,
  });

  @override
  List<Object?> get props => [
        estinateInvoice,
        itemIds,
        item,
        quantity,
        unit,
        rate,
        tax,
        amount,
      ];
}

class DeleteEstinateInvoices extends EstinateInvoicesEvent {
  final int EstinateInvoice;

  const DeleteEstinateInvoices(this.EstinateInvoice);

  @override
  List<Object?> get props => [EstinateInvoice];
}

class SearchEstimateInvoices extends EstinateInvoicesEvent {
  final String searchQuery;
  final  List<String> type;
  final List<int> userCreatorId;
  final List<int> clientId;
  final List<int> clientCreatorId;
  final String dateFrom;
  final String dateTo;
  const SearchEstimateInvoices(this.searchQuery,this.type,this.userCreatorId,this.clientCreatorId,this.clientId,this.dateFrom,this.dateTo);

  @override
  List<Object?> get props => [searchQuery,type,userCreatorId,clientCreatorId,clientId,dateFrom,dateTo];
}


class LoadMoreEstinateInvoices extends EstinateInvoicesEvent {
  final String searchQuery;
  final  List<String> type;
  final List<int> userCreatorId;
  final List<int> clientId;
  final List<int> clientCreatorId;
  final String dateFrom;
  final String dateTo;
  const LoadMoreEstinateInvoices(this.searchQuery,this.type,this.userCreatorId,this.clientCreatorId,this.clientId,this.dateFrom,this.dateTo);

  @override
  List<Object?> get props => [searchQuery,type,userCreatorId,clientCreatorId,clientId,dateFrom,dateTo];

}
