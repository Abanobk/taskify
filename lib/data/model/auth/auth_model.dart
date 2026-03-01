class AuthModel {
  bool? error;
  String? message;
  String? token;
  Data? data;

  AuthModel({this.error, this.message, this.token, this.data});

  AuthModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    token = json['token'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['token'] = token;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;
  int? workspaceId;
  String? myLocale;
  String? locale;

  Data({this.userId, this.workspaceId, this.myLocale, this.locale});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    workspaceId = json['workspace_id'];
    myLocale = json['my_locale'];
    locale = json['locale'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['workspace_id'] = workspaceId;
    data['my_locale'] = myLocale;
    data['locale'] = locale;
    return data;
  }
}
