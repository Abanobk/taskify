import 'package:taskify/config/end_points.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../../api_helper/api_base_helper.dart';
import '../../model/workspace/workspace_model.dart';

class WorkspaceRepo {
  Future<Map<String, dynamic>> workspaceList(
      {int? limit, int? offset, String? search = "",int? id}) async {
    try {
      Map<String, dynamic> body = {"limit": limit, "offset": offset};
      if (search != null) {
        body["search"] = search;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      final Map<String, dynamic> response;
      if(id != null ){
         response = await ApiBaseHelper.getApi(
            url: "$getWorkSpaceUrl/$id", useAuthToken: true, params: body);

      }else{
       response = await ApiBaseHelper.getApi(
          url: getWorkSpaceUrl, useAuthToken: true, params: body);}

      return response;
    } catch (error) {
      return {
        "error": true,
        "message": "Unexpected error occurred."
      };
    }
  }

  Future<void> workspaceRemove({
    required int id,
  }) async {
    try {
      final response = await ApiBaseHelper.delete(
        url: "$removeWorkSpaceUrl/$id",
        useAuthToken: true,
        body: {},
      );
      print("ERRO SEEE ${response['error']}");
      print("ERRO SEEE ${response['message']}");
      if (response['error'] == true) {
        flutterToastCustom(msg: "${response['message']}");
      }
      return;
    } catch (e, stacktrace) {
      print('Exception: $e');
      print('Stacktrace: $stacktrace');
      return;
    }
  }

  Future<void> removeFromWorkspace({
    required bool token,
  }) async {
    try {
      await ApiBaseHelper.delete(
          url: removeMeWorkSpaceUrl, useAuthToken: true, body: {});
    } catch (e, stacktrace) {
      print('Exception: $e');
      print('Stacktrace: $stacktrace');
    }
  }

  Future<Map<String, dynamic>> createWorkspace({
    required WorkspaceModel work,
  }) async {
    try {
      Map<String, dynamic> body = work.toJson();
      print('Request Body: ${work.toJson()}');

      final response = await ApiBaseHelper.post(
        url: createWorkSpaceUrl,
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getWorkspacePrimary({
    required int id,
    required int defaultPrimary
  }) async {
    try {
      Map<String, dynamic> body = {
        "is_default": defaultPrimary,
      };
      final response = await ApiBaseHelper.patch(
        url: "$getWorkSpaceUrl/$id/default",
        useAuthToken: true,
    body: body
      );
      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateWorkspace({
    required int id,
    required String title,
    required int primaryWorkSpace,
    required List<int> userId,
    required List<int> clientId,
  }) async {
    print("tgyhjkl }");
    // Map<String, dynamic> rows;
    // final List<WorkspaceModel> task = [];
    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "primaryWorkspace": primaryWorkSpace,
        "user_ids": userId,
        "client_ids": clientId,
      };
      final response = await ApiBaseHelper.post(
          url: updaetWorkSpaceUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
