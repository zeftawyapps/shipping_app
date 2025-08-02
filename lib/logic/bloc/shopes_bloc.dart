import 'package:JoDija_reposatory/reposetory/repsatory_http.dart';
import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:shipping_app/constants/values/firebase_collections.dart';
import 'package:shipping_app/logic/models/shop.dart';

import '../models/driver.dart';

class ShopesBloc {
  static final ShopesBloc _singleton = ShopesBloc._internal();
  factory ShopesBloc() {
    return _singleton;
  }
  ShopesBloc._internal();

  DataSourceBloc<Shop> shopesBloc = DataSourceBloc<Shop>();
  DataSourceBloc<List<Shop>> listShopessBloc = DataSourceBloc<List<Shop>>();

// get the shope by is
  void loadShopById(String  id ) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.shops,  )
    );
    var result = await repo .getSingleData(id);
    shopesBloc.loadingState();
    result.pick(
      onData: (v) {
     String id =    v.data!.id  ?? '';

     Shop shop = Shop.fromJson(v.data!.map!, id);

        shopesBloc.successState(shop);
      },
      onError: (error) {
        shopesBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }
  // Add more methods as needed



  void editShops(Shop shops) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.edit(dataModel: shops, path: FirebaseCollection.shops,),
    );
    var result = await repo.updateData(shops.shopId ?? '');
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

