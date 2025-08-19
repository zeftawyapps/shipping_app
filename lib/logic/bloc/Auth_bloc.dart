import 'package:JoDija_reposatory/https/http_urls.dart';
import 'package:JoDija_reposatory/model/user/base_model/inhertid_models/user_model.dart';
import 'package:JoDija_reposatory/reposetory/user/auth_repo.dart';
import 'package:JoDija_reposatory/source/user/accountLoginLogout/auth_email_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:JoDija_tamplites/util/shardeprefrance/shard_check.dart';

import '../models/user.dart';

class AuthBloc {
  String emailKey = "email";
  String nameKey = "name";
  String passKey = "pass";
  String phone = "phone";
  String rePass = "rePass";

  DataSourceBloc<Users> userBloc = DataSourceBloc<Users>();

  void signUp({required Map<String, dynamic> map}) async {
    BaseAuthRepo accountSource = BaseAuthRepo(
      EmailPassowrdAuthSource(email: map[emailKey], pass: map[passKey]),
    );
    userBloc.loadingState();
    var data = UserModule(
      name: map[nameKey],
      email: map[emailKey],
      phone: map[phone],
    );
    var result = await accountSource.createAccountAndProfile(data);
    result.pick(
      onData: (v) {
        SharedPrefranceChecking sharedPrefranceChecking =
            SharedPrefranceChecking();
        sharedPrefranceChecking.setDataInShardRefrace(
          email: v.email!,
          pass: map[passKey]!,
          token: v.token!,
        );
        HttpHeader().setAuthHeader(v.token!, Bearer: "Bearer__");
        userBloc.successState(Users.formJson(v.toJson()));
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  void signeIn({required Map<String, dynamic> map}) async {
    BaseAuthRepo accountSource = BaseAuthRepo(
      EmailPassowrdAuthSource(email: map[emailKey], pass: map[passKey]),
    );
    userBloc.loadingState();
    var result = await accountSource.logIn();
    result.pick(
      onData: (v) {
        SharedPrefranceChecking sharedPrefranceChecking =
            SharedPrefranceChecking();
        sharedPrefranceChecking.setDataInShardRefrace(
          email: map[emailKey],
          pass: map[passKey]!,
          token: v.token!,
        );

        print ("token: ${v.token}");
        userBloc.successState(Users.formJson(v.toJson()));
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// change password
  void changePassword (  { required Users  user, required String oldpass , required String  newpass }) async {
    BaseAuthRepo accountSource = BaseAuthRepo(
      EmailPassowrdAuthSource(email: user.email ,  pass:  newpass ),
    );
    userBloc.loadingState();
    var result = await accountSource.changePassword(
       user.email,
       oldpass,
       newpass ,
    );
    result.pick(
      onData: (v) {
        Users users = Users(
          UId: v.uid,
          email: v.email!,
          name: v.name!,
          phone: user.phone!,
          createdAt: v.createdAt,
          role: user.role,
          isActive: user.isActive,
        );

        userBloc.successState(users);
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }
}
