import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taskify/config/end_points.dart';
import 'package:taskify/data/model/contract/contract_model.dart';
import '../../../api_helper/api_base_helper.dart';

class ContractRepo {
  Future<Map<String, dynamic>> createContractType({
    required String type,
  }) async {
    try {
      FormData formData = FormData.fromMap({"type": type, "isApi": true});
      final response = await ApiBaseHelper.formPost(
          url: createContractTypeUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> contractListType(
      {int? limit, int? offset, String? search = ""}) async {
    try {
      print("dfgvhbjkm,lqsa $limit");
      print("dfgvhbjkm,l$offset");
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
      print("dfgvhbjkm,l rt $body");
      final response = await ApiBaseHelper.getApi(
          url: contractTypeUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteContractType({
    required int id,
    required bool token,
  }) async {
    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteContractTypeUrl/$id", useAuthToken: true, body: {});

      // for (var row in rows) {
      //   Contract.add(ContractModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateContractType(
      {required int id, required String type}) async {
    try {
      Map<String, dynamic> body = {"id": id, "type": type, "isApi": true};
      final response = await ApiBaseHelper.post(
          url: updateContractTypeUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }




  Future<Map<String, dynamic>> createContract({
    required ContractModel model,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": model.title,
        "value": model.value,
        "start_date": model.startDate,
        "end_date": model.endDate,
        "client_id": model.client!.id,
        "project_id": model.project!.id,
        "contract_type_id": model.contractType!.id,
        "description": model.description,
        "isApi": true});

      final response = await ApiBaseHelper.formPost(
          url: createContractUrl, useAuthToken: true, body: formData);

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> contractList(
      {int? limit, int? offset, String? search = ""}) async {
    try {
      print("dfgvhbjkm,lqsa $limit");
      print("dfgvhbjkm,l$offset");
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
      print("dfgvhbjkm,l rt $body");
      final response = await ApiBaseHelper.getApi(
          url: contractUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> deleteContract({
    required int id,
    required bool token,
  }) async {
    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteContractUrl/$id", useAuthToken: true, body: {});

      // for (var row in rows) {
      //   Contract.add(ContractModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> deleteSignContract({
    required int id,
  }) async {
    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteSignContractUrl/$id", useAuthToken: true, body: {});

      // for (var row in rows) {
      //   Contract.add(ContractModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> signContract({
    required int id,
   required String image
  }) async {
    try {
      Map<String, dynamic> body = {"id": id, "signatureImage": image, };
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.post(
          url:signContractUrl, useAuthToken: true, body: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateContract(
      { required ContractModel model, File? pdfFile, }) async {
    try {
      FormData formData = FormData.fromMap({
        "id": model.id,
        "title": model.title,
        "value": model.value,
        "start_date": model.startDate,
        "end_date": model.endDate,
        "client_id": model.client?.id,
        "project_id": model.project?.id,
        "contract_type_id": model.contractType?.id,
        "description": model.description,
        "isApi": true,
        if (pdfFile != null)
          "signed_pdf": await MultipartFile.fromFile(
            pdfFile.path,
            filename: pdfFile.path.split('/').last,
          ),
      });

      final response = await ApiBaseHelper.formPost(
          url: updateContractUrl, useAuthToken: true, body: formData);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
