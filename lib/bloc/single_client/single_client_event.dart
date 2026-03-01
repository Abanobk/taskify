
import 'package:equatable/equatable.dart';

abstract class SingleClientEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SingleClientList extends SingleClientEvent {
  // final int offset;
  // final int limit;

  SingleClientList();
  @override
  List<Object> get props => [];
}
class SingleClientLoadMore extends SingleClientEvent {}
class SelectedSingleClient extends SingleClientEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedSingleClient(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

