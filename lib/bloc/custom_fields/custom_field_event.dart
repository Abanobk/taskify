
import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/custom_field/custom_field_model.dart';

abstract class CustomFieldEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomFieldLists extends CustomFieldEvent {

  // final int offset;
  // final int limit;

  CustomFieldLists();
  @override
  List<Object> get props => [];
}
class CustomFieldLoadMore extends CustomFieldEvent {
  final String searchQuery;

  CustomFieldLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedCustomField extends CustomFieldEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedCustomField(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchCustomField extends CustomFieldEvent {
  final String searchQuery;


  SearchCustomField(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreateCustomField extends CustomFieldEvent {
  final CustomFieldModel? customModel;

  // final String? module;
  // final String? fieldLabel;
  // final String? fieldType;
  // final bool? required;
  // final bool? showInTable;
  // final List<String>? options;



  CreateCustomField({

    this.customModel,


  });

  @override
  List<Object?> get props => [
    customModel
    // module,
    // fieldType,
    // fieldLabel,
    // required,
    // showInTable,options
  ];
}


class DeleteCustomField extends CustomFieldEvent {
  final int CustomFieldId;

  DeleteCustomField(this.CustomFieldId );

  @override
  List<Object?> get props => [CustomFieldId];
}

class UpdateCustomField extends CustomFieldEvent {
  final CustomFieldModel? customModel;
  // final int id;
  // final String? module;
  // final String? fieldLabel;
  // final String? fieldType;
  // final bool? required;
  // final bool? showInTable;
  // final List<String>? options;

  UpdateCustomField({
    required this.customModel,

  });

  @override
  List<Object?> get props => [
customModel
  ];
}

