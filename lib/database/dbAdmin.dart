import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'package:flutter/material.dart';


class DBAdmin extends StatelessWidget {
  static Database _database;

  DBAdmin() {
    getDatabase();
  }

  String dbName;

  getDatabase() async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.0,
    );
  }
}