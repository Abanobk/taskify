import 'package:taskify/config/end_points.dart';
import 'package:taskify/config/strings.dart';
import 'package:taskify/data/model/finance/estimate_invoices_model.dart';
import '../../../api_helper/api_base_helper.dart';

class EstinateInvoiceRepo {
  Future<Map<String, dynamic>> EstinateInvoiceList(
      {int? limit, int? offset, String? search = "",required List<int> userCreatorId,
        required List<String> type,required String toDate,required String fromDate,required List<int> clientCreatorId,required List<int> clientId,}) async {
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
      if (type.isNotEmpty) {
        body["types[]"] = type;
      }

      if (clientId.isNotEmpty) {
        body["client_ids[]"] = clientId;
      }
      if (userCreatorId.isNotEmpty) {
        body["created_by_user_ids[]"] = userCreatorId;
      }if (clientCreatorId.isNotEmpty) {
        body["created_by_client_ids[]"] = clientCreatorId;
      }
      if (toDate !="") {
        body["date_to"] = toDate;
      }

        body["date_from"] = fromDate;

      final response = await ApiBaseHelper.getApi(
          url: EstimatesInvoicesUrl, useAuthToken: true, params: body);
      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> createInvoice({
    required int client_id,
    required String name,
    required String estimateInvoice,
    required String address,
    required String city,
    required String state,
    required String country,
    required String zip_code,
    required String phone,
    required String note,
    required String personal_note,
    required String from_date,
    required String to_date,
    required String status,
    required String total,
    required String tax_amount,
    required String final_total,
    required List<String> item_ids,
    required List<InvoicesItems> item,
    required List<String> quantity,
    required List<String> unit,
    required List<String> rate,
    required List<String> tax,
    required List<String> amount,
  }) async {
    try {
      Map<String, dynamic> body = {};

      // Add fields only if they are not "0" or empty
      if (type.isNotEmpty) body["type"] = estimateInvoice;
      if (client_id != 0) body["client_id"] = client_id;
      if (name.isNotEmpty) body["name"] = name;
      if (address.isNotEmpty) body["address"] = address;
      if (city.isNotEmpty) body["city"] = city;
      if (state.isNotEmpty) body["state"] = state;
      if (country.isNotEmpty) body["country"] = country;
      if (zip_code.isNotEmpty) body["zip_code"] = zip_code;
      if (phone.isNotEmpty) body["phone"] = phone;
      if (note.isNotEmpty) body["note"] = note;
      if (personal_note.isNotEmpty) body["personal_note"] = personal_note;
      if (from_date.isNotEmpty) body["from_date"] = from_date;
      if (to_date.isNotEmpty) body["to_date"] = to_date;
      if (status.isNotEmpty) body["status"] = status;
      if (total != '0') body["total"] = total;
      if (tax_amount != '0') body["tax_amount"] = tax_amount;
      if (final_total != '0') body["final_total"] = final_total;
      if (item_ids.isNotEmpty) body["item_ids"] = item_ids[0].toString();
      if (item_ids.isNotEmpty) body["item"] = item_ids; // Assuming you have a toJson() method in InvoicesItems
      if (quantity != '0') body["quantity"] = quantity!="" ?quantity:"1";
      if (unit.isNotEmpty) body["unit"] = unit;
      if (rate.isNotEmpty) body["rate"] = rate;
      if (tax.isNotEmpty) body["tax"] = tax;
      if (amount.isNotEmpty) body["amount"] = amount;

      print("Creating invoice");
      print("Invoice data: $body");

      // Make the API request with the filtered body
      final response = await ApiBaseHelper.post(
        url: createEstimatesInvoicesUrl,
        useAuthToken: true,
        body: body,
      );

      return response;
    } catch (e) {
      print("Error creating invoice: $e");
      // Handle the error appropriately
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteEstinateInvoice({
    required int id,
    required bool token,
  }) async {
    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.delete(
          url: "$deleteEstimatesInvoicesUrl/$id", useAuthToken: true, body: {});

      return response as Map<String, dynamic>;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateInvoice({
    required int id,
    required String name,
    required String estimateInvoice,
    required String address,
    required String city,
    required String state,
    required int clientId,
    required String country,
    required String zip_code,
    required String phone,
    required String note,
    required String personal_note,
    required String from_date,
    required String to_date,
    required String status,
    required String total,
    required String tax_amount,
    required String final_total,
    required List<int> item_ids,
    required List<InvoicesItems> item,
    required List<String> quantity,
    required List<String> unit,
    required List<String> rate,
    required List<String> tax,
    required List<String> amount,
  }) async {
    try {
      Map<String, dynamic> body = {
        "id": id,
        "type": estimateInvoice,
        "client_id": clientId,
        "name": name,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "zip_code": zip_code,
        "phone": phone,
        "note": note,
        "personal_note": personal_note,
        "from_date": from_date,
        "to_date": to_date,
        "status": status,
        "total": total,
        "tax_amount": tax_amount,
        "final_total": final_total,
        "item_ids": item_ids,
        "item": item_ids,
        "quantity": quantity,
        "unit": unit,
        "rate": rate,
        "tax": tax,
        "amount": amount,
      };

      final response = await ApiBaseHelper.post(
          url: updateEstimatesInvoicesUrl,
          useAuthToken: true,
          body: body
      );

      return response;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred while updating invoice');
    }
  }
}
