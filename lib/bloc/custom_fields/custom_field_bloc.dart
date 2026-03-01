import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../api_helper/api.dart';
import '../../data/model/custom_field/custom_field_model.dart';
import '../../data/repositories/custom_field/custom_field_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'custom_field_event.dart';
import 'custom_field_state.dart';


class CustomFieldBloc extends Bloc<CustomFieldEvent, CustomFieldState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;
  CustomFieldBloc() : super(CustomFieldInitial()) {
    on<CustomFieldLists>(_getCustomFieldList);
    on<SelectedCustomField>(_onSelectCustomField);
    on<CustomFieldLoadMore>(_onLoadMoreCustomFieldes);
    on<SearchCustomField>(_onSearchCustomField);
    on<CreateCustomField>(_onCreateCustomField);
    on<UpdateCustomField>(_onUpdateCustomField);
    on<DeleteCustomField>(_onDeleteCustomField);
  }
  void _onDeleteCustomField(DeleteCustomField event, Emitter<CustomFieldState> emit) async {
    // if (emit is NotesSuccess) {
    final CustomField = event.CustomFieldId;

    try {
      Map<String, dynamic> result = await CustomFieldRepo().deleteCustomField(
        id: CustomField,
        token: true,
      );
      if (result['error'] == false) {

        emit(CustomFieldDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((CustomFieldDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(CustomFieldError(e.toString()));
    }
    // }
  }
  void _onUpdateCustomField(UpdateCustomField event, Emitter<CustomFieldState> emit) async {
    if (state is CustomFieldSuccess) {
      final model = event.customModel;

      emit(CustomFieldEditLoading());

      try {
        Map<String, dynamic> updatedProject = await CustomFieldRepo().updateCustomField(
          id: model!.id!,
            module: model.module,
            fieldLabel: model.fieldLabel,
            fieldType: model.fieldType,
            required: model.required=="1" ? true:false,
            showInTable: model.showInTable=="1" ? true:false,
            options:model.options
        );

        if (updatedProject['error'] == false) {
          emit(CustomFieldEditSuccess());
        } else {
          flutterToastCustom(msg: updatedProject['message']);
          emit(CustomFieldEditError(updatedProject['message']));
        }
      } catch (e) {
        print('Error while updating CustomField: $e');
      }
    }
  }

  Future<void> _onCreateCustomField(
      CreateCustomField event, Emitter<CustomFieldState> emit) async {
    try {
      emit(CustomFieldCreateLoading());
      var model = event.customModel;
CustomFieldModel customModel = CustomFieldModel(
    module: model!.module,
    fieldLabel: model.fieldLabel,
    fieldType: model.fieldType,
    required: model.required,
    showInTable: model.showInTable,
    options:model.options
);
      var result = await CustomFieldRepo().createCustomField(customModel: customModel

      );

      if (result['error'] == false) {
        emit(CustomFieldCreateSuccess());
      }
      if (result['error'] == true) {
        emit(CustomFieldCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((CustomFieldError("Error: $e")));
    }
  }

  Future<void> _onSearchCustomField(
      SearchCustomField event, Emitter<CustomFieldState> emit) async {
    try {
      List<CustomFieldModel> CustomFields = [];
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await  CustomFieldRepo().getCustomFieldList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          );
      CustomFields = List<CustomFieldModel>.from(
          result['data'].map((projectData) => CustomFieldModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =CustomFields.length >= result['total'];
      if (result['error'] == false) {
        emit(CustomFieldSuccess(CustomFields, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(CustomFieldError(result['message']));
      }
    } on ApiException catch (e) {
      emit(CustomFieldError("Error: $e"));
    }
  }
  Future<void> _getCustomFieldList(
      CustomFieldLists event, Emitter<CustomFieldState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<CustomFieldModel> priorities = [];
      emit(CustomFieldLoading());
      Map<String, dynamic> result = await CustomFieldRepo().getCustomFieldList(
        offset: _offset,
        limit: _limit,
      );

      priorities = List<CustomFieldModel>.from(
          result['data'].map((projectData) => CustomFieldModel.fromJson(projectData)));

      // Increment offset by limit after each fetch
      _offset += _limit;

      _hasReachedMax = priorities.length >= result['total'];

      if (result['error'] == false) {
        emit(CustomFieldSuccess(priorities, -1, '', _hasReachedMax));
      } else if (result['error'] == true) {
        emit(CustomFieldError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CustomFieldError("Error: $e"));
    }
  }


  Future<void> _onLoadMoreCustomFieldes(
      CustomFieldLoadMore event, Emitter<CustomFieldState> emit) async {
    if (state is CustomFieldSuccess && !_isFetching) {
      final currentState = state as CustomFieldSuccess;

      // Set the fetching flag to true to prevent further requests during this one
      _isFetching = true;


      try {
        // Fetch more CustomFieldes from the repository
        Map<String, dynamic> result = await CustomFieldRepo().getCustomFieldList(
            limit: _limit, offset: _offset, search: event.searchQuery,);

        // Convert the fetched data into a list of CustomFieldes
        List<CustomFieldModel> moreCustomFieldes = List<CustomFieldModel>.from(
            result['data'].map((projectData) => CustomFieldModel.fromJson(projectData)));

        // Only update the offset if new data is received
        if (moreCustomFieldes.isNotEmpty) {
          _offset += _limit; // Increment by _limit (which is 15)
        }

        // Check if we've reached the total number of CustomFieldes
        bool hasReachedMax = (currentState.CustomField.length + moreCustomFieldes.length) >= result['total'];

        if (result['error'] == false) {
          // Emit the new state with the updated list of CustomFieldes
          emit(CustomFieldSuccess(
            [...currentState.CustomField, ...moreCustomFieldes],
            currentState.selectedIndex,
            currentState.selectedTitle,
            hasReachedMax,
          ));
        } else {
          emit(CustomFieldError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        if (kDebugMode) {
          print("API Exception: $e");
        }
        emit(CustomFieldError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {
          print("Unexpected error: $e");
        }
        emit(CustomFieldError("Unexpected error occurred."));
      }

      // Reset the fetching flag after the request is completed
      _isFetching = false;
    }
  }





  void _onSelectCustomField(SelectedCustomField event, Emitter<CustomFieldState> emit) {
    if (state is CustomFieldSuccess) {
      final currentState = state as CustomFieldSuccess;
      emit(CustomFieldSuccess(currentState.CustomField, event.selectedIndex,
          event.selectedTitle, false));
    }
  }
}
