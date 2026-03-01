import 'dart:io';

import 'package:dio/dio.dart';

import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';


class ProjectRepo {
  Future<Map<String, dynamic>> getProjects({
    int? id,
    int? isFav,
    int? limit,
    int? offset,
    String? search = "",
    List<int>? userId,
    List<int>? tagId,
    List<int>? clientId,
    List<int>? priorityId,
    List<int>? statusId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Map<String, dynamic> body = {};

// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;
      if (userId?.isNotEmpty ?? false) body["user_ids[]"] = userId;
      if (clientId?.isNotEmpty ?? false) body["client_ids[]"] = clientId;
      if (tagId?.isNotEmpty ?? false) body["tag_ids[]"] = tagId;
      if (statusId?.isNotEmpty ?? false) body["status_ids[]"] = statusId;
      if (priorityId?.isNotEmpty ?? false) body["priority_ids[]"] = priorityId;
      if (toDate?.isNotEmpty ?? false) body["project_end_date_to"] = toDate;
      if (fromDate?.isNotEmpty ?? false) body["project_start_date_from"] = fromDate;
      if (isFav != null) body["is_favorites"] = isFav;

      // Add search, limit, and offset to the body if they are not null
      // if (search != null && search.isNotEmpty) {
      //   body["search"] = search;
      // }
      // if (limit != null) {
      //   body["limit"] = limit;
      // }
      // if (offset != null) {
      //   body["offset"] = offset;
      // }
      // if ( userId != null) {
      //   body["user_ids[]"] = userId;
      // }
      // if ( clientId != null) {
      //   body["client_ids[]"] = clientId;
      // }
      // if ( tagId != null) {
      //   body["tag_ids[]"] = tagId;
      // }
      // if ( statusId != null) {
      //   body["status_ids[]"] = statusId;
      // }
      // if ( priorityId != null) {
      //   body["priority_ids[]"] = priorityId;
      // }
      // if ( toDate != null) {
      //   body["project_end_date_to"] = toDate;
      // }
      // if (fromDate != null) {
      //   body["project_start_date_from"] = fromDate;
      // }

      print("Request body: $body");

      // Make API call based on whether an id is provided
      final response = await ApiBaseHelper.getApi(
        url:  id!=null ?"$projectUrl/$id" :projectUrl,
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getProjectsFav({

    int? limit,
    int? offset,
    String? search = "",
    int? isFav,
  }) async {
    try {
      Map<String, dynamic> body = {};

// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;
      if (isFav != null) body["is_favorites"] = isFav;


      // Add search, limit, and offset to the body if they are not null
      // if (search != null && search.isNotEmpty) {
      //   body["search"] = search;
      // }
      // if (limit != null) {
      //   body["limit"] = limit;
      // }
      // if (offset != null) {
      //   body["offset"] = offset;
      // }
      // if ( userId != null) {
      //   body["user_ids[]"] = userId;
      // }
      // if ( clientId != null) {
      //   body["client_ids[]"] = clientId;
      // }
      // if ( tagId != null) {
      //   body["tag_ids[]"] = tagId;
      // }
      // if ( statusId != null) {
      //   body["status_ids[]"] = statusId;
      // }
      // if ( priorityId != null) {
      //   body["priority_ids[]"] = priorityId;
      // }
      // if ( toDate != null) {
      //   body["project_end_date_to"] = toDate;
      // }
      // if (fromDate != null) {
      //   body["project_start_date_from"] = fromDate;
      // }

      print("Request body: $body");

      // Make API call based on whether an id is provided
      final response = await ApiBaseHelper.getApi(
        url:  projectUrl,
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateProject({
    required int id,
    required String title,
    required int statusId,
    required int priorityId,
    required String startDate,
    required String endDate,
    required String desc,
    required String taskAccess,
    required String note,
    required String budget,
    required List<int> userId,
    required List<int> clientId,
    required List<int> tagId,
    required int canClientDiscuss,
    required int enable,
    required Map<String, dynamic>? customFieldValues, // Nullable parameter
  }) async {
    try {
      // Safely unwrap and prepare the custom fields
      final Map<String, dynamic> customFieldsMap = customFieldValues ?? {};

      // Optional: Print for debugging
      print("custom_fields to be sent: $customFieldsMap");

      // Construct the request body
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "status_id": statusId,
        "priority_id": priorityId,
        "start_date": startDate,
        "end_date": endDate,
        "description": desc,
        "budget": budget,
        "note": note,
        "task_accessibility": taskAccess,
        "user_id": userId,
        "client_id": clientId,
        "tag_ids": tagId,
        "clientCanDiscuss": canClientDiscuss,
        "enable": enable,
        "custom_fields": customFieldsMap, // ✅ Proper format
      };

      // Make the API request
      final response = await ApiBaseHelper.post(
        url: updateProjectUrl,
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (error) {
      print(" Error: ${error.toString()}");
      throw Exception(error.toString());
    }
  }


  Future<Map<String, dynamic>> createProject(
      {required String title,
      required int statusId,
      required int priorityId,
      required String startDate,
      required String endDate,
      required String desc,
      required String taskAccess,
      required String note,
      required String budget,
      required List<int> userId,
      required List<int> clientId,
      required List<int> tagId,
        required int canClientDiscuss,
        required int enable,
        required Map<String, dynamic>? customFieldValues, // Nullable parameter


        String? search}) async {


    try {
      final Map<String, dynamic> customFieldsMap = customFieldValues ?? {};

      // Optional: Print for debugging
      print("custom_fields to be sent: $customFieldsMap");
      Map<String, dynamic> body = {
        "title": title,
        "status_id": statusId,
        "priority_id": priorityId,
        "start_date": startDate,
        "end_date": endDate,
        "description": desc,
        "budget": budget,
        "note": note,
        "task_accessibility": taskAccess,
        "user_id": userId,
        "client_id": clientId,
        "clientCanDiscuss": canClientDiscuss,
        "enable": enable,
        "tag_ids": tagId,
        "custom_fields": customFieldsMap, // ✅ Proper format

      };
      if (search != null) {
        body["search"] = search;
      }

      final response = await ApiBaseHelper.post(
        url: createProjectUrl,
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getDeleteProject({
    required String id,
    required bool token,
  }) async {
    try {
      final response = await ApiBaseHelper.delete(
          url: "$deleteProjectUrl/$id", useAuthToken: true, body: {});

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getProjectsMilestone({
    int? id,
    int? limit,
    int? offset,
    String? search = "",
    String?  dateBetweenFrom,
    String?  dateBetweenTo,
    String?  startDateFrom,
    String?  startDateTo,
    String?  endDateFrom,
    String?  endDateTo,
    String?  status,

  }) async {
    try {
      Map<String, dynamic> body = {};

// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;
      if (dateBetweenFrom!=null) body["date_between_from"] = dateBetweenFrom;
      if (dateBetweenTo!=null) body["date_between_to"] = dateBetweenTo;
      if (startDateFrom!=null) body["start_date_from"] = startDateFrom;
      if (startDateTo!=null) body["start_date_to"] = startDateTo;
      if (endDateFrom!=null) body["end_date_from"] = endDateFrom;
      if (endDateTo!=null) body["end_date_to"] = endDateTo;
      if (status!=null) body["status"] = status;



      print("Request body: $body");
      print("Request body: $id");

      // Make API call based on whether an id is provided
      final response = await ApiBaseHelper.getApi(
        url:  id!=null ?"$projectMilestoneUrl/$id" :projectMilestoneUrl,
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> updateProjectMilestone({
    required int id,
    required int projectId,
    required String title,
    required String status,
    required String startDate,
    required String endDate,
    required String cost,
    required String desc,
    int? progress

  }) async {
    try {
      Map<String, dynamic> body = {
        "project_id": projectId,
        "id":id,
        "title": title,
        "status": status,
        "start_date": startDate,
        "end_date": endDate,
        "description": desc,
        "cost": cost,
        "progress":progress ?? null

      };
      final response = await ApiBaseHelper.post(
          url:updateProjectMilestoneUrl, useAuthToken: true, body: body);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception(error.toString());
    }
  }

  Future<Map<String, dynamic>> createProjectMilestone(
      {
        required int id,
        required String title,
        required String status,
        required String startDate,
        required String endDate,
        required String cost,
        required String desc}) async {

    try {
      Map<String, dynamic> body = {
"project_id":id,
        "title": title,
        "status": status,
        "start_date": startDate,
        "end_date": endDate,
        "description": desc,
        "cost": cost,

      };

      final response = await ApiBaseHelper.post(
        url: createProjectMilestoneUrl,
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getDeleteProjectMilestone({
    required String id,
    required bool token,
  }) async {
    try {
      final response = await ApiBaseHelper.delete(
          url: "$deleteProjectMilestoneUrl/$id", useAuthToken: true, body: {});

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getProjectMedia({
    int? id,
    int? limit,
    int? offset,
    String? search = "",


  }) async {
    try {
      Map<String, dynamic> body = {};
print("oeiurfotesu $search");
// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;
      if (id != null) body["id"] = id;

      final response = await ApiBaseHelper.getApi(
        url:  id!=null ?"$projectMediaUrl/$id" :projectMediaUrl,
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getProjectMindMap({
    int? id,

  }) async {
    try {
      Map<String, dynamic> body = {};


      final response = await ApiBaseHelper.getApi(
        url: "${projectMindMapUrl}projects/$id/mind-map",
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getProjectTimeLineStatus({
    int? id,
    int? limit,
    int? offset,
    String? search = "",


  }) async {
    try {
      Map<String, dynamic> body = {};

// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;

      final response = await ApiBaseHelper.getApi(
        url:  id!=null ?"$projectTimelineStatusUrl$id/status-timelines" :projectTimelineStatusUrl,
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getDeleteProjectMedia({
    required String id,
    required bool token,
  }) async {
    try {
      final response = await ApiBaseHelper.delete(
          url: "$deleteProjectMediaUrl/$id", useAuthToken: true, body: {});

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> uploadProjectMedia({
    required int id,
    required List<File> media,
  }) async {
    try {
      // Convert List<File> into List<MultipartFile>
      List<MultipartFile> mediaFiles = await Future.wait(
        media.map(
              (file) async => await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
print("fvgNDJGvhn ${mediaFiles.length}");
      mediaFiles.asMap().forEach((index, file) {
        print('File $index:');
        print('  - Length: ${file.length}');
        print('  - Filename: ${file.filename}');
      });

      FormData formData = FormData.fromMap({
        "id": id.toString(),
        "media_files[]": mediaFiles,
      });

      // Make API call
      final response = await ApiBaseHelper.postMedia(
        url: "$uploadProjectMediaUrl",
        useAuthToken: true,
        formData: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateProjectPinned(
      {
        required int id,
        required int isPinned,
     }) async {

    try {
      Map<String, dynamic> body = {
        "id":id,
        "is_pinned": isPinned,
      };

      final response = await ApiBaseHelper.patch(
        url: "$updatePinnedProjectUrl/$id/pinned",
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> updateProjectFavorite(
      {
        required int id,
        required int isFavorite,
     }) async {

    try {
      Map<String, dynamic> body = {
        "id":id,
        "is_favorite": isFavorite,
      };

      final response = await ApiBaseHelper.patch(
        url: "$updatePinnedProjectUrl/$id/favorite",
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
