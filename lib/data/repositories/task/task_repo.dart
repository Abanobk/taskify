import 'dart:io';

import 'package:dio/dio.dart';

import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class TaskRepo {
  Future<Map<String, dynamic>> createTask(
      {required String title,
      required int statusId,
        int? parentId,
        bool? subtask,
      required int priorityId,
      required int canClientDiscuss,
      required String startDate,
      required String dueDate,
      required String desc,
      required int project,
      required String note,
      required String billingType,
      required int completionPercentage,
      required String enableReminder,
      required String enableRecurringTask,
      int? dayOfWeek,
      int? dayOfMonth,
      String? timeOfDay,
      String? recurrenceFrequency,
      int? recurrenceDayOfWeek,
      int? recurrenceDayOfMonth,
      int? recurrenceMonthOfYear,
      String? recurrrenceStartsFrom,
      String? frequencyType,
      String? recurrringFrequenctType,
      int? recurenceOccurences,
      required List<int> userId,
        required Map<String, dynamic>? customFieldValues, // Nullable parameter

        String? search}) async {
    try {
      final Map<String, dynamic> customFieldsMap = customFieldValues ?? {};

      // Optional: Print for debugging
      print("custom_fields to be sent: $customFieldsMap");
      print("gfbhnjdkm , $enableReminder");
      print("gfbhnjdkm , $enableRecurringTask");
      Map<String, dynamic> body = {
        "title": title,
        "status_id": statusId,
        "priority_id": priorityId,
        "start_date": startDate,
        "due_date": dueDate,
        "description": desc,
        "canClientDiscuss": canClientDiscuss,
        "project": project,
        "note": note,
        "user_id": userId,
        "billing_type": billingType == "" ? "none" : billingType,
        "completion_percentage": completionPercentage,
        "custom_fields": customFieldsMap, // ✅ Proper format

      };
      // Conditionally add these fields only if they are not "off"
      if (enableReminder.toLowerCase() != "off") {
        body["enable_reminder"] = enableReminder;
        body["day_of_week"] = dayOfWeek;
        body["day_of_month"] = dayOfMonth;
        body["frequency_type"] = frequencyType;
        body["time_of_day"] = timeOfDay;
      }

      if (enableRecurringTask.toLowerCase() != "off") {
        body["enable_recurring_task"] = enableRecurringTask;
        body["recurrence_occurrences"] = recurenceOccurences;
        body["recurrence_frequency"] = recurrenceFrequency;
        body["recurrence_day_of_week"] = recurrenceDayOfWeek;
        body["recurrence_day_of_month"] = recurrenceDayOfMonth;
        body["recurrence_month_of_year"] = recurrenceDayOfWeek;
        body["recurrence_starts_from"] = recurrrenceStartsFrom;
      }
      if (subtask == true && parentId != null && parentId!= 0) {
        body["parent_id"] = parentId;
      }
      if (search != null) {
        body["search"] = search;
      }

      final response = await ApiBaseHelper.post(
        url: createTaskUrl,
        useAuthToken: true,
        body: body,
      );
      print("sedfghjnkm${response['data']}");
      // rows = response['data'] as List<dynamic>;
      // for (var row in rows) {
      //   task.add(CreateTaskModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getTask(
      {int? offset,
      int? limit,
      required bool token,
      String? search,
      List<int>? userId,
      List<int>? projectId,
      List<int>? clientId,
      List<int>? priorityId,
      List<int>? statusId,
      String? toDate,
      String? fromDate,
      int? id,
      bool? subtask,
      int? isFav}) async {
    try {
      Map<String, dynamic> body = {};

      print("iD $fromDate");
      print("iD $toDate");
      print("iD $statusId");
      print("iD $clientId");
      print("iD $projectId");
      print("iD $userId");
      print("iD priorityId $priorityId");
      print("iD $search");
      print("iD $token");
      print("iD $subtask");
      print("iD drgty $id");
      // Adding data to the body only if it's not null
      if (subtask == true && id != null) {
        body["task_parent_id"] = id;
      }

      if (search?.isNotEmpty ?? false) {
        body["search"] = search;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (isFav != null) {
        body["is_favorites"] = isFav;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      if (userId != null && userId.isNotEmpty) {
        body["user_ids[]"] = userId;
      }
      if (clientId != null && clientId.isNotEmpty) {
        body["client_ids[]"] = clientId;
      }
      if (projectId != null && projectId.isNotEmpty) {
        body["project_ids[]"] = projectId;
      }
      if (statusId != null && statusId.isNotEmpty) {
        body["status_ids[]"] = statusId;
      }
      if (priorityId != null && priorityId.isNotEmpty) {
        body["priority_ids[]"] = priorityId;
      }
      if (toDate?.isNotEmpty ?? false) {
        body["task_end_date_to"] = toDate;
      }
      if (fromDate?.isNotEmpty ?? false) {
        body["task_start_date_from"] = fromDate;
      }
      print("BODY TASK $body");
      // Making the API request with the parameters that are available
      Map<String, dynamic> response = {};
      if (subtask == true && id != null) {
        body["task_parent_id"] = id;

        print("fsrjn kgfmvc,  $subtask}");
        // Handle case where there's no specific ID
        response = await ApiBaseHelper.getApi(
          url: getAllTaskUrl,
          useAuthToken: true,
          params: body,
        );
      } else if (id != null) {
        print("fsrjn,  $id}");
        body["id"] = id;

        response = await ApiBaseHelper.getApi(
          url: "$getAllTaskUrl/$id",
          useAuthToken: true,
          params: body,
        );
      } else {
        body["id"] = id;

        // Handle case where there's no specific ID
        response = await ApiBaseHelper.getApi(
          url: getAllTaskUrl,
          useAuthToken: true,
          params: body,
        );
      }

      print("==body $body=====response $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getTasksFav({
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

      print("Request body: $body");

      // Make API call based on whether an id is provided
      final response = await ApiBaseHelper.getApi(
        url: getAllTaskUrl,
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

  Future<Map<String, dynamic>> getDeleteTask({
    required String id,
    required bool token,
  }) async {
    // Map<String, dynamic> rows;

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteTask/$id", useAuthToken: true, body: {});

      // rows = response as Map<String, dynamic>;
      // for (var row in rows) {
      //   Todos.add(TodosModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTask({
    required int id,
    required String title,
    required int statusId,
    required int priorityId,
    required int canClientDiscuss,
    required String startDate,
    required String dueDate,
    required String desc,
    required String note,
    required String billingType,
    required int completionPercentage,
    required String enableReminder,
    String? frequencyType,
    String? recurrringFrequenctType,
    required String enableRecurringTask,
    required List<int> userId,
    int? dayOfWeek,
    int? dayOfMonth,
    int? parentId,
    bool? subtask,
    String? timeOfDay,
    String? recurrenceFrequency,
    int? recurrenceDayOfWeek,
    int? recurrenceDayOfMonth,
    int? recurrenceMonthOfYear,
    String? recurrrenceStartsFrom,
    int? recurenceOccurences,
    required Map<String, dynamic>? customFieldValues, // Nullable parameter

  }) async {
    print("tgyhjkl $recurrringFrequenctType}");

    try {
      final Map<String, dynamic> customFieldsMap = customFieldValues ?? {};

      // Optional: Print for debugging
      print("custom_fields to be sent: $customFieldsMap");
      Map<String, dynamic> body = {};

      if (id != "") body["id"] = id;
      if (title !="") body["title"] = title;
      if (statusId != "") body["status_id"] = statusId;
      if (priorityId != "") body["priority_id"] = priorityId;
      if (startDate != "") body["start_date"] = startDate;
      if (dueDate != "") body["due_date"] = dueDate;
      if (desc != "") body["description"] = desc;

      if (canClientDiscuss != "") body["canClientDiscuss"] = canClientDiscuss;
      if (note != "") body["note"] = note;
      if (billingType != "") body["billing_type"] = billingType;
      if (completionPercentage != "") body["completion_percentage"] = completionPercentage;
      if (userId != "") body["user_id"] = userId;
      if (dayOfWeek != "") body["day_of_week"] = dayOfWeek;
      if (dayOfMonth != "") body["day_of_month"] = dayOfMonth;
      if (timeOfDay != "") body["time_of_day"] = timeOfDay;
      if (recurrenceFrequency != null) body["recurrence_frequency"] = recurrenceFrequency.toLowerCase();
      if (frequencyType != null) body["frequency_type"] = frequencyType.toLowerCase();
      if (recurrenceDayOfWeek != null) body["recurrence_day_of_week"] = recurrenceDayOfWeek;
      if (recurrenceDayOfMonth != null) body["recurrence_day_of_month"] = recurrenceDayOfMonth;
      if (recurrenceDayOfWeek != null) body["recurrence_month_of_year"] = recurrenceDayOfWeek; // double-check this
      if (recurrrenceStartsFrom != null) body["recurrence_starts_from"] = recurrrenceStartsFrom;
      if (recurenceOccurences != null) body["recurrence_occurrences"] = recurenceOccurences;
      body["custom_fields"]= customFieldsMap;
      // Conditionally add these fields only if they are not "off"
      if (enableReminder.toLowerCase() != "off") {
        body["enable_reminder"] = enableReminder;
      }
      if (subtask == true && parentId != null) {
        body["parent_id"] = parentId;
      }
      if (enableRecurringTask.toLowerCase() != "off") {
        body["enable_recurring_task"] = enableRecurringTask;
      }

      final response = await ApiBaseHelper.post(
          url: updateTaskUrl, useAuthToken: true, body: body);
      print("ertyguhnjmk,l");
      print("xdctfvgybhnjmk,l $response");
      // rows = response['data']['data'] as Map<String, dynamic>;

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTaskPinned({
    required int id,
    required int isPinned,
  }) async {
    try {
      Map<String, dynamic> body = {
        "id": id,
        "is_pinned": isPinned,
      };

      final response = await ApiBaseHelper.patch(
        url: "$getAllTaskUrl/$id/pinned",
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTaskFavorite({
    required int id,
    required int isFavorite,
  }) async {
    try {
      print("u gkujg 4=$isFavorite");
      Map<String, dynamic> body = {
        "id": id,
        "is_favorite": isFavorite,
      };

      final response = await ApiBaseHelper.patch(
        url: "$getAllTaskUrl/$id/favorite",
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getTaskMedia({
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

      final response = await ApiBaseHelper.getApi(
        url: "$taskMediaUrl/$id",
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

  Future<Map<String, dynamic>> getTaskTimeLineStatus({
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
        url: "$taskTimelineStatusUrl$id/status-timelines",
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

  Future<Map<String, dynamic>> getDeleteTaskMedia({
    required String id,
    required bool token,
  }) async {
    try {
      final response = await ApiBaseHelper.delete(
          url: "$deleteTaskMediaUrl/$id", useAuthToken: true, body: {});

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> uploadTaskMedia({
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
        url: "$uploadTaskMediaUrl",
        useAuthToken: true,
        formData: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
