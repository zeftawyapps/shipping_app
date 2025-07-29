import 'package:JoDija_reposatory/reposetory/repsatory_http.dart';
import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:shipping_app/constants/values/firebase_collections.dart';

import '../models/driver.dart';

class DriversBloc {
  static final DriversBloc _singleton = DriversBloc._internal();
  factory DriversBloc() {
    return _singleton;
  }
  DriversBloc._internal();

  DataSourceBloc<Driver> driverBloc = DataSourceBloc<Driver>();
  DataSourceBloc<List<Driver>> listDriversBloc = DataSourceBloc<List<Driver>>();

  void insertDriver(Driver driver) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.insert(dataModel: driver, path: FirebaseCollection.drivers,),
    );
    var result = await repo.addData();
    driverBloc.loadingState();
    result.pick(
      onData: (v) {
        driverBloc.successState(Driver.fromJson(driver.toJson()));
      },
      onError: (error) {
        driverBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  // Add more methods as needed
}

