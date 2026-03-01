import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';

class ActivityLogRepo {
  Future<Map<String, dynamic>> activityLogList(
      {int? limit, int? offset, String? search = "",String? type,int? typeId}) async {

    try {
      print("dfgvhbjkm,l");
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
      if (type != null) {
        body["type"] = type;
      } if (typeId != null) {
        body["type_id"] = typeId;
      }
      final response = await ApiBaseHelper.getApi(
          url: listActivityUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
       throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteActivityLog({
    required String id,
    required bool token,
  }) async {

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteActivityUrl/$id", useAuthToken: true, body: {});
if( response['status_code'] == 401){
  return response ;
}
      return response;
    } catch (error) {print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

}