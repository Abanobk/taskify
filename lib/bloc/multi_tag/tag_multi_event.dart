import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/model/tags/tag_model.dart';


abstract class TagMultiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TagMultiList extends TagMultiEvent {

  TagMultiList();
  @override
  List<Object> get props => [];
}
class TagMultiLoadMore extends TagMultiEvent {
  TagMultiLoadMore();

  @override
  List<Object?> get props => [];
}
class SelectedTagMulti extends TagMultiEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedTagMulti(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleTagMultiSelection extends TagMultiEvent {
  final int tagMultiId;
  final String tagMultiName;

  ToggleTagMultiSelection(this.tagMultiId, this.tagMultiName);
}
class TagMultisCreated extends TagMultiEvent {
  final TagsModel tagMultiList;

  final File? image;
  final String? profileImage;
  // final TagMulti TagMulti;

  TagMultisCreated(this.tagMultiList,this.image,this.profileImage);
  @override
  List<Object> get props => [tagMultiList];
}
class AllTagMultisList extends TagMultiEvent {

  AllTagMultisList();

  @override
  List<Object> get props => [];
}
class UpdateTagMultis extends TagMultiEvent {
  final TagsModel tagMulti;

  UpdateTagMultis(this.tagMulti);
  @override
  List<Object> get props => [tagMulti];
}

class DeleteTagMultis extends TagMultiEvent {
  final int tagMultiId;

  DeleteTagMultis(this.tagMultiId);

  @override
  List<Object?> get props => [tagMultiId];
}
class SearchTagMultis extends TagMultiEvent {
  final String searchQuery;

  SearchTagMultis(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
