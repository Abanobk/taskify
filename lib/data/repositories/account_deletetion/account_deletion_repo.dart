import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class AccountDeletion {
  Future<Map<String, dynamic>> getDeleteAccount() async {
    try {
      final response = await ApiBaseHelper.delete(
          url: accountdeletionsurl, useAuthToken: true, body: {});
      if (response['error'] = true) {
        return {};
      }
      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
