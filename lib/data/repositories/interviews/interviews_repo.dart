import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';



class InterviewsRepo {
  Future<Map<String, dynamic>> createInterviews({
    int? candidateId,
    String? candidateName,
    int? interviewerId,
    String? interviewerName,
    String? round,
    String? scheduledAt,
    String? mode,
    String? location,
    String? status,
  })
  async {
    try {
      FormData formData = FormData.fromMap({
        if (candidateId != null) 'candidate_id': candidateId,
        if (interviewerId != null) 'interviewer_id': interviewerId,
        if (round != null) 'round': round,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (mode != null) 'mode': mode,
        if (location != null) 'location': location,
        if (status != null) 'status': status,
      });

      final response = await ApiBaseHelper.formPost(
        url: createInterviewsUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> InterviewsList(
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
      }if (id != null) {
        body["candidate_id"] = id;
      }
      var url = getInterviewsUrl;
      final response = await ApiBaseHelper.getApi(
          url: url, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteInterviews({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteInterviewsUrl/$id", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateInterviews({
    required int id,
    int? candidateId,
    String? candidateName,
    int? interviewerId,
    String? interviewerName,
    String? round,
    String? scheduledAt,
    String? mode,
    String? location,
    String? status,
  }) async {
    try {
      print('Updating interview with values:');
      print('id: $id');
      print('candidateId: $candidateId');
      print('candidateName: $candidateName');
      print('interviewerId: $interviewerId');
      print('interviewerName: $interviewerName');
      print('round: $round');
      print('scheduledAt: $scheduledAt');
      print('mode: $mode');
      print('location: $location');
      print('status: $status');


      Map<String, dynamic> body = {
        'id': id,
        if (candidateId != null) 'candidate_id': candidateId,
        if (interviewerId != null) 'interviewer_id': interviewerId,
        if (round != null) 'round': round,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (mode != null) 'mode': mode,
        if (location != null) 'location': location,
        if (status != null) 'status': status,
      };

      final response = await ApiBaseHelper.post(
        url: "$updateInterviewsUrl/$id",
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
