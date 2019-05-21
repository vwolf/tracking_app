import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:latlong/latlong.dart';
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../database/models/track.dart';
import '../database/models/trackCoord.dart';
import '../database/models/trackItem.dart';

import '../services/geoLocationService.dart';
import '../gpx/gpxParser.dart';
import '../readWrite/readFile.dart';

import '../map/itemDialog.dart';

/// Common functionality for [TrackMap] and [TrackingMap].
///
/// [track] existing or default [Track] object.
class TrackService {

  final Track track;

  TrackService(this.track);

  GpxFileData gpxFileData = GpxFileData();

  // list of coords in table trackCoord
  List<TrackCoord> trackCoords;
  // list of LatLng, used to make track path
  List<LatLng> trackLatlngPoints = [];
  // List of TrackItems to create markers
  List<TrackItem> trackItems = [];

  TrackCoord markerSelected;

  TrackItem _trackItem;
  TrackItem trackItem;


  int markerInspectIdx;

  /// Read file and parse into TourGpxData.
  ///
  /// Convert GpxCoords to [LatLng].
  /// [path] path to file.
  Future<TrackGpxData> getTrack(String path) async {
    // read file
    final fc = await ReadFile().readFile(path);

    // parse file
    gpxFileData = await new GpxParser(fc).parseData();
    print(gpxFileData.gpxCoords.length);
    // create LatLng points for markers
    gpxFileData.coordsToLatlng();
  }


  /// Read table 'trackname_+ coord and put into [trackCoords] list.
  ///
  ///
  /// If no trackPoints start with blank track
  /// 1. Set start coordinates of track first trying [track.coords] then [GeoLocationService.currentPosition].
  Future<bool> getDatabaseData() async {
    List<TrackCoord> coords = await DBProvider.db.getTrackCoords(track.track);
    if (coords.length > 0) {
      print("Coords in ${track.track}: ${coords.length}");
      trackCoords = coords.toList();
      // make list with LatLng points
      trackLatlngPoints = GeoLocationService.gls.latlngToLatLng(trackCoords);
      // update track coords if not set on not equal to first point in coords
      setStartCoord(coords);

      // get items
      getTrackItems();
      return true;
    } else {
      trackCoords = [];
      if (track.coords != null) {
        // add tour.coords as first point to trackPoints
        var startCoordJson = jsonDecode(track.coords);
        TrackCoord startCoord = TrackCoord(
            latitude: startCoordJson["lat"],
            longitude: startCoordJson["lon"]);
        trackCoords.add(startCoord);
        trackLatlngPoints = GeoLocationService.gls.latlngToLatLng(trackCoords);

        await addTrackPoint(LatLng(startCoord.latitude, startCoord.longitude));
        //return true;

      } else {
        LatLng currentPosition = await GeoLocationService.gls.simpleLocation();
        if (currentPosition != null) {
          // use currentPosition as start coords
          TrackCoord startCoord = TrackCoord(latitude: currentPosition.latitude,
              longitude: currentPosition.longitude);
          trackCoords.add(startCoord);
          trackLatlngPoints = GeoLocationService.gls.latlngToLatLng(trackCoords);
          // set tour.coords to startCoord
        }

        // if still no start coords set default
        trackCoords = coords.toList();
        //return true;
      }
    }

    if (track.items != null) {
      getTrackItems();
    }

  }

  /// Create and save an empty [Track] to be used when start tracking.
  ///
  /// Fill empty track with default values.
  ///
  //ToDo Sqlite tablename allowed character?
  Future saveEmptyTrack()  async {
    LatLng currentPos = await GeoLocationService.gls.simpleLocation();

    var name_ext = DateTime.now().toString();
    // replace not allowed chars in table name
    name_ext = name_ext.replaceAll(RegExp(r'[:\.\-]'), '_');
//    name_ext = name_ext.replaceAll(new RegExp(r':'), '_');
//    name_ext = name_ext.replaceAll(new RegExp(r'\.'), '_');
//    name_ext = name_ext.replaceAll(new RegExp(r'\-'), '_');
//    name_ext = name_ext.replaceAll(new RegExp(r' '), '_');
    track.name = 'track_' + name_ext;
    track.description = "position tracking";
    track.location = "to be set";
    track.timestamp = DateTime.now();
    track.createdAt = DateTime.now().toIso8601String();
    track.coords = GeoLocationService.gls.latlngToJson(currentPos);
    trackLatlngPoints.add(currentPos);
    trackCoords = [];

    TrackCoord newTrackCoord = TrackCoord(latitude: currentPos.latitude, longitude: currentPos.longitude, timestamp: DateTime.now());

    await DBProvider.db.newTrack(track);
    trackCoords.add(newTrackCoord);

    // get placement infos for location name
    GeoLocationService.gls.getPlacemarksFromCoords(currentPos);
    return true;
  }


