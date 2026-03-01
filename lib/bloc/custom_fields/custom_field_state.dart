import 'package:equatable/equatable.dart';

import '../../data/model/custom_field/custom_field_model.dart';


abstract class CustomFieldState extends Equatable{
  @override
  List<Object?> get props => [];
}

class CustomFieldInitial extends CustomFieldState {}
class  CustomFieldEditSuccessLoading extends  CustomFieldState {}
class  CustomFieldCreateSuccessLoading extends  CustomFieldState {}
class CustomFieldLoading extends CustomFieldState {}
class CustomFieldSuccess extends CustomFieldState {
  CustomFieldSuccess(this.CustomField,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<CustomFieldModel> CustomField;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [CustomField,selectedIndex!,selectedTitle,isLoadingMore];
}

class CustomFieldError extends CustomFieldState {
  final String errorMessage;
  CustomFieldError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CustomFieldEditLoading extends CustomFieldState {}
class CustomFieldCreateLoading extends CustomFieldState {}
class CustomFieldCreateSuccess extends CustomFieldState {}
class CustomFieldDeleteSuccess extends CustomFieldState {}

class CustomFieldEditSuccess extends CustomFieldState {

  CustomFieldEditSuccess();
  @override
  List<Object> get props =>
      [];
}

class CustomFieldCreateError extends CustomFieldState {
  final String errorMessage;
  CustomFieldCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CustomFieldEditError extends CustomFieldState {
  final String errorMessage;
  CustomFieldEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CustomFieldDeleteError extends CustomFieldState {
  final String errorMessage;
  CustomFieldDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
