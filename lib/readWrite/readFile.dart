/// read file from local storage
///

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

class ReadFile {

  String contents;
  String filePath;

  Future<String> getPath() {
    //var result =  _getPath();
    return _getPath();
  }

  Future<String> _getPath() async {
    try {
      String fPath = await FilePicker.getFilePath(type: FileType.ANY);
      if ( filePath == '') {
        return null;
      }
      print('fPath: ' + fPath);
      return fPath;
    } on Platform catch (e) {
      print("FilePicker Error: $e");
    }

    return null;
  }


  Future<String> readFile(String fp) async {
    try {
      String fileContents = await File(fp).readAsString();
      return fileContents;
    } catch (e) {
      print('File Error: $e');
    }
    return null;
  }


  Future<List> getFilePath() async {
    try {
      filePath = await FilePicker.getFilePath(type: FileType.ANY);
      if ( filePath == '') {
        return null;
      }
      // check file type. use extension
      String fileType = p.extension(filePath);
      if (fileType != '.gpx') {
        print('Wrong file type');
        return null;
      }

      Future <bool> fileLoaded = loadFile( filePath );
      return [filePath, contents];

    } on Platform catch (e) {
      print("FilePicker Error: $e");
    }

    return null;
  }


  Future<bool> loadFile(String filePath) async {
    try {
      contents = await File(filePath).readAsString();
      print(contents);
      return true;
    } catch (e) {
      return null;
    }
  }
}
