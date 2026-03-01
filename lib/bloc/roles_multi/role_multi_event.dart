
import 'package:equatable/equatable.dart';

abstract class RoleMultiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleMultiList extends RoleMultiEvent {

  RoleMultiList();
  @override
  List<Object> get props => [];
}


class RoleMultiLoadMore extends RoleMultiEvent {
  final String search;
  RoleMultiLoadMore({required this.search});
  @override
  List<Object> get props => [search];

}
class SelectedRoleMulti extends RoleMultiEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedRoleMulti(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleRoleMultiSelection extends RoleMultiEvent {
  final int RoleMultiId;
  final String RoleMultiName;

  ToggleRoleMultiSelection(this.RoleMultiId, this.RoleMultiName);
}
class SearchRoleMulti extends RoleMultiEvent {
  final String searchQuery;

   SearchRoleMulti(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}