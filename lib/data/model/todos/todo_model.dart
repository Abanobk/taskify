import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final bool? error;
  final String? message;
  final int? total;
  final List<TodosModel>? todos;

  const Todo({this.error, this.message, this.total, this.todos});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      error: json['error'] as bool?,
      message: json['message'] as String?,
      total: json['total'] as int?,
      todos: (json['todos'] as List<dynamic>?)
          ?.map((v) => TodosModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['total'] = total;

    if (todos != null) {
      data['todos'] = todos!.map((v) => v.toJson()).toList();
    }

    return data;
  }

  @override
  List<Object?> get props => [error, message, todos, total];
}

class TodosModel {
  int? id;
  String? title;
  String? description;
  String? priority;
  int? isCompleted;
  String? createdAt;
  String? updatedAt;

  TodosModel(
      {this.id,
        this.title,
        this.description,
        this.priority,
        this.isCompleted,
        this.createdAt,
        this.updatedAt});

  TodosModel copyWith(
      {int? id,
        String? title,
        String? description,
        String? priority,
        int? isCompleted,
        String? createdAt,
        String? updatedAt}) {
    return TodosModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  TodosModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    priority = json['priority'];
    isCompleted = json['is_completed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['priority'] = priority;
    data['is_completed'] = isCompleted;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
