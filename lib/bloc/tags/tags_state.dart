import 'package:equatable/equatable.dart';

import '../../data/model/tags/tag_model.dart';



abstract class TagsState extends Equatable{
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}
class TagsLoading extends TagsState {}
class TagCreateLoading extends TagsState {}
class TagCreateSuccess extends TagsState {}
class TagEditLoading extends TagsState {}
class TagDeleteSuccess extends TagsState {}
class TagsSuccess extends TagsState {
  final List<TagsModel> tag;
  final List<int> selectedIndices;
  final List<String> selectedTagsnames;
  final bool isLoadingMore;

  TagsSuccess({
    required this.tag,
    this.selectedIndices = const [],
    this.selectedTagsnames = const [],
    this.isLoadingMore = false,
  });
}
class TagEditSuccess extends TagsState {
  final List<TagsModel> tag;
  final List<int> selectedIndices;
  final List<String> selectedTagsnames;
  final bool isLoadingMore;

  TagEditSuccess({
    required this.tag,
    this.selectedIndices = const [],
    this.selectedTagsnames = const [],
    this.isLoadingMore = false,
  });
}


class TagsError extends TagsState {
  final String errorMessage;
  TagsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagDeleteError extends TagsState {
  final String errorMessage;
  TagDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagEditError extends TagsState {
  final String errorMessage;
  TagEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagCreateError extends TagsState {
  final String errorMessage;
  TagCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
