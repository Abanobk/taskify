import 'package:taskify/config/end_points.dart';
import 'package:taskify/data/model/custom_field/custom_field_model.dart';
import '../../../api_helper/api_base_helper.dart';



class CustomFieldRepo {
  Future<Map<String, dynamic>> createCustomField({
    CustomFieldModel? customModel,
    String? module,
    String? fieldLabel,
    String? fieldType,
    bool? required,
    bool? showInTable,
    List<String>? options

  }) async {
    try {
      Map<String, dynamic> body = {
        if (customModel!.module != null) 'module': customModel.module,
        if (customModel.fieldLabel != null) 'field_label': customModel.fieldLabel,
        if (customModel.fieldType != null) 'field_type': customModel.fieldType,
        if (customModel.options != null) 'options': customModel.options,
        if (customModel.required != null) 'required': customModel.required,
        if (customModel.showInTable != null) 'show_in_table': customModel.showInTable,
      };

      final response = await ApiBaseHelper.formPost(
        url: createCustomFieldUrl,
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> getCustomFieldList(
      {int? limit, int? offset, String? search = "",int? id}) async {


    try {
      Map<String, dynamic> body = {};
      if (search != null) {
        body["search"] = search;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      var url = getCustomFieldUrl;
      final response = await ApiBaseHelper.getApi(
          url: url, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteCustomField({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteCustomFieldUrl/$id", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateCustomField({
    required int id,
    String? module,
    String? fieldLabel,
    String? fieldType,
    bool? required,
    bool? showInTable,
    List<String>? options
  }) async {
    try {
      Map<String, dynamic> body = {
        'id': id,
        if (module != null) 'module': module,
        if (fieldLabel != null) 'field_label': fieldLabel,
        if (fieldType != null) 'field_type': fieldType,
        if (options != null) 'options': options,
        if (required != null) 'required': required ? '1' : '0',
        if (showInTable != null) 'show_in_table': showInTable ? '1' : '0',
      };

      final response = await ApiBaseHelper.post(
        url: "$updateCustomFieldUrl/$id",
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


}

