

import 'package:equatable/equatable.dart';

abstract class SingleUserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SingleUserList extends SingleUserEvent {


  SingleUserList();
  @override
  List<Object> get props => [];
}
class SingleUserLoadMore extends SingleUserEvent {}

class SearchSingleUser extends SingleUserEvent {
  final String searchQuery;


  SearchSingleUser(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectSingleUser extends SingleUserEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectSingleUser(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

