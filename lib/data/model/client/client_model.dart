class ClientModel {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? photo;

  ClientModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.photo,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'photo': photo,
    };
  }
} 