import '../data/localStorage/hive.dart';

Future<Map<String, String>?> get headers async {
  final String? token = await HiveStorage.getToken();
  final int? workspaceId = await HiveStorage.getWorkspaceId();
  print("Token: $token");
  print("Workspace ID: $workspaceId");
  if (token != null && token.trim().isNotEmpty) {
    return {
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
      'workspace-id': workspaceId.toString()
    };
  }
  return  null;
}
Future<Map<String, String>?> get headerForChat async {
  final String? token = await HiveStorage.getToken();
  final int? workspaceId = await HiveStorage.getWorkspaceId();
  print("Token: $token");
  print("Workspace ID: $workspaceId");
  if (token != null && token.trim().isNotEmpty) {
    return {
      "Accept": "application/json",
      'Authorization': 'Bearer $token',
      'workspace-id': workspaceId.toString(),
      'user-agent': 'Dart/3.6 (dart:io)',
      'accept': 'application/json',
      'accept-encoding': 'gzip',
      'host': 'dev-taskify.taskhub.company',


    };
  }
  return  null;
}
