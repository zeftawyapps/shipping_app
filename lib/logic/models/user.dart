// نموذج بيانات المستخدم

import 'package:JoDija_reposatory/model/user/base_model/base_user_module.dart';
import 'package:JoDija_reposatory/model/user/base_model/inhertid_models/user_model.dart';
import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';

enum UserRole { admin, driver, shop_owner }

class Users   extends UsersBaseModel  implements BaseEntityDataModel{
    String? id;
  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final UserRole role;

  final bool isActive;


  Users({
     this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    required this.isActive,

  })   {

     toJson() ;
  }

  // add a copyWith method to allow for easy copying with modifications
  Users copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    UserRole? role,

    bool? isActive,
  }) {
    return Users(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }


  Map<String, dynamic> toJson() {

    map = Map() ;

     map = {
      'uid': id,
      'name': name,
      'email': email,
      'phone': phone,

      'role': role.name,
      'createdAt': createdAt?.toIso8601String(),
       'isArchived': isArchived ?? false,
       'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
     return map! ;
  }

  factory Users.formJson(Map<String, dynamic> json , {String? id})  {


   return   Users(
      id: json['uid'] ??  id ?? "",
      name: json['name'],
      email: json['email'],
      phone: json['phone']??"",
      passwordHash: json['passwordHash']??"SDAfdsf",
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      createdAt: DateTime.parse(json['createdAt']??"2025-07-08T10:00:00Z" ),
      isActive: json['isActive']??true ,
    );
  }



  @override
  Map<String, dynamic>? map;

    @override
    bool? isArchived;

    @override
    DateTime? createdAt;

    @override
    DateTime? updatedAt;
}
