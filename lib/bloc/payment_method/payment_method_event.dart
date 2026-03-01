
import 'package:equatable/equatable.dart';

abstract class PaymentMethdEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentMethdLists extends PaymentMethdEvent {

  // final int offset;
  // final int limit;

  PaymentMethdLists();
  @override
  List<Object> get props => [];
}
class PaymentMethdLoadMore extends PaymentMethdEvent {
  final String searchQuery;

  PaymentMethdLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedPaymentMethd extends PaymentMethdEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedPaymentMethd(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchPaymentMethd extends PaymentMethdEvent {
  final String searchQuery;


  SearchPaymentMethd(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreatePaymentMethd extends PaymentMethdEvent {
  final String title;


  CreatePaymentMethd(
      {required this.title,


     });
  @override
  List<Object> get props => [title, ];
}

class DeletePaymentMethd extends PaymentMethdEvent {
  final int PaymentMethdId;

  DeletePaymentMethd(this.PaymentMethdId );

  @override
  List<Object?> get props => [PaymentMethdId];
}

class UpdatePaymentMethd extends PaymentMethdEvent {
  final int id;
  final String title;



  UpdatePaymentMethd(
      {
        required  this.id,
        required this.title,


      });
  @override
  List<Object> get props => [
    id,
    title,

  ];
}
