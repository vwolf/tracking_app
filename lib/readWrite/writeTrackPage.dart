import 'dart:io';

import 'package:flutter/material.dart';
import '../database/database.dart';
import '../database/models/track.dart';
import '../database/models/trackCoord.dart';
import '../database/models/trackItem.dart';

import '../readWrite/writeTrack.dart';
import '../gpx/gpxWriter.dart';

/// Save a tour to external storage
/// Tours are saved to directory TourData
class WriteTrackPage extends StatefulWidget {
  WriteTrackPage(this.track);

  final Track track;

  _TrackWriteToExternal createState() => _TrackWriteToExternal();
}


class _TrackWriteToExternal extends State<WriteTrackPage> {

  final _formkey = GlobalKey<FormState>();
  String _status = '';

  /// Save tour data
  Future saveTour() async {
    String directoryName = '/MyTracks/${widget.track.name}';
    String fileName = "track.txt";
    String track_json = trackToJson(widget.track);
    // print(track_json);
    String filePath = '$directoryName/$fileName';

    try {
      final directoryCreated = await WriteTourExternal().makeFolder('$directoryName');
      if (directoryCreated == true) {
        await WriteTourExternal().writeToFile(filePath, track_json);

        setState(() {
          _status = 'Track written';
        });
      }
    } catch (e) {
      print(e);
      /// Modal with error. After dismiss of modal return to main page
      await _writeError("Could not create folder", e).then((value) {
        Navigator.pop(context);
      });

    }

    /// Now save track coords to track file as json string
    /// Always create new track file
//    if (widget.tour.track != null) {
//      List<TourCoord> tourCoords =  await DBProvider.db.getTourCoords(widget.tour.track);
//
//      var openFile = await WriteTourExternal().openFile('$directoryName/track.txt');
//      var fileLength = await openFile.length();
//      print("openFile.length: $fileLength");
//
//      var sink = openFile.openWrite();
//      //var sink = openFile.openWrite(mode: FileMode.append);
//
//      for ( var coord in tourCoords ) {
//        print(tourCoordToJson(coord));
//
//        sink.write(tourCoordToJson(coord));
//        sink.write('\n');
//      }
//      sink.close();
//    }

    if (widget.track.track != null) {
      try {
        await DBProvider.db.getTrackCoords(widget.track.track)
            .then((List<TrackCoord> trackCoords) {
          WriteTourExternal().openFile('$directoryName/track.gpx')
              .then((openFile) {
            var sink = openFile.openWrite();
            GpxWriter gpxWriter = GpxWriter();
            String xml = gpxWriter.buildGpx(trackCoords);
            sink.write(xml);
            sink.close();

            setState(() {
              _status = '$_status \n Coords to gpx wirten';
            });
          });
        });
      } catch (e) {
        await _writeError("Error writing gpx file", e).then((val) {
          Navigator.pop(context);
        });
      }
    }


    /// Save track as *.gpx file im xml format
//    if (widget.track.track != null) {
//      List<TrackCoord> tourCoords = await DBProvider.db.getTrackCoords(widget.track.track);
//      var openFile = await WriteTourExternal().openFile('$directoryName/track.gpx');
//      var sink = openFile.openWrite();
//
//      GpxWriter gpxWriter = GpxWriter();
//      var xml = gpxWriter.buildGpx(tourCoords);
//
//      sink.write(xml);
//      sink.close();
//
//      setState(() {
//        _status = '$_status \n Coords to gpx wirten';
//      });
//
//    }


    /// Save tour items to items file
    if (widget.track.items != null) {
      List<TrackItem> trackItems = await DBProvider.db.getTrackItems(widget.track.items);
      if (trackItems.length > 0) {

      }
    }

    sleep(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  /// Alert dialog
  ///
  /// [e] Exception
  Future<void> _writeError(String msg, Exception e) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$msg'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('$e'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Text("Save Tour"),
        ),
        body: ListView(
          children: <Widget>[
            _info,
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
              child: Container(
                height: 2.0,
                color: Colors.blueGrey,
              ),
            ),

            _form,
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 24.0),
              child: Text('Status: $_status'),
            )
          ],
        )
    );
  }

  Widget get _form {
    return Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text('SAVE'),
                    onPressed: saveTour,
                  ),
                  RaisedButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            )
          ],
        )
    );
  }


  Widget get _info {
    return Container(
      margin: EdgeInsets.only(left: 24.0, top: 32.0),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Save Track',
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.left,
          ),

          Text('  ${widget.track.name} (${widget.track.location})',
            style: Theme.of(context).textTheme.title,

          ),
          Text("to external Storage on this device \n(directory MyTracks -> track name).",
            style: Theme.of(context).textTheme.title,
          )
        ],

      ),
    );
  }

}