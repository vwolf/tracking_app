import 'dart:async';

import 'package:flutter/material.dart';

import '../database/models/track.dart';
import '../map/trackingMap.dart';
import 'trackService.dart';
import '../services/cameraService.dart';

import 'trackInspect.dart';
import '../services/cameraPage.dart';

/// Start tracking current position
/// Permission geo location
/// Create a track and add position to track
/// Leaving page: ask if track to save?
class TrackingPage extends StatefulWidget {

  TrackingPage();

  @override
  _TrackingPageState createState() => _TrackingPageState();
}



class _TrackingPageState extends State<TrackingPage> {
  GlobalKey _trackingMapKey = GlobalKey();

  /// communication with map via streams
  StreamController<TrackPageStreamMsg> _streamController = StreamController.broadcast();

  /// TrackService with empty track, then save track with default values
  TrackService trackService = TrackService(Track());

  TrackingMap get _trackingMap => TrackingMap(trackService, _streamController);
  //TrackingMap _trackingMap;

  bool emptyTrackReady = false;

  /// persistent bottom sheet
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _persistentBottomSheetController;

  @override
  void initState() {
    super.initState();

    initStreamController();

    //trackService.saveEmptyTrack();
    initEmptyTrack();
  }



  /// First save an empty track to db, then show map
  Future initEmptyTrack() async {
    try {
      var res = await trackService.saveEmptyTrack();
      if (res == true) {
        print("initEmptyTrack OK");
        /// add start position to DB
        //trackService.addTrackCoord(trackService.trackPoints.first, trackService.track.track);
        trackService.addTrackCoord(trackService.trackCoords.first, tableName: trackService.track.track);
        /// Set location description for start position

        setState(() {
          emptyTrackReady = true;
        });
      }
    } catch (e) {
      print("initEmptyTrack Error $e");
    }
  }


  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  /// Initialize _streamController subscription to listen for TrackPageStreamMsg
  initStreamController() {
    _streamController.stream.listen((TrackPageStreamMsg trackingPageStreamMsg) {
      onMapEvent(trackingPageStreamMsg);
    }, onDone: () {
      print('TrackingPageStreamMsg Done');
    }, onError: (error) {
      print('TrackingPage StreamContorller error $error');
    });
  }

  onMapEvent(TrackPageStreamMsg trackingPageStreamMsg) {
    print("TrackingPage.onMapEvent ${trackingPageStreamMsg.type}");
    switch (trackingPageStreamMsg.type) {
      case "trackingMapStatusAction" :
        if ( trackingPageStreamMsg.msg == "camera") {
          // openPersistentBottomSheet("camera");
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return CameraPage();
              })
          );
        };
    };

  }


  void trackInspectEvent(int event) {
    print('trackInspectEvent $event');
  }

  openPersistentBottomSheet(dataType) {
    if (_persistentBottomSheetController == null) {
      _persistentBottomSheetController = _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
        if (dataType == "camera") {
          return CameraService();
          //return TrackInspect(trackService, trackInspectEvent);
        }
      });
    } else {
      _persistentBottomSheetController.close();
      _persistentBottomSheetController = null;

    }
  }


  @override
  Widget build(BuildContext content) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Tracking'),
      ),
      body: Column(
        children: <Widget>[
          emptyTrackReady == true ? _trackingMap : Container(),
        ],
      ),
    );
  }
}

class TrackingMsg{
  String type;
  var msg;

  TrackingMsg(this.type, this.msg);
}