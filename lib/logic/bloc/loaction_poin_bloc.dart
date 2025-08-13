import 'dart:math' as math;
import 'package:JoDija_reposatory/reposetory/repsatory.dart';
import 'package:JoDija_reposatory/source/firebase/crud_firebase_source.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/base_bloc.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/remote_base_model.dart';
import 'package:shipping_app/constants/values/firebase_collections.dart';
import 'package:shipping_app/logic/models/location_point.dart';
import 'package:shipping_app/logic/models/location.dart';

class LocationPointBloc {
  static final LocationPointBloc _singleton = LocationPointBloc._internal();

  factory LocationPointBloc() {
    return _singleton;
  }

  LocationPointBloc._internal();

  // Location point blocs
  DataSourceBloc<LocationPoint> locationPointBloc = DataSourceBloc<LocationPoint>();
  DataSourceBloc<List<LocationPoint>> listLocationPointsBloc = DataSourceBloc<List<LocationPoint>>();
  DataSourceBloc<List<LocationPoint>> shopLocationPointsBloc = DataSourceBloc<List<LocationPoint>>();
  DataSourceBloc<List<LocationPoint>> driverLocationPointsBloc = DataSourceBloc<List<LocationPoint>>();
  DataSourceBloc<List<LocationPoint>> orderLocationPointsBloc = DataSourceBloc<List<LocationPoint>>();

  // ====================== LOCATION POINTS CRUD METHODS ======================
  
  /// Create a new location point
  void createLocationPoint(LocationPoint locationPoint) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.addData();
    locationPointBloc.loadingState();

