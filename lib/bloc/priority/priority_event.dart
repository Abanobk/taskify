
import 'package:equatable/equatable.dart';

abstract class PriorityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PriorityLists extends PriorityEvent {

  // final int offset;
  // final int limit;

  PriorityLists();
  @override
  List<Object> get props => [];
}
class PriorityLoadMore extends PriorityEvent {
  final String searchQuery;

  PriorityLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedPriority extends PriorityEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedPriority(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchPriority extends PriorityEvent {
  final String searchQuery;


  SearchPriority(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreatePriority extends PriorityEvent {
  final String title;
  final String color;


  CreatePriority(
      {required this.title,
        required this.color,

     });
  @override
  List<Object> get props => [title, color];
}

class DeletePriority extends PriorityEvent {
  final int PriorityId;

  DeletePriority(this.PriorityId );

  @override
  List<Object?> get props => [PriorityId];
}

class UpdatePriority extends PriorityEvent {
  final int id;
  final String title;
  final String color;


  UpdatePriority(
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
