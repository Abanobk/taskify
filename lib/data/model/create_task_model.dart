class CreateTaskModel {
  bool? error;
  int? id;
  int? parentId;
  String? parentType;
  String? message;

  CreateTaskModel(
      {this.error, this.id, this.parentId, this.parentType, this.message});

  CreateTaskModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    id = json['id'];
    parentId = json['parent_id'];
    parentType = json['parent_type'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['id'] = id;
    data['parent_id'] = parentId;
    data['parent_type'] = parentType;
    data['message'] = message;
    return data;
  }
}