  /// Add new track point to end of track then update trackPoints and trackLatLngPoints
  ///
  /// [latlng]
  addTrackPoint(LatLng latlng) async {

    TrackCoord newTrackCoord = TrackCoord(latitude: latlng.latitude, longitude: latlng.longitude, timestamp: DateTime.now());

    if (!trackCoords.contains(newTrackCoord)) {
      await DBProvider.db.addTrackCoord(newTrackCoord, track.track);
      trackCoords.add(newTrackCoord);
      trackLatlngPoints.add(latlng);
    } else {
      print("trackPoints contains $newTrackCoord");
    }
  }

  /// Add TrackCoord to DB. Update [trackLatlngPoints].
  ///
  /// [trackCoord] -
  /// [tableName] - optional, name of db table
  addTrackCoord( TrackCoord trackCoord,  {String tableName}  ) async {
    if (tableName == null) {
      tableName = track.track;
    }
    await DBProvider.db.addTrackCoord(trackCoord, tableName);
    trackLatlngPoints.add(LatLng(trackCoord.latitude, trackCoord.longitude));
  }


  /// Add a new [TrackCoord] at [index]. Used to add a marker to a path.
  ///
  addTrackCoordAtIndex(LatLng latlng, int index) async {
      TrackCoord trackCoord = TrackCoord(latitude: latlng.latitude, longitude: latlng.longitude);

      await DBProvider.db.insertTrackCoords(trackCoord, track.track, trackCoords[index].id);
      getDatabaseData();
  }

  /// Change coordinates at index to [latlng].
  changeTrackCoord(int index, LatLng latlng) async {
    trackLatlngPoints[index] = latlng;
    await DBProvider.db.updateTrackCoord(index + 1, track.track, "latitude", latlng.latitude);
    await DBProvider.db.updateTrackCoord(index + 1, track.track, "longitude", latlng.longitude);
  }

  /// Delete [TrackCoord] at [index].
  ///
  /// Special case: first trackpoint, which is also the startPoint in track.coords.
  ///
  /// Because the id of [TrackCoord]'s can change after deleting a trackPoint reload data.
  // TODO Update refs trackPoint - item
  deleteTrackPoint(int index) async {
    if ( index < trackLatlngPoints.length) {
      int trackCoordId = trackCoords[index].id;
      trackLatlngPoints.removeAt(index);
      trackCoords.removeAt(index);

      await DBProvider.db.deleteTrackCoord(trackCoordId, track.track);
      getDatabaseData();
    }
  }


  /// Get start coord. First try [trackLatlngPoints], then [Track.coords] then return default [LatLng].
  LatLng getStartCoord() {
    if (trackLatlngPoints.length > 0) {
      return trackLatlngPoints[0];
    }

    if (track.coords != null) {
      var coordsJson = jsonDecode(track.coords);
      return LatLng(coordsJson['lat'], coordsJson['lon']);
    }

    return LatLng(0.0, 0.0);
  }


  /// Set an [Track.coords], which is the start point of an [Track].
  /// If [coords] not equal to [Track.coords] replace with [coords].
  ///
  /// [coords]
  setStartCoord(List<TrackCoord> coords) async {
    if (track.coords == null && coords.length > 0) {
//      TrackCoord startCoord = coords.first;
//      LatLng startLatLng = LatLng(startCoord.latitude, startCoord.longitude);
//      var tc = GeoLocationService.gls.latlngToJson(startLatLng);
      await DBProvider.db.updateTrack(track);
    } else {
      var startCoordJson = jsonDecode(track.coords);
      LatLng startLatLng = LatLng(startCoordJson['lat'], startCoordJson['lon']);
      print( startLatLng.latitude );
      if ( startLatLng.latitude != coords.first.latitude ) {
        track.coords = GeoLocationService.gls.latlngToJson(LatLng(coords.first.latitude, coords.first.longitude));
        await DBProvider.db.updateTrack(track);
      }
    }
  }

  /// Set [markerSelected]
  ///
  /// Case: Gpx file track marker are not in [trackCoords]
  selectMarker( {trackPointIdx: null} ) {
    if ( trackPointIdx == null ) {
      markerSelected = null;
    } else {
      markerSelected = trackCoords[trackPointIdx];
    }
  }


  getTrackPointAtIndex(int index) {
    print("index $index");
  }


  setTrackMarkerInspect(int trackPointIdx) {

  }

  /// TrackItem
  /// Return new TrackItem or TrackItem for marker at index
  Future<TrackItem> getTrackItem(int trackPointIdx) async {
    if ( trackCoords[trackPointIdx].item != null) {
      List<TrackItem> trackItemList = await DBProvider.db.getTrackItem(track.items, 'id', trackCoords[trackPointIdx].item );
      trackItemList.length > 0 ? _trackItem = trackItemList.first : _trackItem = TrackItem();
    } else {
      _trackItem = TrackItem();
    }
    return _trackItem;
  }


  /// Find TrackItem with id in trackItems
  TrackItem getTrackItemWithId(int index) {
    return trackItems.firstWhere((ti) => ti.id ==index);
  }
   
