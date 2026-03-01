import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../config/strings.dart';
import '../localStorage/hive.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class GlobalKeys {
  // static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
}

class GlobalUserData {

  static String? roleIS;
  static int? workspaceId;
  static String? token;


  static Future<void> getToken()async{
     token=  await HiveStorage.getToken();
  }
  static Future<int> putWorkspaceId(workspaceIdd)async{
    Box box = await Hive.openBox(userBox);
    await box.put('workspace_id', workspaceIdd);
    workspaceId =workspaceIdd;
    return workspaceId!;
  }

  static Future<String?> getRole() async {
    Box user = await Hive.openBox(userBox);
    roleIS= user.get('role');
    return role;
  }



}

