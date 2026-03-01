
import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../data/model/priority_model.dart';


abstract class PriorityMultiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PriorityMultiList extends PriorityMultiEvent {

  PriorityMultiList();
  @override
  List<Object> get props => [];
}
class PriorityMultiLoadMore extends PriorityMultiEvent {
  PriorityMultiLoadMore();

  @override
  List<Object?> get props => [];
}
class SelectedPriorityMulti extends PriorityMultiEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedPriorityMulti(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class TogglePriorityMultiSelection extends PriorityMultiEvent {
  final int priorityMultiId;
  final String priorityMultiName;

  TogglePriorityMultiSelection(this.priorityMultiId, this.priorityMultiName);
}
class PriorityMultisCreated extends PriorityMultiEvent {
  final Priorities priorityMultiList;

  final File? image;
  final String? profileImage;
  // final PriorityMulti PriorityMulti;

  PriorityMultisCreated(this.priorityMultiList,this.image,this.profileImage);
  @override
  List<Object> get props => [priorityMultiList];
}
class AllPriorityMultisList extends PriorityMultiEvent {

  AllPriorityMultisList();

  @override
  List<Object> get props => [];
}
class UpdatePriorityMultis extends PriorityMultiEvent {
  final Priorities priorityMulti;

  UpdatePriorityMultis(this.priorityMulti);
  @override
  List<Object> get props => [priorityMulti];
}

class DeletePriorityMultis extends PriorityMultiEvent {
  final int priorityMultiId;

  DeletePriorityMultis(this.priorityMultiId);

  @override
  List<Object?> get props => [priorityMultiId];
}
class SearchPriorityMultis extends PriorityMultiEvent {
  final String searchQuery;

  SearchPriorityMultis(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
