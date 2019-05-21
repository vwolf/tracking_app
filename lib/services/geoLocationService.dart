import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import '../database/models/trackCoord.dart';

class GeoLocationService {

  GeolocationStatus status = GeolocationStatus.unknown;
  Geolocator geolocator = Geolocator();
  LocationOptions locationOptions = LocationOptions(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  LatLng location = new LatLng(0.0000, 0.0000);

  StreamSubscription<Position> _positionStream;
  StreamController trackerStream;

  GeoLocationService._();
  static final GeoLocationService gls = GeoLocationService._();

  GeolocationStatus _geolocationStatus;

  cleanUp() {
    _positionStream.cancel();
    trackerStream.close();
  }


  /// Convert LatLng object to json
  String latlngToJson(LatLng latlng) {
    return jsonEncode( {"lat": latlng.latitude, "lon": latlng.longitude} );
  }

  /// Map TrackCoord's to LatLng object
  List<LatLng> latlngToLatLng(List<TrackCoord> trackCoords) {
    List<LatLng> latlngFromCoords = [];
    trackCoords.forEach((TrackCoord trackCoord) {
      latlngFromCoords.add(LatLng(trackCoord.latitude, trackCoord.longitude));
    });
    return latlngFromCoords;
  }

  /// String to LatLng
  LatLng stringToLatLng(String latlng) {
    var latlngJson = jsonDecode(latlng);
    return LatLng(latlngJson['lat'], latlngJson['lon']);
  }


  /// Return Geolocation position as LatLng
  Future<LatLng> simpleLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    location.latitude = position.latitude;
    location.longitude = position.longitude;
    return location;
  }

  /// Return Geolocation position as Position
  Future<Position> getPosition() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return position;
  }


  subscribeToPositionStream( [StreamController streamToParent]) {
    trackerStream = streamToParent;
    _positionStream = geolocator.getPositionStream(locationOptions)
        .listen((Position _position) {
      print(_position == null ? 'Unknown' : _position.latitude.toString() + ', ' + _position.longitude.toString());
      if (_position != null) {
        if ( streamToParent == null ) {
          //_trackingPoints.add(LatLng(_position.latitude, _position.longitude));
        } else {
          trackerStream.add(_position);
        }
        //

      }
    });
  }

  unsubcribeToPositionStream() {
    if (_positionStream != null ) {
      _positionStream.cancel();
    }
  }


  /// Get placemarks from coordinates
  getPlacemarksFromCoords(LatLng latlng) async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(latlng.latitude, latlng.longitude);

    if (placemark.length > 0) {
      print(placemark[0].country);
      print(placemark[0].position);
      print(placemark[0].locality);
      print(placemark[0].administrativeArea);
      print(placemark[0].postalCode);
      print(placemark[0].name);
      print(placemark[0].subAdministrativeArea);
      print(placemark[0].isoCountryCode);
      print(placemark[0].subLocality);
      print(placemark[0].subThoroughfare);
      print(placemark[0].thoroughfare);
    }
  }

  /// Get a description of a coord
  /// country + locality + administrativeArea
  Future<String> getCoordDescription(LatLng latlng) async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(latlng.latitude, latlng.longitude);

    String description = placemark[0].country + ', ' + placemark[0].locality + ', ' + placemark[0].administrativeArea;
    return description;
  }

  /// Get distance between coordinates
  Future<double> getDistanceBetweenCoords(LatLng coord1, LatLng coord2) async {
    double distanceInMeters = await Geolocator().distanceBetween(coord1.latitude, coord1.longitude, coord2.latitude, coord2.longitude);
    return distanceInMeters;
  }
}

