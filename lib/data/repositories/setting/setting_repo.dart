import 'dart:io';

import 'package:dio/dio.dart';

import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';
import '../../model/settings/sms_gateway.dart';

class SettingRepo {
  Future<Map<String, dynamic>> setting(String? endPoint) async {
    try {
      var responses = await ApiBaseHelper.getApi(
          url: () {
            switch (endPoint) {
              case "company_information":
                return companyInfourl;
              case "email_settings":
                return emailComapnyurl;
              case "sms_gateway_settings":
                return smsGatewayurl;
              case "whatsapp_settings":
                return whatsappurl;
              case "slack_settings":
                return slackappurl;
              case "media_storage_settings":
                return mediaStorageUrl;
              default:
                return settingsurl;
            }
          }(),
          useAuthToken: true,
          params: {});
      print(
          "********************** $responses \n URL $getUserLoginApi ******************");
      print("ERRO REPO ${responses['error']}");
      print("REPOIMSE $responses");
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> settingUpdate(SmsGatewayModel sms) async {
    try {
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: sms.toJson());
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> generalSettingUpdate({
    String? title,
    String? siteUrl,
    File? fullLogo,
    File? favicon,
    String? currencyFullForm,
    String? currencySymbol,
    String? currencyCode,
    String? currencySymbolPosition,
    String? currencyFormat,
    String? decimalPoints,
    String? dateFormat,
    String? timezone,
    String? timeFormat,
    int? birthdaySec,
    int? workanniversarySec,
    int? leaveReqSec,
  }) async {
    try {
      // Create a map and only add non-null values
      // final Map<String, dynamic> body = {};
      // if (title != null) body["company_title"] = title;
      // if (siteUrl != null) body["site_url"] = siteUrl;
      // if (fullLogo != null) body["full_logo"] = fullLogo;
      // if (favicon != null) body["favicon"] = favicon;
      // if (timezone != null) body["timezone"] = timezone;
      // if (currencyFullForm != null)
      //   body["currency_full_form"] = currencyFullForm;
      // if (currencySymbol != null) body["currency_symbol"] = currencySymbol;
      // if (currencyCode != null) body["currency_code"] = currencyCode;
      // if (currencySymbolPosition != null)
      //   body["currency_symbol_position"] = currencySymbolPosition;
      // if (currencyFormat != null) body["currency_format"] = currencyFormat;
      // if (decimalPoints != null) body["decimal_points"] = decimalPoints;
      // if (dateFormat != null) body["date_format"] = dateFormat;
      // if (timeFormat != null) body["time_format"] = timeFormat;
      // if (birthdaySec != null) body["upcomingBirthdays"] = birthdaySec;
      // if (workanniversarySec != null)
      //   body["upcomingWorkAnniversaries"] = workanniversarySec;
      // if (leaveReqSec != null) body["membersOnLeave"] = leaveReqSec;
      // body["variable"] = "general_settings";
      // print("sfsDJFN $body");



      FormData formData = FormData.fromMap({
        if (title != null) "company_title": title,
        if (siteUrl != null) "site_url": siteUrl,
        if (fullLogo != null)
          "full_logo": await MultipartFile.fromFile(fullLogo.path, filename: fullLogo.path.split('/').last),
        if (favicon != null)
          "favicon": await MultipartFile.fromFile(favicon.path, filename: favicon.path.split('/').last),
        if (timezone != null) "timezone": timezone,
        if (currencyFullForm != null) "currency_full_form": currencyFullForm,
        if (currencySymbol != null) "currency_symbol": currencySymbol,
        if (currencyCode != null) "currency_code": currencyCode,
        if (currencySymbolPosition != null) "currency_symbol_position": currencySymbolPosition,
        if (currencyFormat != null) "currency_format": currencyFormat,
        if (decimalPoints != null) "decimal_points": decimalPoints,
        if (dateFormat != null) "date_format": dateFormat,
        if (timeFormat != null) "time_format": timeFormat,
        if (birthdaySec != null) "upcomingBirthdays": birthdaySec.toInt(), // Ensure it's an int
        if (workanniversarySec != null) "upcomingWorkAnniversaries": workanniversarySec.toInt(),
        if (leaveReqSec != null) "membersOnLeave": leaveReqSec.toInt(),
        "variable": "general_settings",
      });

      var responses = await ApiBaseHelper.postImageWithText(
        url: settingUpdateurl,
        useAuthToken: true,
        formData: formData, // Sending only non-null values
      );

      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> securitySettingUpdate({
    String? maxAttempt,
    String? lockTime,
    String? allowMaxUploadSize,
    String? maxFilesAllowed,
    String? allowedFileType,
    String? isAllowedSignUP,
  }) async {
    try {
      // Create a map and only add non-null values
      final Map<String, dynamic> body = {
        "variable": "security_settings",
      };

      if (maxAttempt != null) body["max_attempts"] = maxAttempt;
      if (lockTime != null) body["lock_time"] = lockTime;
      if (allowMaxUploadSize != null)
        body["max_files"] = allowMaxUploadSize;
      if (maxFilesAllowed != null) body["allowed_max_upload_size"] = maxFilesAllowed;
      if (allowedFileType != null) body["allowed_file_types"] = allowedFileType;
      if (isAllowedSignUP != null) body["allowSignup"] = isAllowedSignUP;

      var responses = await ApiBaseHelper.post(
        url: settingUpdateurl,
        useAuthToken: true,
        body: body, // Sending only non-null values
      );

      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> whatsAppsettingUpdate(
      String accessToken, String phoneNumId) async {
    try {
      Map<String, dynamic> body = {
        "whatsapp_access_token": accessToken,
        "whatsapp_phone_number_id": phoneNumId,
        "variable": "whatsapp_settings"
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> slackSettingUpdate(String slackBotToken) async {
    try {
      Map<String, dynamic> body = {
        "slack_bot_token": slackBotToken,
        "variable": "slack_settings"
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> privacyPolicyUpdate(
      {required privacyPolicy,required from}) async {
    print("rkdjgnf $from");
    String variable;

    switch (from) {
      case "terms":
        variable = "terms_conditions";
        break;
      case "aboutus":
        variable = "about_us";
        break;
        case "privacypolicy":
        variable = "privacy_policy";
        break;
      default:
        variable = "privacy_policy";
        break;
    }
    try {
      Map<String, dynamic> body = {
        "value": privacyPolicy,
        "variable": variable
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> companyInformationUpdate(
      {required String email,
      required String phoneNumber,
      required String address,
      required String city,
      required String state,
      required String country,
      required String vatNumber,
      required String zipCode}) async {
    try {
      Map<String, dynamic> body = {
        "companyEmail": email,
        "companyPhone": phoneNumber,
        "companyAddress": address,
        "companyCity": city,
        "companyState": state,
        "companyCountry": country,
        "companyZip": zipCode,
        "companyVATNumber":vatNumber,
        "variable": "company_information"
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> emailUpdate(
      {required String email,
      required String password,
      required String smtpHost,
      required String smtpPort,
      required String emailContentType,
      required String smtpEncyption,
      }) async {
    try {
      Map<String, dynamic> body = {
        "email": email,
        "password": password,
        "smtp_host": smtpHost,
        "smtp_port": smtpPort,
        "email_content_type": emailContentType,
        "smtp_encryption": smtpEncyption,
        "variable": "email_settings"
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> mediaStorageSettingUpdate(
      {required String storageType,String? key,String? region,String? bucket,String? secret}) async {
    print("esdfjxzf,jsDN $storageType");

    try {
      Map<String, dynamic> body = {
        "media_storage_type": storageType,
        "s3_key":key??"",
        "s3_secret":secret??"",
        "s3_region":region??"",
        "s3_bucket":bucket??"",
        "variable": "media_storage_settings"
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
  Future<Map<String, dynamic>> emialSettingUpdate(
      {required String storageType}) async {
    print("esdfjxzf,jsDN $storageType");

    try {
      Map<String, dynamic> body = {
        "media_storage_type": storageType,
        "variable": "media_storage_settings"
      };
      var responses = await ApiBaseHelper.post(
          url: settingUpdateurl, useAuthToken: true, body: body);
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> privacyPolicy() async {
    try {
      var responses = await ApiBaseHelper.getApi(
        url: privacyPolicyUrl,
        useAuthToken: true,
        params: {},
      );
      print(
          "********************** $responses \n URL $getUserLoginApi ******************");
      print("ERRO REPO ${responses['error']}");
      print("REPOIMSE $responses");
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> aboutUs() async {
    try {
      var responses = await ApiBaseHelper.getApi(
        url: aboutUsUrl,
        useAuthToken: true,
        params: {},
      );
      print(
          "********************** $responses \n URL $getUserLoginApi ******************");
      print("ERRO REPO ${responses['error']}");
      print("REPOIMSE $responses");
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> termsAndConditions() async {
    try {
      var responses = await ApiBaseHelper.getApi(
        url: termsAndConditionUrl,
        useAuthToken: true,
        params: {},
      );
      print(
          "********************** $responses \n URL $getUserLoginApi ******************");
      print("ERRO REPO ${responses['error']}");
      print("REPOIMSE $responses");
      return responses;
    } catch (error) {
      print("Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
