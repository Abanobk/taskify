import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class WorkAnniversaryRepo{
  Future<Map<String, dynamic>> getWorkAnniversary(
      {
        int? offset,
        int? limit,
        required bool token,
        String? toDate,
        String? fromDate,
        int? upComingDays,
        List<int>? userId,
        List<int>? clientId
      }) async {
    try {
      // print("harshad: ${offset+limit}");
      Map<String, dynamic> body = {};
      if (upComingDays != null && upComingDays != 0) {
        body["upcoming_days"] = upComingDays;
      }
      if (userId != null) {
        body["user_ids[]"] = userId;
      }
      if (clientId != null) {
        body["client_ids[]"] = clientId;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      print("BODY OF ANNIVERSARY $body");
      final response = await ApiBaseHelper.getApi(
        url: getWorkAnniUrl,
        useAuthToken: true, params: body,


      );
      print("WORK ANNI $response");
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

}