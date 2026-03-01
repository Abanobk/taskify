
import 'package:equatable/equatable.dart';

abstract class LeadSourceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeadSourceLists extends LeadSourceEvent {

  // final int offset;
  // final int limit;

  LeadSourceLists();
  @override
  List<Object> get props => [];
}
class LeadSourceLoadMore extends LeadSourceEvent {
  final String searchQuery;

  LeadSourceLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedLeadSource extends LeadSourceEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedLeadSource(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchLeadSource extends LeadSourceEvent {
  final String searchQuery;


  SearchLeadSource(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreateLeadSource extends LeadSourceEvent {
  final String title;



  CreateLeadSource(
      {required this.title,


     });
  @override
  List<Object> get props => [title, ];
}

class DeleteLeadSource extends LeadSourceEvent {
  final int LeadSourceId;

  DeleteLeadSource(this.LeadSourceId );

  @override
  List<Object?> get props => [LeadSourceId];
}

class UpdateLeadSource extends LeadSourceEvent {
  final int id;
  final String title;


  UpdateLeadSource(
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