  /// ItemDialog
  ///
  /// Clousure to get values from ItemDialog
  onReflectItemDialog( Map item ) {
    print(item);
    print(item['name']);
    print(item['info']);
    _trackItem.name = item['name'];
    _trackItem.info = item['info'];
  }

  onImagesInItemDialog( List images ) {
    for (int i = 0; i < images.length; i++) {
      print(images[i]);
    }
    _trackItem.images = images;
  }

  /// Dialog to add or edit TrackItem
//  itemDialog(context, int trackpointIdx, String latlng) async {
//    if ( trackPoints[trackpointIdx].item != null) {
//     List<TrackItem> trackItemList = await DBProvider.db.getTrackItem(track.items, 'id', trackPoints[trackpointIdx].item );
//     trackItemList.length > 0 ? _trackItem = trackItemList.first : _trackItem = TrackItem();
//    } else {
//      _trackItem = TrackItem();
//    }
//
//    switch ( await showDialog(
//      context: context,
//      builder: (context) {
//        return ItemDialog(context, trackpointIdx, onReflectItemDialog, onImagesInItemDialog, _trackItem);
//      }
//    )) {
//      case "SAVE" :
//        print('ItemDialog SAVE TrackItem');
//        if (_trackItem.id == null) {
//          saveItem(_trackItem, trackPoints[trackpointIdx].id);
//        } else {
//          updateItem(_trackItem, trackpointIdx);
//        }
//        break;
//      case "CANCEL":
//        break;
//      case "REMOVE" :
//        deleteItem(_trackItem, trackpointIdx);
//        break;
//    }
//  }

  Future saveItem(TrackItem trackItem, int trackPointIdx) async {
    trackItem.markerId = trackCoords[trackPointIdx].id;
    var result = await DBProvider.db.addTrackItem(trackItem, track.items);
    if (result > 0) {
      var r = await DBProvider.db.updateTrackCoord(trackCoords[trackPointIdx].id, track.track, "item", result);
      trackCoords[trackPointIdx].item = result;
      //print (r);
      //getTrackItems();
    }

  }

  Future updateItem(TrackItem trackItem, int trackPointIdx) async {
    var result = await DBProvider.db.updateTrackItem(trackItem, track.items);
    if (result == 0) {
      print("Error trackItem update");
    } else {
      print("Update trackItem successful");
    }
  }

  /// First delete [TrackItem], then delete TrackItem.id in [TrackCoord.item]
  Future deleteItem(TrackItem trackItem, int trackPointIdx) async {
    var result = await DBProvider.db.deleteTrackItem(trackItem.id, track.items);
    if (result == true) {
      await DBProvider.db.updateTrackCoord(trackCoords[trackPointIdx].id, track.track, 'item', null);
      trackCoords[trackPointIdx].item = null;
    }
  }

  getTrackItems() async {
    var result = await DBProvider.db.getTrackItems(track.items);
    if (result.length > 0) {
      trackItems = result;
    }
  }
  
  /// Here we save the current state of tracking. Ask if track to be saved.
  /// Then save track as gpx file and save items to table
  saveTrackingState() {
    
  }
  
}


/// Service class for adding point to path
/// Add point between to points on path
class AddPointToPath {

  List<int> pathMarker = [];


  /// add max 2 marker index's to pathMarker list
  /// If index already in list, remove
  int addPathMarker(int markerIdx, context) {

    Map <String, String> feedback = {
      "toManyPoints": "Select only 2 directly connected points",
      "pointsNotConnected" : "Points have to be directly conneted."
    };

    bool validate() {

      if (pathMarker.indexOf(markerIdx) >= 0 ) {
        pathMarker.removeAt(pathMarker.indexOf(markerIdx));
        return false;
      }

      if (pathMarker.length == 1 ) {
        if (markerIdx == pathMarker[0] - 1 || markerIdx == pathMarker[0] + 1 ) {
          // ok
          pathMarker.add(markerIdx);
        } else {
          String msg = "Points have to be directly conneted.";
          bottomSheet(context, msg);
        }
      }

      if ( pathMarker.length > 2 ) {
        print("Only 2 points allowed");
        bottomSheet(context, feedback['toManyPoints']);
        // if new point + or - of first point then replace pathMarker[1]
      }
      return true;
    }

    pathMarker.length == 0 ? pathMarker.add(markerIdx) : validate();

    return pathMarker.length;
  }


  int removePathMarker(int markerIdx) {
    if (pathMarker.indexOf(markerIdx) >= 0 ) {
      pathMarker.removeAt(pathMarker.indexOf(markerIdx));
    }

    return pathMarker.length;
  }


  int getLastPathMarker() {
    return  max(pathMarker[0], pathMarker[1]);
  }


  bottomSheet(context, msg) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.error, color: Colors.redAccent,),
                title: Text(msg),
              ),
            ],
          );
        });
  }
}


/// Stream messages
 class TrackPageStreamMsg {
  String type;
  var msg;

  TrackPageStreamMsg(this.type, this.msg);
}