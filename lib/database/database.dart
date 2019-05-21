import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models/track.dart';
import 'trackTable.dart';
import 'models/trackCoord.dart';
import 'trackCoordTable.dart';
import 'models/trackItem.dart';
import 'trackItemTable.dart';

class DBProvider {
  final dataBaseName = "TracksDB.db";

  TrackTable _trackTable;
  TrackCoordTable _trackCoordTable;
  TrackItemTable _trackItemTable;

  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    _trackTable = TrackTable();
    _trackCoordTable = TrackCoordTable();
    _trackItemTable = TrackItemTable();

    _database = await _initDB(dataBaseName);

    return _database;
  }

  _initDB(dbName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(path, version: 1, onOpen: (db) {},
      onCreate: (Database db, int version) async {
        var tourTableState = _trackTable.createTrackTable(db);
        print('_initDb.createTrackTable: $tourTableState');
      }
    );
  }

  /// Delete
  deleteTable(String tableName) async {
    final db = await database;
    var result = await db.rawQuery("DROP TABLE IF EXISTS " + tableName);
    //var result = await db.delete(tableName);
    print("deleteTable $tableName with result $result");
  }

  /// TrackTable queries
  newTrack(Track newTour) async {
    final db = await database;
    return _trackTable.newTrack(db, newTour);
  }

  updateTrack(Track tour) async {
    final db = await database;
    return _trackTable.updateTrack(db, tour);
  }

  deleteTrack(int id) async {
    final db = await database;
    return _trackTable.deleteTour(db, id);
  }

  cloneTrack(Track newTrack, String oldTrackName) async {
    final db = await database;
    return _trackTable.cloneTrack(db, newTrack, oldTrackName);
  }

  Future<List<Track>> getAllTracks() async {
    final db = await database;
    return _trackTable.getAllTracks(db);
  }

  isTableExisting(String tablename) async {
    final db = await database;
    return _trackTable.isTableExisting(db, tablename);
  }

  trackExists(String trackname) async {
    final db = await database;
    return _trackTable.trackExists(db, trackname);
  }

  /// TrackCoordTable queries
  addTrackCoord(TrackCoord newTrackCoord, trackCoordTable) async {
    final db = await database;
    return _trackCoordTable.addTrackCoords(db, newTrackCoord, trackCoordTable);
  }

  insertTrackCoords(TrackCoord trackCoord, trackCoordTable, index) async {
    final db = await database;
    return _trackCoordTable.insertTrackCoords(db, trackCoord, trackCoordTable, index);
  }

  Future<List<TrackCoord>> getTrackCoords(String trackCoordTable) async {
    final db = await database;
    return _trackCoordTable.getTrackCoords(db, trackCoordTable);
  }

  deleteTrackCoord(int id, String trackCoordTable) async {
    final db = await database;
    return _trackCoordTable.deleteTrackCoord(db, trackCoordTable, id);
  }

  updateTrackCoord(int id, String trackCoordTable, String prop, dynamic val ) async {
    final db = await database;
    return _trackCoordTable.updateTrackCoord(db, trackCoordTable, id, prop, val);
  }


  /// TrackItem

  addTrackItem(TrackItem newTrackItem, trackItemTable) async {
    final db = await database;
    return _trackItemTable.addTrackItem(db, newTrackItem, trackItemTable);
  }

  Future<List<TrackItem>> getTrackItems(String trackItemTable) async {
    final db = await database;
    return _trackItemTable.getTrackItems(db, trackItemTable);
  }

  Future<List<TrackItem>> getTrackItem( String tableName,  String prop,  dynamic value) async {
    final db = await database;
    return _trackItemTable.getTrackItem(db, tableName, prop, value);
  }

  updateTrackItem(TrackItem trackItem, trackItemTable) async {
    final db = await database;
    return _trackItemTable.updateTrackItem(db, trackItemTable, trackItem);
  }

  deleteTrackItem(int id, String trackItemTable) async {
    final db = await database;
    return _trackItemTable.deleteTrackItem(db, trackItemTable, id);
  }
}