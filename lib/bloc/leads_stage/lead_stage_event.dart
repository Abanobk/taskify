
import 'package:equatable/equatable.dart';

abstract class LeadStageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeadStageLists extends LeadStageEvent {

  // final int offset;
  // final int limit;

  LeadStageLists();
  @override
  List<Object> get props => [];
}
class LeadStageLoadMore extends LeadStageEvent {
  final String searchQuery;

  LeadStageLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedLeadStage extends LeadStageEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedLeadStage(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchLeadStage extends LeadStageEvent {
  final String searchQuery;


  SearchLeadStage(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreateLeadStage extends LeadStageEvent {
  final String title;
  final String color;


  CreateLeadStage(
      {required this.title,
        required this.color,

     });
  @override
  List<Object> get props => [title, color];
}

class DeleteLeadStage extends LeadStageEvent {
  final int LeadStageId;

  DeleteLeadStage(this.LeadStageId );

  @override
  List<Object?> get props => [LeadStageId];
}

class UpdateLeadStage extends LeadStageEvent {
  final int id;
  final String title;
  final String color;


  UpdateLeadStage(
      {
        required  this.id,
        required this.title,
        required this.color,

      });
  @override
  List<Object> get props => [
    id,
    title,
    color,

  ];
}
