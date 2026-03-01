import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../config/error_message_code.dart';
import '../data/GlobalVariable/globalvariable.dart';
import 'api.dart';
import '../utils/widgets/toast_widget.dart';
import '../../api_helper/header.dart';

class ApiBaseHelper {
  static final Dio _dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Called before request is sent
          log('➡️ Request: ${options.method} ${options.path}');
          log('Headers: ${options.headers}');
          log('Body: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Called when response is received
          log('✅ Response: ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Add a delay to ensure this runs after the current execution
            GoRouter.of(navigatorKey.currentContext!).go('/login');

            // Return a resolved response instead of an error
            return handler.resolve(Response(
              requestOptions: e.requestOptions,
              data: {'message': 'Unauthorized, redirecting to login'},
              statusCode: 200,
            ));
          }

          log('⛔ Error: ${e.response?.statusCode} ${e.message}');
          return handler.next(e);
        },
      ),
    );
  static Future<dynamic> patch({
    Map<String, dynamic>? body,
    required String url,
    bool useAuthToken = true,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
    bool isMultipart = false, // <-- Add a flag to toggle FormData
  }) async {
    try {
      debugPrint("PATCH REQUEST => URL: $url\nBODY: $body");

      final Map<String, String>? header = await headers;

      dynamic dataToSend;

      if (isMultipart && body != null) {
        FormData formData = FormData();

        body.forEach((key, value) {
          if (value is File) {
            formData.files.add(MapEntry(
              key,
              MultipartFile.fromFileSync(value.path,
                  filename: value.path.split('/').last),
            ));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });

        dataToSend = formData;
      } else {
        dataToSend = body;
        header?['Content-Type'] = 'application/json'; // important
      }

      final response = await _dio.patch(
        url,
        data: dataToSend,
        queryParameters: queryParameters,
        options: Options(
          headers: header,
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return {
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data}");
      rethrow;
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("Unhandled error: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

//   static Future<dynamic> patch({
//     Map<String, dynamic>? body,
//     bool isFcm = false,
//     required String url,
//     bool? useAuthToken,
//     Map<String, dynamic>? queryParameters,
//     Function(int, int)? onSendProgress,
//     Function(int, int)? onReceiveProgress,
//   }) async {
//     try {
//       debugPrint("HEADER ? BODY $url $body");
//       body ??= {};
//       FormData formData = FormData();
//       final Map<String, String>? header = await headers;
//
//       body.forEach((key, value) {
//         if (value is File) {
//           formData.files.add(MapEntry(
//             key,
//             MultipartFile.fromFileSync(value.path,
//                 filename: value.path.split('/').last),
//           ));
//         } else {
//           formData.fields.add(MapEntry(key, value.toString()));
//         }
//       });
// print("fvgbhnjm Header $header");
//       // Add your custom patch logic here
//       final response = await _dio.patch(
//
//         url,
//         // data: body is Map<String, dynamic> ? body : formData,
//         data: body is FormData ? body : FormData.fromMap(body),
//
//         queryParameters: queryParameters,
//         options: Options(headers: header),
//       );
//
//       // Handling response error
//       // if (response.data['error']) {
//       //   throw ApiException(response.data['message']);
//       // }
//
//       return <String, dynamic>{
//         "data": Map.from(response.data),
//         "status": 200,
//       };
//     } on DioException catch (e) {
//        debugPrint(e.response?.data);
//       rethrow;
//     } on ApiException catch (e) {
//       throw ApiException(e.errorMessage);
//     } catch (e) {
//       debugPrint("e: $e");
//       throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
//     }
//   }

  static Future<Map<String, dynamic>> loginPost({
    Map<String, dynamic>? body,
    required String url,
  }) async {
    try {
      final response = await _dio.post(url,
          data: body,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> signUpPost({
    Map<String, dynamic>? body,
    required String url,
  }) async {
    try {
      final response = await _dio.post(url,
          data: body,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> formPost({
    required String url,
    dynamic body, // Can be Map<String, dynamic> or FormData
    bool useAuthToken = true,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      // Fetch headers dynamically
      final Map<String, String>? authHeaders = await headers;
      final response = await _dio.post(
        url,
        data: body, // Supports FormData or JSON body
        queryParameters: queryParameters,
        options: Options(
          headers: authHeaders,
          contentType:
              Headers.jsonContentType, // Automatically handles FormData
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode != 200) {
        flutterToastCustom(msg: "Request failed");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e, stackTrace) {
      debugPrint("DioException: ${e.message}, StackTrace: $stackTrace");

      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }

      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("Unhandled Exception: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }


// Assuming _dio is a pre-configured Dio instance


// Assuming headers is a method that fetches auth headers dynamically


  static Future<Map<String, dynamic>> formPostChat({
    required String url,
    dynamic body, // Can be Map<String, dynamic> or FormData
    bool useAuthToken = true,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Map<String, String>? authHeaders = useAuthToken ? await headerForChat : null;
      if (body is FormData) {
        print("📤 Sending FormData:");
        for (var f in body.fields) {
          print("  ➜ ${f.key} = ${f.value}");
        }
      }

      print("➡️ Headers: $headerForChat");
      print("➡️ URL: $url");
      print("➡️ Query Params: $queryParameters");

      final response = await _dio.post(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: authHeaders,
          contentType: body is FormData ? null : Headers.jsonContentType,
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );


      if (response.statusCode != 200) {
        debugPrint("Response data: ${response.data}");
        flutterToastCustom(msg: "Request failed");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e, stackTrace) {
      debugPrint("DioException: ${e.message}, StackTrace: $stackTrace");

      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }

      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("Unhandled Exception: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }
  static Future<Map<String, dynamic>> post({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      print("FDJ Fkd,zhgnd;x $body");
      body ??= {};
      print("FDJ Fkd,zhgnd;x $url");

      final Map<String, String>? authHeaders = await headers;
      print("FDJ Fkd,z");

      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: authHeaders,
        ),
      );
      print("dgklfgxcmg. $response");
      if (response.statusCode != 200) {
        flutterToastCustom(msg: "ghj ");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e, stackTrace) {
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        print(e.response!.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions.validateStatus);
        print(e.message);
      }
      print("sfgbgbdzvm  $stackTrace");
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      debugPrint("Error Response Data: ${e.response?.data}");
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> postImageWithText({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      print("ogk;lm $formData");
      for (var field in formData.fields) {
        print("Field: ${field.key} = ${field.value}");
        print("klesgkdx,nv ${field.key}");
      }
      final Map<String, String>? authHeaders = await headers;

      final response = await _dio.post(url,
          data: formData, options: Options(headers: authHeaders));

      print("dgklfgxcmg. $response");
      if (response.statusCode != 200) {
        flutterToastCustom(msg: "ghj ");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e, stackTrace) {
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        print(e.response!.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions.validateStatus);
        print(e.message);
      }
      print("sfgbgbdzvm  $stackTrace");
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      debugPrint("Error Response Data: ${e.response?.data}");
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> postMedia({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      // Debugging FormData
      print("🚀 Sending FormData:");
      for (var field in formData.fields) {
        print("📄 Field: ${field.key} = ${field.value}");
      }
      for (var file in formData.files) {
        print("📂 File: ${file.key} = ${file.value.filename}");
      }

      final Map<String, String>? authHeaders = await headers;

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: authHeaders),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> postProfile({
    required String url,
    bool? useAuthToken,
    File? profile,
    String? type,
    int? id,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'upload': await MultipartFile.fromFile(profile!.path),
        'id': id,
        'type': type,
      });

      final Map<String, String>? header = await headers;
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: header),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }



  static Future<dynamic> delete({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};

      FormData formData = FormData();
      final Map<String, String>? header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(MapEntry(
            key,
            MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last),
          ));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await _dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      flutterToastCustom(msg: e.response?.data['message']);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      flutterToastCustom(msg: e.toString());
      throw ApiException(e.errorMessage);
    } catch (e) {
      print("e: $e");
      flutterToastCustom(msg: e.toString());
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> deleteApi({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};
      FormData formData = FormData();
      final Map<String, String>? header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(MapEntry(
            key,
            MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last),
          ));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await _dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      flutterToastCustom(msg: e.response?.data['message']);

      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      print("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> get(
      {required String url,
      required bool useAuthToken,
      required Map<String, dynamic> params}) async {
    Response responseJson;

    final Map<String, String>? header = await headers;
    try {
      final response = await _dio.get(url,
          queryParameters: params, options: Options(headers: header));
      if (kDebugMode) {
        log('response api****PARAMS $params *********** $url *****************${response.statusCode}*********${response.data}');
      }
      responseJson = response;
    } on SocketException {
      throw ApiException('No Internet connection');
    }
    return responseJson;
  }

  static Future<Map<String, dynamic>> getApi(
      {required String url,
      required bool useAuthToken,
      required Map<String, dynamic> params}) async {
    final Map<String, String>? header = await headers;
    try {
      final response = await _dio.get(url,
          queryParameters: params, options: Options(headers: header));
      if (kDebugMode) {
        log('response api****$params****************** $url *****************${response.statusCode}*********${response.data}');
      }
      return response.data as Map<String, dynamic>;
    } on SocketException {
      throw ApiException('No Internet connection');
    } catch (e) {
      throw ApiException('Error: $e');
    }
  }

  static Future<List<dynamic>> getGoogleApi({
    required String url,
    required bool useAuthToken,
    required Map<String, dynamic> params,
  }) async {
    final Map<String, String>? header = await headers;

    try {
      final response = await _dio.get(url,
          queryParameters: params, options: Options(headers: header));

      if (kDebugMode) {
        log('response api****$params****************** $url *****************${response.statusCode}*********${response.data}');
      }

      if (response.data is List) {
        return response.data as List<dynamic>;
      } else {
        throw ApiException('Unexpected response format: ${response.data}');
      }
    } on SocketException {
      throw ApiException('No Internet connection');
    } catch (e) {
      throw ApiException('Error: $e');
    }
  }

  static Future<dynamic> getRole(
      {required String url,
      required bool useAuthToken,
      required Map<String, dynamic> params}) async {
    Response responseJson;
    final Dio dio = Dio();

    final Map<String, String>? header = await headers;

    try {
      final response = await dio.get(url,
          queryParameters: params, options: Options(headers: header));
      if (kDebugMode) {
        log('response api**** $url *****************${response.statusCode}*********${response.data}');
      }
      responseJson = response;
    } on SocketException {
      throw ApiException('No Internet connection');
    }
    return responseJson;
  }
}

// class CustomException implements Exception {
//   final String? _message;
//   final String? _prefix;
//
//   CustomException([this._message, this._prefix]);
//
//   @override
//   String toString() {
//     return "$_prefix$_message";
//   }
// }
//
// class FetchDataException extends CustomException {
//   FetchDataException([message])
//       : super(message, "Error During Communication: ");
// }
//
// class BadRequestException extends CustomException {
//   BadRequestException([message]) : super(message, "Invalid Request: ");
// }
//
// class UnauthorisedException extends CustomException {
//   UnauthorisedException([message]) : super(message, "Unauthorised: ");
// }
