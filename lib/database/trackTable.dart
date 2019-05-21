import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'models/track.dart';
//import 'models/tourCoord.dart';
import 'models/trackItem.dart';
import 'trackItemTable.dart';
import 'trackCoordTable.dart';

class TrackTable {
  TrackTable();

  createTrackTable(Database db) async {
    print("createTourTable");

    try {
      var res = db.transaction((txn) async {
        await txn.execute("CREATE TABLE TRACK ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "description TEXT,"
            "timestamp TEXT,"
            "open BIT,"
            "location TEXT,"
            "tourImage TEXT,"
            "options TEXT,"
            "coords TEXT,"
            "track TEXT,"
            "items TEXT,"
            "createdAt TEXT )");
      });
      print("collection TRACK create ok: $res");
      return res;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
      return false;
    }
  }


  /// Tour names have to be unique
  Future newTrack(Database db, Track newTour) async {
    print("db newTrack");
    // get biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM TRACK");
    int id = table.first["id"];
    // join all parts of tourname with '_'
    var modTourname = newTour.name.replaceAll(new RegExp(r' '), '_');
    // create trackTable for tour
    var createTableResult = await createTrackCoordsTable(db, modTourname);
    print("CreateTourTrackTable: " + createTableResult);
    newTour.track = createTableResult;

    var createTableItems = await createTrackItemTable(db, modTourname);
    print("CreateTourItemTable: " + createTableItems);
    newTour.items = createTableItems;

    // insert into the table using new id
    print("Start insert new Track");
    newTour.id = id;
    newTour.createdAt = DateTime.now().toIso8601String();
//    var tourString = newTour.toMap();
//    try {
//      var res = await db.insert("TRACK", newTour.toMap());
//      return res;
////      var res = db.transaction((txn) async {
////        await txn.execute(
////          "INSERT TRACK (" + tourString + ")"
////        );
////      });
//    } on DatabaseException catch (e) {
//      print("sqlite error: $e");
//      return null;
//    }
    var res = await db.insert("TRACK", newTour.toMap());
    print("Finished insert new Track");
    return res;
  }

  /// To change the track name, we need to create
  /// new track, coords and item table
  /// Clone tables then delete
  /// ToDo Check if tables exists
  Future cloneTrack(Database db, Track newTrack, String oldTrackName) async {
    print("db CloneTrack");
    /// first create new table and save
    int id = newTrack.id;
    // join all parts of tourname with '_'
    var modTourName = newTrack.name.replaceAll(RegExp(r' '), '_');
    String oldTrackNameMod = oldTrackName.replaceAll(RegExp(r' '), '_');
    // create track table for track
    var cloneTableResult = await cloneTrackCoordsTable(db, oldTrackNameMod, modTourName);
    newTrack.track = cloneTableResult;
    TrackCoordTable().deleteTrackCoordTable(db, oldTrackNameMod);

    // clone item table and delete old table
    var cloneItemTableResult = await cloneTrackItemTable(db, oldTrackNameMod, modTourName);
    newTrack.items = cloneItemTableResult;
    TrackItemTable().deleteTrackItemTable(db, oldTrackNameMod);

    // delete track and add new track
    deleteTour(db, newTrack.id);
    var res = await db.insert("TRACK", newTrack.toMap());
    return res;
  }


  /// Table for track coordinates
  createTrackCoordsTable(Database db, String tourName) async {
    return await TrackCoordTable().createTrackCoordTable(db, tourName);
  }

  /// Clone table for track coordinates
  cloneTrackCoordsTable(Database db, String tableToClone, String newTableName ) async {
    return await TrackCoordTable().cloneTrackCoordTable(db, tableToClone, newTableName);
  }

  /// Table for track items
  createTrackItemTable(Database db, String tourName) async {
    return await TrackItemTable().createTrackItemTable(db, tourName);
  }

  /// Clone table for track items
  cloneTrackItemTable(Database db, String tableToClone, String tableName ) async {
    return await TrackItemTable().cloneTrackItemTable(db, tableToClone, tableName);
  }


  updateTrack(Database db, Track track) async {
    print("updateTrack");
    try {
      var res = await db
          .update("TRACK", track.toMap(), where: "id = ?", whereArgs: [track.id]);
      return 1;
    } on DatabaseException catch (e) {
      print("sqlite error $e");
    }
    return 0;
  }

  addCoord(Database db, String coord) async {
    try {
      return 1;
    } on DatabaseException catch (e) {
      print("sqlite error $e");
    }
    return 0;
  }

  deleteTour(Database db, int id) async {
    print("deleteTrack with id $id");
    return db.delete("TRACK", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Track>> getAllTracks(Database db) async {
    print("getAllTracks");
    try {
      var res = await db.query("TRACK");
      List<Track> list =
      res.isNotEmpty ? res.map((c) => Track.fromMap(c)).toList() : [];

      print(list);
      return list;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
    }

    return [];
  }

  Future<int> isTableExisting(Database db, String tablename) async {
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name= ?",
        [tablename]);
    if (result.length > 0) {
      print("table $tablename exists");
      return result.length;
    } else {
      print("table $tablename does not exists");
      var tableCreated = await createTrackTable(db);
      if (tableCreated == true) {
        return 1;
      }
    }
    return null;
  }

  Future<int> trackExists(Database db, String query) async {
    try {
      List<Map> maps =
      await db.rawQuery("SELECT id FROM TRACK WHERE name = ? ", [query]);
      if (maps.length > 0) {
        return maps.length;
      }
    } on DatabaseException catch (e) {
      print("Sqlite error: $e");
    }
    return null;
  }

}