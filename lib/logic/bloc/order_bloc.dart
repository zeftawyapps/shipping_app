import 'package:JoDija_reposatory/reposetory/repsatory_http.dart';
import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:shipping_app/constants/values/firebase_collections.dart';

import '../models/order.dart';

class OrdersBloc {
  static final OrdersBloc _singleton = OrdersBloc._internal();
  factory OrdersBloc() {
    return _singleton;
  }
  OrdersBloc._internal();

  DataSourceBloc<Order> orderBloc = DataSourceBloc<Order>();
  DataSourceBloc<List<Order>> listOrdersBloc = DataSourceBloc<List<Order>>();

  void insertOrder(Order order) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.insert(dataModel: order, path: FirebaseCollection.orders,),
    );
    var result = await repo.addData();
    orderBloc.loadingState();
    result.pick(
      onData: (v) {
        orderBloc.successState(Order.fromJson(order.map!));
      },
      onError: (error) {
        orderBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  // Add more methods as needed
}

