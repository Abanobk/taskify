

import 'package:equatable/equatable.dart';

abstract class SingleSelectProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class SearchSingleProject extends SingleSelectProjectEvent {
  final String searchQuery;


  SearchSingleProject(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}

class SingleProjectList extends SingleSelectProjectEvent {


  SingleProjectList();
  @override
  List<Object> get props => [];
}
class SingleProjectLoadMore extends SingleSelectProjectEvent {
  final String searchQuery;



  SingleProjectLoadMore(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class SelectSingleProject extends SingleSelectProjectEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectSingleProject(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

