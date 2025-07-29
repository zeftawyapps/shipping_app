import 'package:shipping_app/logic/models/user.dart';

class UserDataLoaded {
  // singl ton instance
  static final UserDataLoaded _instance = UserDataLoaded._internal();
  factory UserDataLoaded() {
    return _instance;
  }

  UserDataLoaded._internal();
Users? users ;
  void setUser(Users user) {
    users = user;
  }

  Users? getUser() {
    return users;
  }

}