import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class NotificationRepo {
  Future<Map<String, dynamic>> getNoti(
      {
        int? offset,
        int? limit,
        required bool token,
        String? search,
        String? notificationType,
        String? toDate,
        String? fromDate
      }) async {

    try {
      // print("harshad: ${offset+limit}");
      Map<String, dynamic> body = {};
      if (search != null) {
        body["search"] = search;
      }
      if (toDate != null) {
        body["task_start_date_from"] = toDate;
      }
      if (fromDate != null) {
        body["task_start_date_to"] = fromDate;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      if (notificationType != null) {

        body["notification_type"] = notificationType;
      }
      final response = await ApiBaseHelper.getApi(
        url: getNotificationUrl,
        useAuthToken: true, params: body,

      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getUnreadNotiCount(
      {
        String? notificationType,
        int? offset,
        int? limit,
        required bool token,
        String? search,
      }) async {

    try {
      Map<String, dynamic> body = {};
      // print("harshad: ${offset+limit}");
      if (notificationType != null) {

        body["notification_type"] = notificationType;
      }
      body['status']='unread';
      print("Notification Count $body");
      final response = await ApiBaseHelper.getApi(
        url: getNotificationUrl,
        useAuthToken: true, params: body,


      );
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> getDeleteNoti({
    required String id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
   final response= await ApiBaseHelper.delete(
          url: "$deleteNotificationUrl/$id", useAuthToken: true, body: {});

      // rows = response as Map<String, dynamic>;
      // for (var row in rows) {
      //   Todos.add(TodosModel.fromJson(row as Map<String, dynamic>));
      // }
return response;
    } catch (e, stacktrace) {
      print('Exception: $e');
      print('Stacktrace: $stacktrace');
      throw Exception('Error occurred');
    }

  }
  Future<Map<String, dynamic>> markAsReadNoti({
    required int id,
  }) async {
    try {

      final response = await ApiBaseHelper.patch(
          url: "$markAsReadNotificationUrl/$id",
          useAuthToken: true,
          body: {});
      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

}
