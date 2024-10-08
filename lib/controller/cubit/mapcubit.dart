// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:usaficity/data/models/location.dart';

import '../state/mapstate.dart';
import '../../data/services/db.dart';
import '../../app/shared/shared.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(InitialState());

  static MapCubit get(context) => BlocProvider.of(context);

  void createMap(user) {
    DBServices().updateUserLocation(
      user.email,
      Location(
        lat: currentLocation!.latitude,
        lng: currentLocation!.longitude,
      ),
    );
  }

  static dynamic destination = LatLng(-2.404338883207981, 28.838976997537976);
  static dynamic source = LatLng(-2.5007389434069105, 28.849003662179616);

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;

  bool? serviceEnabled;
  Position? currentLocation;
  LocationPermission? permissionGranted;
  dynamic currentPlace;
  Geolocator geolocator = Geolocator();

  dynamic distanceRestant = Geolocator.distanceBetween(
    -2.4034369199135437,
    28.839082703376597,
    -2.4992107119225553,
    28.868730999629342,
  );

  setCustomMatkerIcons() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      AppImages.logo,
    ).then(
      (icon) => sourceIcon = icon,
    );
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      AppImages.gdsclogo,
    ).then(
      (icon) => destinationIcon = icon,
    );
    emit(SetCustomMarkerIconsState());
  }

  getCurrentLocation() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == true) {}

    permissionGranted = await Geolocator.checkPermission();
    if (permissionGranted == LocationPermission.denied) {
      permissionGranted = await Geolocator.requestPermission();
      if (permissionGranted == LocationPermission.whileInUse) {}
    }

    currentLocation = await Geolocator.getCurrentPosition();

    emit(GetCurrentLocationState());
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    // PolylinePoints polylinePoints = PolylinePoints();

    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   google_api_key,
    //   PointLatLng(source.latitude, source.longitude),
    //   PointLatLng(destination.latitude, destination.longitude),
    //   travelMode: TravelMode.driving,
    //   wayPoints: [PolylineWayPoint(location: "Bukavu, DRC")], request: null,
    // );

    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
    //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    //   });
    // }
    emit(GetPolyPointState());
  }

  List<Marker> markers = [
    Marker(
      markerId: MarkerId('source'),
      infoWindow: InfoWindow(
        title: "1ère Station",
        snippet: 'Parking du Gouverneur',
      ),
      position: source,
    ),
    Marker(
      markerId: MarkerId('destination'),
      infoWindow: InfoWindow(
        title: "Base",
        snippet: "Base de l'Agence IITA/RUNRES",
      ),
      position: destination,
    ),
  ];

  getUserLocation(user) {
    DBServices().addUserLocation(
      UserLoc(
        name: user.displayName,
        email: user.email,
        location: Location(
          lat: currentLocation!.latitude,
          lng: currentLocation!.longitude,
        ),
      ),
    );
  }
}
