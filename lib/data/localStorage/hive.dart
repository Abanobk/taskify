import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../config/constants.dart';
import '../../config/strings.dart';

class HiveStorage {
  final String languageBoxName = 'languagebox';
  final String defaultLanguageBoxName = 'defaultLanguagebox';


  static putToken(String value) async {
    var box = await Hive.openBox(authBox);
    box.put(customToken, value);
  }
  static putSMSGatewayHeader(List<Map<dynamic, dynamic>> headerList) async {
    var box = await Hive.openBox(headerBox);
    box.put('headerList', headerList);
    print("sfdgfkjlgjl $headerList");
  }
  static putSMSGatewayFormData(List<Map<String, String>> formDataList) async {
    var box = await Hive.openBox(headerBox);
    box.put('formDataList', formDataList);
    print("sfdgfkjlgjl $formDataList");
  }
  static putSMSGatewayParam(List<Map<String, String>> paramList) async {
    var box = await Hive.openBox(headerBox);
    box.put('paramList', paramList);
    print("sfdgfkjlgjl $paramList");
  }
  static putSMSGatewayAuthToken(String authToken) async {
    var box = await Hive.openBox(headerBox);
    box.put('authToken', authToken);
    print("sfdgfkjlgjl $authToken");
  }

  static Future<String?> getToken() async {
    var box = await Hive.openBox(authBox);
   var token = await box.get(customToken) ?? false;
    print("customToken FROM HIVE $token");
    return box.get(customToken)??"";
  }
  static Future<String?> getSMSGatewayToken() async {
    var box = await Hive.openBox(headerBox);
   var token = await box.get('authToken') ?? false;
    print("customToken FROM HIVE $token");
    return box.get('authToken')??"";
  }
  static Future<String> getRole() async {
    var box = await Hive.openBox(userBox);
    var role = await box.get('role') ;
    print("Role FROM HIVE $role");
    return box.get('role')??"";
  }

  static  setWorkspaceId(int workspaceIdd) async {
    Box box = await Hive.openBox(userBox);
     await box.put('workspace_id', workspaceIdd);
  }
  static  setUserId(int userId) async {
    print("fghjnkm $userId");
    Box box = await Hive.openBox(userBox);
     await box.put('user_id', userId);
  }
  static  setHasAllDataAccess(bool hasAllDataAccess) async {
    Box box = await Hive.openBox(userBox);
     await box.put('hasAllDataAccess', hasAllDataAccess);
  }
  static  setFcm(String fcm) async {
    var box = await Hive.openBox(fcmBox);
     await box.put('fcmTokenId', fcm);;
  }
  static  setRole(String role) async {
    Box box = await Hive.openBox(userBox);
     await box.put('role', role);
  }
  static Future<void> setBiometricAuth(bool status) async {
    try {
      Box box = await Hive.openBox(biometricAuthBox);
      await box.put('biometric', status);
      print("Biometric auth set to: $status");
    } catch (e) {
      print("Error in setBiometricAuth: $e");
    }
  }
  static  setWorkspaceTitle(String workspaceTitle) async {
    Box box = await Hive.openBox(userBox);
     await box.put('workspace_title', workspaceTitle);
  }
  static Future<int> getWorkspaceId() async {
    Box box = await Hive.openBox(userBox);
    int workspaceId = box.get('workspace_id') ?? 0; // or any default ID
    return workspaceId;
  }

  static Future<bool> getBiometricAuth() async {
    try {
      Box box = await Hive.openBox(biometricAuthBox);
      bool isActive = box.get('biometric', defaultValue: defaultBiometric);
      print("tryuhj $isActive");
      return isActive;
    } catch (e) {
      print("Error in getBiometricAuth: $e");
      return defaultBiometric; // Fallback to default
    }
  }

  static Future<String> getWorkspaceTitle() async {
    Box box = await Hive.openBox(userBox);
    String workspaceTitle=await box.get('workspace_title');
    return workspaceTitle;
  }
  static Future<bool> getHasAllDataAccess() async {
    Box box = await Hive.openBox(userBox);
    bool hasAllDataAccess=await box.get('hasAllDataAccess');
    return hasAllDataAccess;
  }
  static Future<int> getUserId() async {
    Box box = await Hive.openBox(userBox);
    int userId=await box.get('user_id');
    print("fgvhbjklml $userId");
    return userId;
  }
  static Future<bool> getAllDataAccess() async {
    Box box = await Hive.openBox(userBox);
    bool hasAllDataAccess = await box.get('hasAllDataAccess') ;
    print("hasAllDataAccess FROM HIVE $hasAllDataAccess");
    return box.get('hasAllDataAccess')??"";
  }


  static Future<bool> isToken() async {
    var box = await Hive.openBox(authBox);
    var token = await box.get(customToken);
    print("isToken $token");
    print("isToken ${token != null || token != ""}");
    if (token != null && token != "") {
      return true;
    } else {
      return false;
    }

  }

  static Future<void> clearToken() async {
    var authbox = await Hive.openBox(authBox);
    var userbox = await Hive.openBox(userBox);
    var themebox = await Hive.openBox(themeBox);
    var biometricbox = await Hive.openBox(biometricAuthBox);

    print("Before clearing:");
    print("AuthBox values: ${authbox.toMap()}");
    print("UserBox values: ${userbox.toMap()}");
    print("ThemeBox values: ${themebox.toMap()}");

    await authbox.clear();
    await userbox.clear();
    await themebox.clear();
    await biometricbox.clear();

    print("After clearing:");
    print("AuthBox values:After  ${authbox.toMap()}");
    print("UserBox values: ${userbox.toMap()}");
    print("ThemeBox values: ${themebox.toMap()}");

    print("AuthBox cleared: ${authbox.isEmpty}");
    print("UserBox cleared: ${userbox.isEmpty}");
    print("ThemeBox cleared: ${themebox.isEmpty}");
    var box = await Hive.openBox(authBox);
    print("Token after clear: ${box.get('token')}");
  }


  static setIsFirstTime(value) async {
    var box = await Hive.openBox(authBox);
    box.put(firstTimeUserKey, value);
    getIsFirstTime();
  }

  static Future<bool> getIsFirstTime() async {
    var box = await Hive.openBox(authBox);

    print("isFirstTime  HIVE firstTimeUserKey ${box.get(firstTimeUserKey)}");
    return box.get(firstTimeUserKey) ?? true;
  }

  static Future<bool> isFirstTime() async {
    var box = await Hive.openBox(authBox);
    var isFirst = await box.get(firstTimeUserKey);
    print("ISFIRST TIME IN HIVE $isFirst");
    if (isFirst != null) {
      return false;
    } else {
      return true;
    }
  }

//== Language Hive

  Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  Future<String?> getLanguage() async {

    final box = await openBox(languageBoxName);
    return box.get(languageKey);
  }

  Future<void> storeLanguage(String languageCode) async {
    final box = await openBox(languageBoxName);

    await box.put(languageKey, languageCode);
  }

  Future<void> storeDefaultLanguage(String languageCode) async {
    final box = await openBox(defaultLanguageBoxName);
    await box.put(languageKey, languageCode);
  }

  Future<String?> getDefaultLanguage() async {
    final box = await openBox(defaultLanguageBoxName);
    return box.get(languageKey);
  }

}
