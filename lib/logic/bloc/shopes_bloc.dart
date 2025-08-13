import 'package:JoDija_reposatory/reposetory/repsatory.dart';
import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:shipping_app/constants/values/firebase_collections.dart';
import 'package:shipping_app/logic/models/shop.dart';

class ShopesBloc {
  static final ShopesBloc _singleton = ShopesBloc._internal();
  factory ShopesBloc() {
    return _singleton;
  }
  ShopesBloc._internal();

  // Shop-specific blocs only
  DataSourceBloc<Shop> shopesBloc = DataSourceBloc<Shop>();
  DataSourceBloc<List<Shop>> listShopessBloc = DataSourceBloc<List<Shop>>();

  // get the shope by id
  void loadShopById(String id) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.shops)
    );
    var result = await repo.getSingleData(id);
    shopesBloc.loadingState();
    result.pick(
      onData: (v) {
        String id = v.data!.id ?? '';
        Shop shop = Shop.fromJson(v.data!.map!, id);
        shopesBloc.successState(shop);
      },
      onError: (error) {
        shopesBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  // Load all shops
  void loadShops() async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.shops),
    );

    var result = await repo.getListData();
    listShopessBloc.loadingState();

    result.pick(
      onData: (v) {
        List<Shop> shopsList = v.data!.map((e) => Shop.fromJson(e.map!, e.id!)).toList();
        listShopessBloc.successState(shopsList);
      },
      onError: (error) {
        listShopessBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  // Edit shop
  void editShops(Shop shops) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.edit(dataModel: shops, path: FirebaseCollection.shops),
    );
    var result = await repo.updateData(shops.shopId);
    shopesBloc.loadingState();

    result.pick(
      onData: (v) {
        shopesBloc.successState(shops);
      },
      onError: (error) {
        shopesBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }
}

