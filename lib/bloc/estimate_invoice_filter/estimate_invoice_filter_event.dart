abstract class EstimateInvoiceFilterCountEvent {}

class EstimateInvoiceUpdateFilterCount extends EstimateInvoiceFilterCountEvent {
  final String filterType;
  final bool isSelected;
  EstimateInvoiceUpdateFilterCount({required this.filterType, required this.isSelected});
}

class EstimateInvoiceResetFilterCount extends EstimateInvoiceFilterCountEvent {}

class SetClients extends EstimateInvoiceFilterCountEvent {
  final List<int> clientIds;
  SetClients({List<int>? clientIds}) : clientIds = clientIds ?? [];
}

class SetTypes extends EstimateInvoiceFilterCountEvent {
  final List<String> typeIds;
  SetTypes({List<String>? typeIds}) : typeIds = typeIds ?? [];
}

class SetUserCreator extends EstimateInvoiceFilterCountEvent {
  final List<int> userCreatorIds;
  SetUserCreator({List<int>? userCreatorIds}) : userCreatorIds = userCreatorIds ?? [];
}

class SetClientCreator extends EstimateInvoiceFilterCountEvent {
  final List<int> clientCreatorIds;
  SetClientCreator({List<int>? clientCreatorIds}) : clientCreatorIds = clientCreatorIds ?? [];
}

class SetDateEstimate extends EstimateInvoiceFilterCountEvent {
  final String fromDate;
  final String toDate;
  SetDateEstimate({this.fromDate = "", this.toDate = ""});
}
