class Workspace {
  bool? error;
  String? message;
  int? total;
  List<WorkspaceModel>? data;

  Workspace({this.error, this.message, this.total, this.data});

  Workspace.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    total = json['total'];
    if (json['data'] != null) {
      data = <WorkspaceModel>[];
      json['data'].forEach((v) {
        data!.add(WorkspaceModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WorkspaceModel {
  int? id;
  String? title;
  int? primaryWorkspace;
  int? defaultWorkspace;
  List<UsersWorkspace>? users;
  List<int>? userIds;
  List<ClientsWorkspace>? clients;
  List<int>? clientIds;
  String? createdAt;
  String? updatedAt;

  WorkspaceModel(
      {this.id,
        this.title,
        this.primaryWorkspace,
        this.defaultWorkspace,
        this.users,
        this.userIds,
        this.clients,
        this.clientIds,
        this.createdAt,
        this.updatedAt});

  WorkspaceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    primaryWorkspace = json['primaryWorkspace'];
    defaultWorkspace = json['defaultWorkspace'];
    if (json['users'] != null) {
      users = <UsersWorkspace>[];
      json['users'].forEach((v) {
        users!.add(UsersWorkspace.fromJson(v));
      });
    }
    userIds = json['user_ids'].cast<int>();
    if (json['clients'] != null) {
      clients = <ClientsWorkspace>[];
      json['clients'].forEach((v) {
        clients!.add(ClientsWorkspace.fromJson(v));
      });
    }
    clientIds = json['client_ids'].cast<int>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['primaryWorkspace'] = primaryWorkspace;
    data['defaultWorkspace'] = defaultWorkspace;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    data['user_ids'] = userIds;
    if (clients != null) {
      data['clients'] = clients!.map((v) => v.toJson()).toList();
    }
    data['client_ids'] = clientIds;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class UsersWorkspace {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? photo;

  UsersWorkspace({this.id, this.firstName, this.lastName, this.photo});

  UsersWorkspace.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    photo = json['photo'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['photo'] = photo;
    data['email'] = email;
    return data;
  }
}
class ClientsWorkspace {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? photo;

  ClientsWorkspace({this.id, this.firstName, this.lastName, this.photo});

  ClientsWorkspace.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    photo = json['photo'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['photo'] = photo;
    data['email'] = email;
    return data;
  }
}
