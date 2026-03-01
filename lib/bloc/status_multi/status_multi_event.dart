import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/model/status_model.dart';

abstract class StatusMultiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatusMultiList extends StatusMultiEvent {

  StatusMultiList();
  @override
  List<Object> get props => [];
}
class StatusMultiLoadMore extends StatusMultiEvent {
  StatusMultiLoadMore();

  @override
  List<Object?> get props => [];
}
class SelectedStatusMulti extends StatusMultiEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedStatusMulti(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleStatusMultiSelection extends StatusMultiEvent {
  final int statusMultiId;
  final String statusMultiName;

  ToggleStatusMultiSelection(this.statusMultiId, this.statusMultiName);
}
class StatusMultisCreated extends StatusMultiEvent {
  final Statuses statusMultiList;

  final File? image;
  final String? profileImage;
  // final StatusMulti StatusMulti;

  StatusMultisCreated(this.statusMultiList,this.image,this.profileImage);
  @override
  List<Object> get props => [statusMultiList];
}
class AllStatusMultisList extends StatusMultiEvent {

  AllStatusMultisList();

  @override
  List<Object> get props => [];
}
class UpdateStatusMultis extends StatusMultiEvent {
  final Statuses statusMulti;

  UpdateStatusMultis(this.statusMulti);
  @override
  List<Object> get props => [statusMulti];
}

class DeleteStatusMultis extends StatusMultiEvent {
  final int statusMultiId;

  DeleteStatusMultis(this.statusMultiId);

  @override
  List<Object?> get props => [statusMultiId];
}
class SearchStatusMultis extends StatusMultiEvent {
  final String searchQuery;

  SearchStatusMultis(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
