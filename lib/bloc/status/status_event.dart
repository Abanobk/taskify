import 'package:equatable/equatable.dart';

abstract class StatusEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatusList extends StatusEvent {
  // final int offset;
  // final int limit;

  StatusList();
  @override
  List<Object> get props => [];
}

class SearchStatus extends StatusEvent {
  final String searchQuery;
  // final int limit;

  SearchStatus(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}

class StatusLoadMore extends StatusEvent {
  final String searchQuery;
  // final int limit;

  StatusLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}

class SelectedStatus extends StatusEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedStatus(this.selectedIndex, this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex, selectedTitle];
}

class CreateStatus extends StatusEvent {
  final String title;
  final String color;

  final List<int>? roleId;

  CreateStatus(
      {required this.title,
      required this.color,

        this.roleId,});
  @override
  List<Object> get props => [title, color,  roleId ??[]];
}

class DeleteStatus extends StatusEvent {
  final int statusId;

  DeleteStatus(this.statusId );

  @override
  List<Object?> get props => [statusId];
}

class UpdateStatus extends StatusEvent {
  final int id;
  final String title;
  final String color;
  final List<int>? roleId;

  UpdateStatus(
      {
        required  this.id,
        required this.title,
        required this.color,
        this.roleId
      });
  @override
  List<Object> get props => [
    id,

    title, color,
    roleId ??[]
  ];
}
