
import 'package:equatable/equatable.dart';

abstract class TagsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TagsList extends TagsEvent {

  TagsList();
  @override
  List<Object> get props => [];
}


class TagsLoadMore extends TagsEvent {
  final String search;
  TagsLoadMore({required this.search});
  @override
  List<Object> get props => [search];

}
class SelectedTags extends TagsEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedTags(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleTagsSelection extends TagsEvent {
  final int tagsId;
  final String tagsName;

  ToggleTagsSelection(this.tagsId, this.tagsName);
}
class CreateTag extends TagsEvent {
  final String title;
  final String color;

  final List<int>? roleId;

  CreateTag(
      {required this.title,
        required this.color,

        this.roleId,});
  @override
  List<Object> get props => [title, color,  roleId ??[]];
}

class DeleteTag extends TagsEvent {
  final int TagId;

  DeleteTag(this.TagId );

  @override
  List<Object?> get props => [TagId];
}
class SearchTags extends TagsEvent {
  final String searchQuery;
  // final int limit;

  SearchTags(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class UpdateTag extends TagsEvent {
  final int id;
  final String title;
  final String color;
  final List<int>? roleId;

  UpdateTag(
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