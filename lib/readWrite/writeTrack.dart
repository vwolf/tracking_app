import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

/// Write track coordinates as *gpx file
///
class WriteTrack {

  /// Documents directory (Android: AppData, iOS: NSDocumentDirectory)
  /// Only the app can access the files
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tour.json');
  }


  Future<File> writeTour(int tour) async {
    final file = await _localFile;

    return file.writeAsString('$tour');
  }


  Future<int> readTour() async {
    try {
      final file = await _localFile;

      // read
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }
}


/// Write data to external storage
class WriteTourExternal {

  bool externalStoragePermission = false;

  final PermissionGroup _permissionGroup = PermissionGroup.storage;

  Future get _externalDirectory async {
    final externalDirectory = await getExternalStorageDirectory();
    return externalDirectory.path;
  }

  /// Create new directory if not already exists
  Future makeFolder(String folderName) async {
    Directory externalDir = await getExternalStorageDirectory();

    if ( !externalStoragePermission) {
      var result = await requestWritePermissions(_permissionGroup);
      if ( !externalStoragePermission) {
        print("no permission to use external storage");
        //return false;
      } else {
        Directory dir = Directory(externalDir.path + folderName);
        if ( await dir.exists() == false ) {
          print("Creating dir $externalDir + $folderName");
          dir.createSync(recursive: true);
          return true;
        } else {
          print("directory $externalDir + $folderName exists");
          return true;
        }
      }
    }
    return false;
  }


  /// Write string to file
  /// Create file at path if file does not exist
  Future writeToFile(String filePath, String text) async {
    final path = await _externalDirectory;
    File file = File('$path/$filePath');

    File result = await file.writeAsString('$text');
    print("writeToFile $result");
    return result;
  }


  /// Return file,
  Future<File> openFile(String filePath) async {
    final path = await _externalDirectory;
    try {
      File file = File('$path/$filePath');
      return file;
    } on FileSystemException {
      return null;
    }
  }


  Future writeStreamToFile(String filePath, List data) async {
    final path = await _externalDirectory;
    File file = File('$path/$filePath');

    IOSink sink = file.openWrite();
  }


  Future get _file async {
    final path = await _externalDirectory;
    return path;
  }


  Future requestWritePermissions(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    if (Platform.isAndroid) {
      final Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions(permissions);
      print(permissionRequestResult);
      externalStoragePermission = permissionRequestResult[PermissionGroup.storage] == PermissionStatus.granted;
      print(permissionRequestResult[PermissionGroup.storage]);
      print (externalStoragePermission);
//      await SimplePermissions.checkPermission(Permission.WriteExternalStorage)
//          .then((checkOkay) {
//        if (!checkOkay) {
//          SimplePermissions.requestPermission(Permission.WriteExternalStorage)
//              .then((PermissionStatus okDone) {
//                if (okDone == PermissionStatus.authorized ) {
//                  print("$okDone");
//                  externalStoragePermission = true;
//                  return true;
//                } else {
//                  return false;
//                };
//          });
//        } else {
//          externalStoragePermission = true;
//          return true;
//        }
//      });
    }
  }
}



class ReadFileExternal{

  Future get _externalDirectory async {
    final externalDirectory = await getExternalStorageDirectory();
    return externalDirectory.path;
  }


  Future<File> get _localFile async {
    final path =  await _externalDirectory;
    return File('$path/Tourdata/data.gpx');
  }


  Future<String>readFile(String filePath) async {
    try {
      final path = await _externalDirectory;
      final file = File(path + filePath);

      return await file.readAsString();
    } catch (e) {
      print (e);
      return null;
    }
  }
}