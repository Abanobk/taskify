import 'package:equatable/equatable.dart';

import '../../data/model/tags/tag_model.dart';

abstract class TagMultiState extends Equatable{
  @override
  List<Object?> get props => [];
}

class TagMultiInitial extends TagMultiState {}

class TagMultiLoading extends TagMultiState {}

class TagMultiSuccess extends TagMultiState {
  final List<TagsModel> tagMulti;
  final List<int> selectedIndices;
  final List<String> selectedTagMultinames;
  final bool isLoadingMore;

  TagMultiSuccess({
    required this.tagMulti,
    this.selectedIndices = const [],
    this.selectedTagMultinames = const [],
    this.isLoadingMore = false,
  });
}

class TagMultiPaginated extends TagMultiState {
  final List<TagsModel> tagMulti;
  final bool hasReachedMax;

  TagMultiPaginated({
    required this.tagMulti,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [tagMulti, hasReachedMax];
}

class TagMultiSuccessCreate extends TagMultiState {


  TagMultiSuccessCreate();

  @override
  List<Object> get props => [];
}

class TagMultiError extends TagMultiState {
  final String errorMessage;
  TagMultiError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagMultiCreateError extends TagMultiState {
  final String errorMessage;

  TagMultiCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagMultiEditError extends TagMultiState {
  final String errorMessage;

  TagMultiEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagMultiEditSuccess extends TagMultiState {
  TagMultiEditSuccess();
  @override
  List<Object> get props => [];
}
class TagMultiCreateSuccess extends TagMultiState {
  TagMultiCreateSuccess();
  @override
  List<Object> get props => [];
}

class TagMultiDeleteError extends TagMultiState {
  final String errorMessage;

  TagMultiDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TagMultiDeleteSuccess extends TagMultiState {
  TagMultiDeleteSuccess();
  @override
  List<Object> get props => [];
}