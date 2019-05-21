import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../track/trackService.dart';
import '../services/geoLocationService.dart';
import 'trackingMapStatusLayer.dart';

import '../database/models/trackCoord.dart';
import '../database/models/trackItem.dart';

import '../gpx/gpxWriter.dart';
import '../readWrite/writeTrack.dart';

/// Map to display the [TrackCoord]'s as path, the current position and [TrackItem]'s
/// 
/// ToDo: Save trackPoints and trackItems
/// ToDo: Convert trackPoints to gpx data
/// ToDo: Save trackItems to db
class TrackingMap extends StatefulWidget  {
  final StreamController<TrackPageStreamMsg> streamController;
  final TrackService trackService;

  TrackingMap(this.trackService, this.streamController);

  @override
  TrackingMapState createState() => TrackingMapState(trackService, streamController);
}


class TrackingMapState extends State<TrackingMap>  {
  StreamController<TrackPageStreamMsg> streamController;
  StreamController trackerStreamController;
  TrackService trackService;

  TrackingMapState(this.trackService, this.streamController);

  bool _tracking = true;

  /// MapController
  MapController mapController;
  TrackingMapStatusLayer _mapStatusLayer = TrackingMapStatusLayer('location_on');

  //LatLng get startPos => TrackServiceInherited.of(context).trackService.getStartCoord();
  //LatLng get startPos => _trackService.getStartCoord();

  LatLng get startPos => widget.trackService.getStartCoord();

  @override
  void initState() {
    super.initState();

    streamInit();
    toggleTracker(_tracking);
    //streamController.add(TrackPageStreamMsg("mapInit", "ready"));
  }


  @override
  void dispose() {
    streamController.close();
    toggleTracker(false);
    saveTrackToGpx();
    super.dispose();
  }


  streamInit(){
    streamController.stream.listen((event) {
      streamEvent(event);
    });
  }


  streamEvent(TrackPageStreamMsg event){
    print('TrackingMap.streamEvent $event');

    switch (event.type) {
      case "newDefaultCoord" :
        setState(() {
          startPos;
          mapController.move(startPos, mapController.zoom);
        });
      break;

      case "trackingMapStatusAction" :
        if (event.msg == "location_on") {
          _tracking = !_tracking;
          toggleTracker(_tracking);
          _mapStatusLayer.statusNotification(_tracking == true ? "location_on" : "locaton_off");
          setState(() {

          });
        }
        break;

      default: print('TrackingMap.streamEvent: unkown event type ${event.type}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: startPos,
          zoom: 15,
          minZoom: 4,
          maxZoom: 18,
          plugins: [
            _mapStatusLayer,
          ]
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: trackService.trackLatlngPoints,
                strokeWidth: 4.0,
                color: Colors.blueAccent,
              )
            ]
          ),
          MarkerLayerOptions(
            markers: markerList,
          ),
          TrackingMapStatusLayerOptions(streamController: streamController),
        ],
      )
    );
  }

  List<Marker> get markerList => getMarkerList();

  List<Marker> getMarkerList() {
    List<Marker> ml = [];
    for ( var i = 0; i < trackService.trackItems.length; i++) {
      Marker newMarker = Marker(
        width: 40.0,
        height: 40.0,
        point: jsonDecode(trackService.trackItems[i].latlng),
        builder: (ctx) =>
            Container(
              child: Icon(
                Icons.location_on,
                color: Colors.green,
              ),
            )
      );

      ml.add(newMarker);
    }

    return ml;
  }



  /// Subscribe / Unsubscribe to PositionStream in Geolocation
  toggleTracker(bool trackState) {
    print("tourmap.toggleTracker to $trackState");
    if (trackState == true) {
      trackerStreamSetup();
      GeoLocationService.gls.subscribeToPositionStream(trackerStreamController);
    } else {
      GeoLocationService.gls.unsubcribeToPositionStream();
    }
  }

  trackerStreamSetup() {
    trackerStreamController = StreamController();
    trackerStreamController.stream.listen((coords) {
      onTrackerEvent(coords);

    });
  }

  /// Send position as [TrackCoord] to trackService
  onTrackerEvent(Position coords) {
    print(coords);

    Map tmp = coordToMap(coords);
    TrackCoord.fromMap(tmp);

    //trackService.addTrackPoint(LatLng(coords.latitude, coords.longitude));
    trackService.addTrackCoord( TrackCoord.fromMap(tmp));

    //_tourGpxData.trackPoints.add(LatLng(coords.latitude, coords.longitude));
  }

  /// Convert position object to TrackCord Map
  Map<String, dynamic>coordToMap(Position coord) {
    Map<String, dynamic> tmp = {
      "id": null,
      "latitude": coord.latitude,
      "longitude": coord.longitude,
      "altitude": coord.altitude,
      "timestamp": coord.timestamp,
      "accuracy": coord.accuracy,
      "heading": coord.heading,
      "speed": coord.speed,
      "speedAccuracy": coord.speedAccuracy,
      "item": null,
    };
    return tmp;
  }


  /// Save track points to gpx file
  void saveTrackToGpx() {
    GpxWriter gpxWriter = GpxWriter();
    var xml = gpxWriter.buildGpx(trackService.trackCoords);

    String directoryName = '/Tracks/${trackService.track.name}';

  }
}



//class MapService {
//
//  //MapService();
//
//  bool mapService = true;
//
//  LatLng getStartPos() {
//    return LatLng(0.0, 0.0);
//  }
//
//}