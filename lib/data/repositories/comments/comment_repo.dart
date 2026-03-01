import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class DiscussionRepo {
  Future<Map<String, dynamic>> createDiscussion({
    required String modelType,
    required int modelId,
    required String content,
    String? parentId,
    bool? isProject ,// Change to nullable to handle empty case
    required List<File> media,
  }) async {
    try {
      // Only include non-empty fields in FormData
      final formData = FormData.fromMap({
        "model_type": modelType,
        "model_id": modelId.toString(),
        "content": content,
        if (parentId != null && parentId.isNotEmpty) "parent_id": parentId,
      });

      // Only add media files if the media list is not empty
      if (media.isNotEmpty) {
        List<MultipartFile> mediaFiles = await Future.wait(
          media.map(
                (file) async => await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
        // Add each file individually with the key "attachments[]"
        for (var file in mediaFiles) {
          formData.files.add(MapEntry("attachments[]", file));
        }
      }
      print("FormData Fields:");
      formData.fields.forEach((entry) {
        print("${entry.key}: ${entry.value}");
      });
String url = isProject ==true ?"$createDiscussionUrl/$modelId/comments":"$createTasksDiscussionUrl/$modelId/comments";
      final response = await ApiBaseHelper.formPostChat(
        url: url,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred: $error');
    }
  }

  Future<Map<String, dynamic>> DiscussionList({int? id,int? limit, int? offset, String? search = "",bool? isProject }) async {


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
      String url = isProject==true ?"$getDiscussionUrl/$id/comments/list":"$getTaskDiscussionUrl/$id/comments/list";
      final response = await ApiBaseHelper.getApi(
          url: url, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }



  Future<Map<String, dynamic>> updateDiscussion({
    required int DiscussionId,
    required String content,
    bool? isProject,

  }) async {
print("rftyhuik $DiscussionId");
    try {
      FormData formData = FormData.fromMap({
        "comment_id": DiscussionId,
        "content": content,
       });
      String url = isProject ==true ?"$updateDiscussionUrl":"$updateTasksDiscussionUrl";

      // Send the request using ApiBaseHelper (assumes Dio under the hood)
      final response = await ApiBaseHelper.formPost(
        url: url,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print(" Error in updateDiscussion: ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> deleteComment({
    required String CommentId,
    required bool token,
    bool? isProject,
  }) async {

    try {
      print("rftgyhujikl Id $CommentId");
      String url = isProject ==true ?"$deleteDiscussionUrl?comment_id=$CommentId":"$deleteTasksDiscussionUrl?comment_id=$CommentId";

      final response = await ApiBaseHelper.deleteApi(
          url: url, useAuthToken: true, body: {});
      if( response['status_code'] == 401){
        return response ;
      }
      return response;
    } catch (error) {print("Error ${error.toString()}");
    throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> deleteCommentAttachment({
    required String id,
    required bool token,
    bool? isProject,
  }) async {

    try {
      String url = isProject ==true ?"$deleteDiscussionAttachmentUrl/$id":"$deleteTasksDiscussionAttachmentUrl/$id";

      final response = await ApiBaseHelper.deleteApi(
          url: url, useAuthToken: true, body: {});
      if( response['status_code'] == 401){
        return response ;
      }
      return response;
    } catch (error) {print("Error ${error.toString()}");
    throw Exception('Error occurred');
    }
  }
}
