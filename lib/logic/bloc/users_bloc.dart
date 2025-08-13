import 'package:JoDija_reposatory/reposetory/repsatory.dart';
import 'package:JoDija_reposatory/reposetory/user/auth_repo.dart';
import 'package:JoDija_reposatory/source/user/accountLoginLogout/auth_email_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
 import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';
import 'package:JoDija_reposatory/utilis/models/remote_base_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:shipping_app/constants/values/firebase_collections.dart';

import '../models/user.dart';

class UsersBloc {

  static final UsersBloc _singleton = UsersBloc._internal();
  factory UsersBloc() {
    return _singleton;
  }
  UsersBloc._internal();

  DataSourceBloc<Users> userBloc =
  DataSourceBloc<Users>();


  DataSourceBloc<List<Users>> listUsersBloc =
  DataSourceBloc<List<Users>>();

  void addUser(Users users)async {
    BaseAuthRepo accountSource = BaseAuthRepo(EmailPassowrdAuthSource(email:  users.email  , pass: users.passwordHash! ) );
    userBloc.loadingState() ;
     var result =   await  accountSource.createAccountAndProfile(users );
    result.pick(onData: (v) {
      userBloc.successState( Users.formJson(v.toJson())  )   ;
    }, onError: (error) {
      userBloc.failedState(ErrorStateModel(message: error.message) , () {});
    });

  }

  void insertUser(Users users) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.insert(dataModel: users, path: FirebaseCollection.users,),
    );

    var result = await repo.addData();
    userBloc.loadingState();

    result.pick(
      onData: (v) {
        userBloc.successState(Users.formJson(users.map!));
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }


  // add edit user 
  void editUser(Users users) async {
    DataSourceRepo repo = DataSourceRepo(
       inputSource: DataSourceFirebaseSource.edit(dataModel: users, path: FirebaseCollection.users,),
    );
    
    var result = await repo.updateData(users.UId   ?? '');
    userBloc.loadingState();
     
    result.pick(
      onData: (v) {
        userBloc.successState(users);
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  void deleteUser(String id) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.delete(  path: FirebaseCollection.users),
    );

    var result = await repo.deleteData(id);
    userBloc.loadingState();

    result.pick(
      onData: (v) {
        userBloc.successState(Users.formJson(v));
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }
  // load users
  void loadUsers() async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource ( FirebaseCollection.users),
    );

    var result = await repo.getListData();
    listUsersBloc.loadingState();

    result.pick(
      onData: (v) {
        List<Users> usersList = v.data!.map((e) => Users.formJson(e.map! , id:  e.id  )).toList();
        listUsersBloc.successState(usersList);
      },
      onError: (error) {
        userBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }
  
}