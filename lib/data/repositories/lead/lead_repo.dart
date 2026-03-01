import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import 'package:taskify/data/model/leads/leads_model.dart';
import '../../../api_helper/api_base_helper.dart';



class LeadsStageRepo {
  Future<Map<String, dynamic>> createLeadsStage({
    String? color,
    String? name,

  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (color != null) 'color': color,
        if (name != null) 'name': name,
      });

      final response = await ApiBaseHelper.formPost(
        url: createLeadStageUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> getLeadsStageList(
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
      var url = getLeadStageUrl;
      final response = await ApiBaseHelper.getApi(
          url: url, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteLeadsStage({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteLeadStageUrl/${id.toString()}", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateLeadsStage({
    required int id,
    String? color,
    String? name,
  }) async {
    try {
      print('Updating Lead with values:');
      print('id: $id');



      Map<String, dynamic> body = {
        'id': id,
        if (color != null) 'color': color,
        if (name != null) 'name': name,
      };

      final response = await ApiBaseHelper.post(
        url: "$updateLeadStageUrl",
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
class LeadsFollowUpRepo {
  Future<Map<String, dynamic>> createLeadsFollowUp({
FollowUps? model,
    int? leadId

  }) async {
    try {
      FormData formData = FormData.fromMap({

        if (model!.assignedTo != null) 'assigned_to': model.assignedTo!.id,
        if (model.type != null) 'type': model.type,
        if (model.status != null) 'status': model.status,
        if (model.followUpAt != null) 'follow_up_at': model.followUpAt,
        if (model.note != null) 'note': model.note,
        if (leadId != null) 'lead_id': leadId,
      });

      final response = await ApiBaseHelper.formPost(
        url: createFollowUpLeadUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteLeadsFollowUp({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteFollowUpLeadUrl/${id.toString()}", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateLeadsFollowUp({
    required int id,
    FollowUps? model
  }) async {
    try {
      print('Updating Lead with values:');
      print('id: $id');



      Map<String, dynamic> body = {
        'id': id,
        if (model!.assignedTo != null) 'assigned_to': model.assignedTo!.id,
        if (model.type != null) 'type': model.type,
        if (model.status != null) 'status': model.status,
        if (model.followUpAt != null) 'follow_up_at': model.followUpAt,
        if (model.note != null) 'note': model.note,
      };

      final response = await ApiBaseHelper.post(
        url: "$updateFollowUpLeadUrl",
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
class LeadsSourceRepo {
  Future<Map<String, dynamic>> createLeadsSource({
    String? name,

  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (name != null) 'name': name,
      });

      final response = await ApiBaseHelper.formPost(
        url: createLeadSourceUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }


  Future<Map<String, dynamic>> getLeadsSourceList(
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
      var url = getLeadSourceUrl;
      final response = await ApiBaseHelper.getApi(
          url: url, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteLeadsSource({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteLeadSourceUrl/${id.toString()}", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateLeadsSource({
    required int id,
    String? name,
  }) async {
    try {
      print('Updating Lead with values:');
      print('id: $id');



      Map<String, dynamic> body = {
        'id': id,
        if (name != null) 'name': name,
      };

      final response = await ApiBaseHelper.post(
        url: "$updateLeadSourceUrl",
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
class LeadsRepo {
  Future<Map<String, dynamic>> createLead({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? countryCode,
    String? countryIsoCode,
    int? leadSourceId,
    String? leadSource,
    int? leadStageId,
    String? leadStage,
    int? assignedTo,
    String? assignedUser,
    String? jobTitle,
    String? industry,
    String? company,
    String? website,
    String? linkedin,
    String? instagram,
    String? facebook,
    String? pinterest,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? createdAt,
    String? updatedAt,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (countryCode != null) 'country_code': countryCode,
        if (countryIsoCode != null) 'country_iso_code': countryIsoCode,
        if (leadSourceId != null) 'source_id': leadSourceId,
        if (leadStageId != null) 'stage_id': leadStageId,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (assignedUser != null) 'assigned_user': assignedUser,
        if (jobTitle != null) 'job_title': jobTitle,
        if (industry != null) 'industry': industry,
        if (company != null) 'company': company,
        if (website != null) 'website': website,
        if (linkedin != null) 'linkedin': linkedin,
        if (instagram != null) 'instagram': instagram,
        if (facebook != null) 'facebook': facebook,
        if (pinterest != null) 'pinterest': pinterest,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (zip != null) 'zip': zip,
        if (country != null) 'country': country,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      });

      final response = await ApiBaseHelper.formPost(
        url: createLeadUrl,
        useAuthToken: true,
        body: formData,
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }



  Future<Map<String, dynamic>> getLeadsList(
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
      var url = getLeadUrl;
      final response = await ApiBaseHelper.getApi(
          url: url, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteLeads({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteLeadUrl/$id", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> convertLeadToClient({
    required int id,
    required bool token,
  }) async {

    try {
      final response = await ApiBaseHelper.post(
          url: "$convertLeadToClientUrl/$id/convert-to-client", useAuthToken: true, body: {});
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateLeads({
    required int id,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? countryCode,
    String? countryIsoCode,
    int? leadSourceId,
    String? leadSource,
    int? leadStageId,
    String? leadStage,
    int? assignedTo,
    String? assignedUser,
    String? jobTitle,
    String? industry,
    String? company,
    String? website,
    String? linkedin,
    String? instagram,
    String? facebook,
    String? pinterest,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? createdAt,
    String? updatedAt,
  }) async {
    try {
      print('Updating Lead with values:');
      print('id: $id');

      Map<String, dynamic> body = {
        'id': id,
        if (name != null) 'name': name,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (countryCode != null) 'country_code': countryCode,
        if (countryIsoCode != null) 'country_iso_code': countryIsoCode,
        if (leadSourceId != null) 'source_id': leadSourceId,
        if (leadStageId != null) 'stage_id': leadStageId,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (jobTitle != null) 'job_title': jobTitle,
        if (industry != null) 'industry': industry,
        if (company != null) 'company': company,
        if (website != null) 'website': website,
        if (linkedin != null) 'linkedin': linkedin,
        if (instagram != null) 'instagram': instagram,
        if (facebook != null) 'facebook': facebook,
        if (pinterest != null) 'pinterest': pinterest,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (zip != null) 'zip': zip,
        if (country != null) 'country': country,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };

      final response = await ApiBaseHelper.post(
        url: "$updateLeadUrl/$id",
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
