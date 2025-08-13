import 'package:JoDija_reposatory/reposetory/repsatory.dart';
import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
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
      inputSource: DataSourceFirebaseSource.insert(
        dataModel: order, path: FirebaseCollection.orders,

      ),
    );
    var result = await repo.addData( id: order.id);
    orderBloc.loadingState();
    result.pick(
      onData: (v) {
        orderBloc.successState(order);
      },
      onError: (error) {
        orderBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }


  void loadOrdersByShopId(String sopId) async {
    DataSourceRepo repo = DataSourceRepo(
        inputSource: DataSourceFirebaseSource(FirebaseCollection.orders
            , query: (query) => query.where("shopId", isEqualTo: sopId)));
    listOrdersBloc.loadingState();

    var result = await repo.getListData();

 result .pick(
      onData: (v) {
        if (v.data!.isEmpty) {
          listOrdersBloc.successState([]);
        } else {
          List<Order> orders = v.data!.map((e) => Order.fromJson(e.map!, e.id!)).toList();
          listOrdersBloc.successState(orders);
        }
      },
      onError: (error) {
        listOrdersBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  // Load all orders
  void loadAllOrders() async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.orders),
    );

    var result = await repo.getListData();
    listOrdersBloc.loadingState();

    result.pick(
      onData: (v) {
        if (v.data!.isEmpty) {
          listOrdersBloc.successState([]);
        } else {
          List<Order> orders = v.data!.map((e) => Order.fromJson(e.map!, e.id!)).toList();
          listOrdersBloc.successState(orders);
        }
      },
      onError: (error) {
        listOrdersBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }
}
