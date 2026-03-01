import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel{
  @HiveField(0)
  String? email;

  @HiveField(1)
  String? password;

  @HiveField(2)
  String? firstname;

  @HiveField(3)
  String? lastname;

  @HiveField(4)
  String? company;

  @HiveField(5)
  String? userProfilePhoto;

  @HiveField(6)
  String? role;

  @HiveField(7)
  String? type;

  UserModel({
    this.email,
    this.password,
    this.firstname,
    this.lastname,
    this.company,
    this.userProfilePhoto,
    this.role,
    this.type
  });
}