import 'package:sqflite/sqflite.dart';
import 'models/trackItem.dart';

class TrackItemTable {
  TrackItemTable();

  createTrackItemTable(Database db, String tourName) async {
    print("createTrackItemTable");
    String trackItemTableName = "TrackItem_" + tourName;
    try {
      var res = db.transaction((txn) async {
        await txn.execute("CREATE TABLE " +
            trackItemTableName +
            "(id INTEGER PRIMARY KEY,"
                "name TEXT,"
                "info TEXT,"
                "timestamp TEXT,"
                "latlng TEXT,"
                "images TEXT,"
                "createdAt TEXT,"
                "markerId INTEGER"
                ")"
        );
      });
      return trackItemTableName;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
      return false;
    }
  }


  cloneTrackItemTable(Database db, String tableToClone, String tableName) async {
    String tableToCloneName = "TrackItem_" + tableToClone;
    String newTableName = "TrackItem_" + tableName;
    try {
      var res = db.transaction((txn) async {
        await txn.execute("CREATE TABLE " + newTableName + " AS SELECT * FROM " + tableToCloneName);
      });
      return newTableName;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
      return false;
    }
  }


  deleteTrackItemTable(Database db, String tableName) async {
    String tableToDelete = "TrackItem_" + tableName;
    try {
      var res = db.transaction((txn) async {
        await txn.execute(("DROP TABLE " + tableToDelete));
      });
      return res;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
      return false;
    }
  }


  addTrackItem(Database db, TrackItem newTrackItem, String trackItemTable) async {
    print("db newTrackItem");
    var table =
    await db.rawQuery("SELECT MAX(id)+1 as id FROM " + trackItemTable);
    newTrackItem.id = table.first["id"];
    newTrackItem.timestamp = DateTime.now();
    newTrackItem.createdAt = DateTime.now().toIso8601String();
    // insert
    var res = await db.insert(trackItemTable, newTrackItem.toMap());
    return res;
  }


  updateTrackItem(Database db, String tableName, TrackItem trackItem) async {
    print("updateTrackItem");
    try {
      var res = await db
          .update("$tableName", trackItem.toMap(), where: "id = ?", whereArgs: [trackItem.id]);
      return 1;
    } on DatabaseException catch (e) {
      print("sqlite error $e");
    }
    return 0;
  }

  updateTrackItemProperty(Database db, String trackItemTable, String prop, dynamic val) {}


  Future<List<TrackItem>> getTrackItems(
      Database db, String trackCoordTable) async {
    print("getTrackCoords");
    try {
      var res = await db.query(trackCoordTable);
      List<TrackItem> list =
      res.isNotEmpty ? res.map((c) => TrackItem.fromMap(c)).toList() : [];

      return list;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
    }

    return [];
  }


  Future<List<TrackItem>> getTrackItem(Database db, String tableName, String prop, dynamic value ) async {
    print("getTourItem with $prop = $value");
    // String query = "SELECT * FROM $tableName WHERE $prop = $value";
    try {
      //var result = await db.query(query);
      var result = await db.query('$tableName', where: '$prop = ?', whereArgs: [value]);
      List<TrackItem> tourItem = result.isNotEmpty ? result.map((c) => TrackItem.fromMap(c)).toList() : [];
      return tourItem;
    } on DatabaseException catch (e) {
      print("DatabaseException $e");
    }
    return [];
  }

  /// Delete TrackItem at index id.
  /// Delete item reference from marker
  deleteTrackItem(Database db, String trackItemTable, int id) async {
    try {
      var res =
      await db.delete(trackItemTable, where: "id = ?", whereArgs: [id]);
      print("deleteTrackItem res: $res");
      return true;
    } on DatabaseException catch (e) {
      print("sqlite error: $e");
      return false;
    }
  }
}