    result.pick(
      onData: (v) {
        locationPointBloc.successState(locationPoint);
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Get a single location point by ID
  void loadLocationPointById(String id) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getSingleData(id);
    locationPointBloc.loadingState();
    
    result.pick(
      onData: (v) {
        String id = v.data!.id ?? '';
        LocationPoint locationPoint = LocationPoint.fromJson(v.data!.map!, id);
        locationPointBloc.successState(locationPoint);
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Load all location points
  void loadAllLocationPoints() async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    listLocationPointsBloc.loadingState();

    result.pick(
      onData: (v) {
        List<LocationPoint> locationPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        listLocationPointsBloc.successState(locationPoints);
      },
      onError: (error) {
        listLocationPointsBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Load location points by type
  void loadLocationPointsByType(LocationType type) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    
    DataSourceBloc<List<LocationPoint>> targetBloc;
    switch (type) {
      case LocationType.shop:
        targetBloc = shopLocationPointsBloc;
        break;
      case LocationType.driver:
        targetBloc = driverLocationPointsBloc;
        break;
      case LocationType.order_pickup:
      case LocationType.order_delivery:
        targetBloc = orderLocationPointsBloc;
        break;
    }
    
    targetBloc.loadingState();

    result.pick(
      onData: (v) {
        List<LocationPoint> allLocationPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        
        List<LocationPoint> filteredPoints = allLocationPoints
            .where((point) => point.type == type)
            .toList();
            
        targetBloc.successState(filteredPoints);
      },
      onError: (error) {
        targetBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Update an existing location point
  void updateLocationPoint(LocationPoint locationPoint) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource.edit(
        dataModel: locationPoint, 
        path: FirebaseCollection.locationPoints,
      ),
    );
    var result = await repo.updateData(locationPoint.locationId);
    locationPointBloc.loadingState();

    result.pick(
      onData: (v) {
        locationPointBloc.successState(locationPoint);
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Update location point's position only
  void updateLocationPointPosition(String locationPointId, double latitude, double longitude) async {
    // First get the existing location point
    DataSourceRepo getRepo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var getResult = await getRepo.getSingleData(locationPointId);
    
    getResult.pick(
      onData: (v) async {
        LocationPoint existingPoint = LocationPoint.fromJson(v.data!.map!, v.data!.id!);
        
        // Create new location with updated coordinates
        Location newLocation = Location(latitude: latitude, longitude: longitude);
        
        // Create updated location point
        LocationPoint updatedPoint = existingPoint.copyWith(
          location: newLocation,
          lastUpdated: DateTime.now(),
        );
        
        // Save the updated point
        DataSourceRepo updateRepo = DataSourceRepo(
          inputSource: DataSourceFirebaseSource.edit(
            dataModel: updatedPoint, 
            path: FirebaseCollection.locationPoints,
          ),
        );
        var updateResult = await updateRepo.updateData(locationPointId);
        locationPointBloc.loadingState();
        
        updateResult.pick(
          onData: (v) {
            locationPointBloc.successState(updatedPoint);
          },
          onError: (error) {
            locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
          },
        );
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Delete a location point
  void deleteLocationPoint(String locationPointId) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.deleteData(locationPointId);
    locationPointBloc.loadingState();

    result.pick(
      onData: (v) {
        locationPointBloc.successState(LocationPoint(
          locationId: locationPointId,
          name: 'Deleted',
          location: Location(latitude: 0, longitude: 0),
          type: LocationType.shop,
          lastUpdated: DateTime.now(),
          isActive: false,
        ));
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Add shop point
  void addShopPoint({
    required String shopId,
    required String shopName,
    required double latitude,
    required double longitude,
    String? address,
    String? phone,
    bool isActive = true,
    Map<String, dynamic>? additionalData,
  }) async {
    LocationPoint shopPoint = LocationPoint.fromShop(
      shopId: shopId,
      shopName: shopName,
      location: Location(latitude: latitude, longitude: longitude),
      address: address,
      phone: phone,
      isActive: isActive,
      additionalData: additionalData,
    );

    createLocationPoint(shopPoint);
  }

  /// Add driver point
  void addDriverPoint({
    required String driverId,
    required String driverName,
    required double latitude,
    required double longitude,
    String? phone,
    String? status,
    double? rating,
    bool isActive = true,
  }) async {
    LocationPoint driverPoint = LocationPoint.fromDriver(
      driverId: driverId,
      driverName: driverName,
      location: Location(latitude: latitude, longitude: longitude),
      phone: phone,
      status: status,
      rating: rating,
      isActive: isActive,
    );

    createLocationPoint(driverPoint);
  }

  /// Add order pickup point
  void addOrderPickupPoint({
    required String orderId,
    required String shopName,
    required double latitude,
    required double longitude,
    String? customerName,
    String? orderStatus,
    double? totalPrice,
    Map<String, dynamic>? additionalData,
  }) async {
    LocationPoint orderPoint = LocationPoint.fromOrderPickup(
      orderId: orderId,
      shopName: shopName,
      location: Location(latitude: latitude, longitude: longitude),
      customerName: customerName,
      orderStatus: orderStatus,
      totalPrice: totalPrice,
      additionalData: additionalData,
    );

    createLocationPoint(orderPoint);
  }

  /// Add order delivery point
  void addOrderDeliveryPoint({
    required String orderId,
    required String customerName,
    required double latitude,
    required double longitude,
    String? address,
    String? phone,
    String? orderStatus,
    double? totalPrice,
    Map<String, dynamic>? additionalData,
  }) async {
    LocationPoint deliveryPoint = LocationPoint.fromOrderDelivery(
      orderId: orderId,
      customerName: customerName,
      location: Location(latitude: latitude, longitude: longitude),
      address: address,
      phone: phone,
      orderStatus: orderStatus,
      totalPrice: totalPrice,
      additionalData: additionalData,
    );

    createLocationPoint(deliveryPoint);
  }

  /// Update driver's current location
  void updateDriverLocation(String driverId, double latitude, double longitude) async {
    // Find the driver's location point and update it
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    
    result.pick(
      onData: (v) async {
        List<LocationPoint> allPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        
        LocationPoint? driverPoint = allPoints
            .where((point) => point.type == LocationType.driver && point.entityId == driverId)
            .firstOrNull;
            
        if (driverPoint != null) {
          updateLocationPointPosition(driverPoint.locationId, latitude, longitude);
        }
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Update shop's location
  void updateShopLocation(String shopId, double latitude, double longitude) async {
    // Find the shop's location point and update it
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    
    result.pick(
      onData: (v) async {
        List<LocationPoint> allPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        
        LocationPoint? shopPoint = allPoints
            .where((point) => point.type == LocationType.shop && point.entityId == shopId)
            .firstOrNull;
            
        if (shopPoint != null) {
          updateLocationPointPosition(shopPoint.locationId, latitude, longitude);
        }
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Get active location points only
  void loadActiveLocationPoints() async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    listLocationPointsBloc.loadingState();

    result.pick(
      onData: (v) {
        List<LocationPoint> allLocationPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        
        List<LocationPoint> activePoints = allLocationPoints
            .where((point) => point.isActive)
            .toList();
            
        listLocationPointsBloc.successState(activePoints);
      },
      onError: (error) {
        listLocationPointsBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Toggle location point active status
  void toggleLocationPointActiveStatus(String locationPointId) async {
    // First get the existing location point
    DataSourceRepo getRepo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var getResult = await getRepo.getSingleData(locationPointId);
    
    getResult.pick(
      onData: (v) async {
        LocationPoint existingPoint = LocationPoint.fromJson(v.data!.map!, v.data!.id!);
        
        // Toggle the active status
        existingPoint.isActive = !existingPoint.isActive;
        existingPoint.lastUpdated = DateTime.now();
        
        // Save the updated point
        updateLocationPoint(existingPoint);
      },
      onError: (error) {
        locationPointBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Load location points by entity ID
  void loadLocationPointsByEntityId(String entityId) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    listLocationPointsBloc.loadingState();

    result.pick(
      onData: (v) {
        List<LocationPoint> allLocationPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        
        List<LocationPoint> filteredPoints = allLocationPoints
            .where((point) => point.entityId == entityId)
            .toList();
            
        listLocationPointsBloc.successState(filteredPoints);
      },
      onError: (error) {
        listLocationPointsBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Load location points within a radius
  void loadLocationPointsInRadius({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    DataSourceRepo repo = DataSourceRepo(
      inputSource: DataSourceFirebaseSource(FirebaseCollection.locationPoints),
    );
    var result = await repo.getListData();
    listLocationPointsBloc.loadingState();

    result.pick(
      onData: (v) {
        List<LocationPoint> allLocationPoints = v.data!
            .map((e) => LocationPoint.fromJson(e.map!, e.id!))
            .toList();
        
        List<LocationPoint> nearbyPoints = allLocationPoints.where((point) {
          double distance = _calculateDistance(
            centerLat, centerLng,
            point.location.latitude, point.location.longitude,
          );
          return distance <= radiusKm;
        }).toList();
            
        listLocationPointsBloc.successState(nearbyPoints);
      },
      onError: (error) {
        listLocationPointsBloc.failedState(ErrorStateModel(message: error.message), () {});
      },
    );
  }

  /// Calculate distance between two points in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}