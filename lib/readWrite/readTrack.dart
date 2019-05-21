import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import '../database/models/track.dart';
import '../database/models/trackCoord.dart';
import '../database/models/trackItem.dart';

/// Get directory with tour data
/// Check contents
class TrackDirectory {
  String trackPath;
  String _directoryPath;

  Future<bool> getDirectory() async {
    //checkServicesStatus(PermissionGroup.storage);
    await requestPermissionStatus(PermissionGroup.storage);
    try {
      String pathToTrack = await FilePicker.getFilePath(type: FileType.ANY);
      if (pathToTrack != "") {
        return await checkDirectory(pathToTrack);
      }
    } on Platform catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  Future<bool> checkDirectory(String directoryPath) async {
    // tour.txt
    //checkServicesStatus(PermissionGroup.storage);

    var dirName = path.dirname(directoryPath);
    print("dirname $dirName");
    var filePath = '$dirName/track.txt';
    File track = File(filePath);
    if ( track.existsSync() == true ) {
      print("checkDirectory track file ok");
      _directoryPath = path.dirname(directoryPath);
      trackPath = filePath;
      return true;
    } else {
      print("checkDirectory tour file false");
    }
    return false;
  }

  checkServicesStatus(PermissionGroup permission ) {
    print("checkServiceStatus");
    PermissionHandler()
        .checkServiceStatus(permission)
        .then((ServiceStatus serviceStatus) {
      print("ServiceStatus: ${serviceStatus.toString()}");
    });
  }

  requestPermissionStatus(PermissionGroup permission ) async {
    PermissionStatus status = await PermissionHandler().checkPermissionStatus(permission);
    print(status.toString());
  }

  Future<Track> readTour() async {
    String contents = await File(trackPath).readAsString();
    print("tour.txt content: $contents");
    Track track = trackFromJson(contents);
    return track;
  }


  Future <List<TrackCoord>> readTourCoords() async {
    List<TrackCoord> trackCoords = [];
    var filePath = '$_directoryPath/coords.txt';
    File coordsFile = File(filePath);
    if (coordsFile.existsSync() == true ) {
      print("Track track file exists");
      List contents = await coordsFile.readAsLinesSync();
      for (var line in contents) {
        TrackCoord trackCoord = trackCoordFromJson(line);
        trackCoords.add(trackCoord);
      }
    }
    return trackCoords;
  }


  Future <List<TrackItem>> readTourItems() async {
    List<TrackItem> trackItems = [];
    var filePath = '$_directoryPath/item.txt';
    File itemFile = File(filePath);
    if (itemFile.existsSync() == true ) {
      print("Tour item file exists");
      List contents = await itemFile.readAsLinesSync();
      for (var line in contents) {
        TrackItem trackItem = trackItemFromJson(line);
        trackItems.add(trackItem);
      }
    }
    return trackItems;
  }
}