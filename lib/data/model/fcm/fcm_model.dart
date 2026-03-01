class FcmModel {
  bool? error;
  String? message;
  FcmData? data;

  FcmModel({this.error, this.message, this.data});

  FcmModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? FcmData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class FcmData {
  int? id;
  String? firstName;
  String? lastName;
  String? role;
  String? email;
  String? phone;
  String? countryCode;
  String? countryIsoCode;
  String? password;
  String? passwordConfirmation;
  String? type;
  String? dob;
  String? doj;
  String? address;
  String? city;
  String? state;
  String? country;
  String? zip;
  String? profile;
  int? status;
  String? fcmToken;
  String? createdAt;
  String? updatedAt;
  Assigned? assigned;

  FcmData(
      {this.id,
        this.firstName,
        this.lastName,
        this.role,
        this.email,
        this.phone,
        this.countryCode,
        this.countryIsoCode,
        this.password,
        this.passwordConfirmation,
        this.type,
        this.dob,
        this.doj,
        this.address,
        this.city,
        this.state,
        this.country,
        this.zip,
        this.profile,
        this.status,
        this.fcmToken,
        this.createdAt,
        this.updatedAt,
        this.assigned});

  FcmData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    role = json['role'];
    email = json['email'];
    phone = json['phone'];
    countryCode = json['country_code'];
    countryIsoCode = json['country_iso_code'];
    password = json['password'];
    passwordConfirmation = json['password_confirmation'];
    type = json['type'];
    dob = json['dob'];
    doj = json['doj'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zip = json['zip'];
    profile = json['profile'];
    status = json['status'];
    fcmToken = json['fcm_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    assigned = json['assigned'] != null
        ? Assigned.fromJson(json['assigned'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['role'] = role;
    data['email'] = email;
    data['phone'] = phone;
    data['country_code'] = countryCode;
    data['country_iso_code'] = countryIsoCode;
    data['password'] = password;
    data['password_confirmation'] = passwordConfirmation;
    data['type'] = type;
    data['dob'] = dob;
    data['doj'] = doj;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['zip'] = zip;
    data['profile'] = profile;
    data['status'] = status;
    data['fcm_token'] = fcmToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (assigned != null) {
      data['assigned'] = assigned!.toJson();
    }
    return data;
  }
}

class Assigned {
  int? projects;
  int? tasks;

  Assigned({this.projects, this.tasks});

  Assigned.fromJson(Map<String, dynamic> json) {
    projects = json['projects'];
    tasks = json['tasks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projects'] = projects;
    data['tasks'] = tasks;
    return data;
  }
}
