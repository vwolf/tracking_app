import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/models/track.dart';
import 'trackService.dart';
import 'trackInspect.dart';
import 'trackItemInspect.dart';
import '../map/trackMap.dart';
import 'trackItemCard.dart';

/// Display a track map
class TrackDetailPage extends StatefulWidget {
  final Track track;
  TrackDetailPage(this.track);

  @override
  _TrackDetailPageState createState() => _TrackDetailPageState();
}


class _TrackDetailPageState extends State<TrackDetailPage> {

  GlobalKey _trackMapKey = GlobalKey();

  /// communication with map via streams
  StreamController<TrackPageStreamMsg> _streamController = StreamController.broadcast();

  /// Get a map instance and the service for map (TourServices)
  TrackMap get _trackMap => TrackMap(_streamController, _trackMapKey);
  TrackService trackService;

  /// map display values
  bool _mapFullScreen = true;
  bool _displayGpxFileTrack = false;
  bool _currentPosition = false;

  /// map event state
  bool _trackingEnabled = false;

  bool _showTrackPoints = false;

  /// action after tap on map _trackMap
  MapTapAction _mapTapAction = MapTapAction.NOACTION;

  /// for persistent bottom sheet
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _persistentBottomSheetController;


  @override
  void initState() {
    super.initState();

    initStreamController();
    trackService = TrackService(widget.track);

    /// If path to gpx file exist, read gpx file
    String tourGpxPath = widget.track.getOption("gpxFilePath");
    if (tourGpxPath != null) {
      getFileData(tourGpxPath);
    }

    getDatabaseData();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  /// Initialize _streamController subscription to listen for TrackPageStreamMsg and
  /// handle in onMapEvent()
  initStreamController() {
    _streamController.stream.listen((TrackPageStreamMsg trackPageStreamMsg) {
      onMapEvent(trackPageStreamMsg);
    }, onDone: () {
      print("Done trackPageStreamMsg");
    }, onError: (error) {
      print("StreamController error $error");
    });
  }

  /// Handle tap event on map, depending on options.
  /// StreamMsg from [TrackMap] [MapStatusLayer].
  /// TrackPageStreamMsg comes from trackMap
  onMapEvent(TrackPageStreamMsg trackPageStreamMsg) {
    print("TrackDetailPage.onMapEvent: $trackPageStreamMsg");
    switch (trackPageStreamMsg.type) {
      case "tapOnMap" :
        switch (_mapTapAction) {
          case MapTapAction.ADD_MARKER:
            trackService.addTrackPoint(trackPageStreamMsg.msg);
            setState(() {});
            break;
          case MapTapAction.ADD_ITEM:
            break;
          case MapTapAction.SELECT_MARKER:
            break;
          case MapTapAction.ADD_PATHMARKER:
            break;
          case MapTapAction.MOVE_MARKER:
            break;
          case MapTapAction.NOACTION:
            break;

        }
        break;

      case "mapStatusAction":
        print("mapStatusAction action: ${trackPageStreamMsg.msg}");
        openPersistentBottomSheet(trackPageStreamMsg.msg);
        break;

      case "showItem" :
        openPersistentBottomSheet(trackPageStreamMsg.type, trackPageStreamMsg.msg);
        break;

      case "hideItem" :
        openPersistentBottomSheet(trackPageStreamMsg.type, trackPageStreamMsg.msg);
        break;

      case "trackingOnOff" :
        break;

      case "toggleTrackPoints" :
        break;
        //trackpointIdx
    }
  }


  /// Send TrackPageStreamMsg with changed action
  setMapTapAction(MapTapAction action) {
    if (_mapTapAction == MapTapAction.NOACTION || _mapTapAction != action) {
      switch (action) {
        case MapTapAction.ADD_MARKER:
          break;
        case MapTapAction.ADD_ITEM:
          break;
        case MapTapAction.MOVE_MARKER:
          break;
        case MapTapAction.SELECT_MARKER:
          break;
        case MapTapAction.ADD_PATHMARKER:
          break;
        case MapTapAction.NOACTION:
          break;
      }

      _mapTapAction = action;
      _streamController
          .add(new TrackPageStreamMsg('mapTapAction', _mapTapAction));

//      if(_persistentBottomSheetController != null) {
//        _persistentBottomSheetController.close();
//        _persistentBottomSheetController = null;
//      }
    } else {
      _mapTapAction = MapTapAction.NOACTION;
      _streamController
          .add(new TrackPageStreamMsg('mapTapAction', _mapTapAction));
    }
    setState(() {});
  }


  toggleTracking() {
    _trackingEnabled = !_trackingEnabled;
    setState(() {});
    _streamController.add(new TrackPageStreamMsg("toggleTracker", _trackingEnabled));
  }


  /// load data from gpx file
  getFileData(filePath) async {
    var result = await trackService.getTrack(filePath);
    _streamController.add(new TrackPageStreamMsg("gpxFileData", true));
    _displayGpxFileTrack = true;
    setState(() {
      gpxFilePathDisplay;
    });
  }

  /// get tour data from database
  Future getDatabaseData() async {
    var result = await trackService.getDatabaseData();
    print("getData $result");
    _streamController.add(new TrackPageStreamMsg("newDefaultCoord", true));
  }


   //void trackInspectEvent(int event) => print('trackInspectEvent $event');

   void trackInspectEvent(int event) {
     print('trackInspectEvent $event');

     setState(() {
       trackService.markerInspectIdx = event;
       //trackService.setTrackMarkerInspect(event);
       _streamController.add(TrackPageStreamMsg('moveTo', trackService.trackLatlngPoints[event]));
     });
   }

   openPersistentBottomSheet(dataType, [index]) {
    if (_persistentBottomSheetController == null) {
      _persistentBottomSheetController =
          _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
        if (dataType == 'trackPoints') {
          return TrackInspect(trackService, trackInspectEvent);
        }

        if (dataType == 'trackItems') {
          return TrackItemInspect(trackService, trackInspectEvent);
        }

        if (dataType == 'showItem') {
          int itemIndex = trackService.trackCoords[index].item;
          var aItem = trackService.getTrackItemWithId(itemIndex);
          return TrackItemCard(aItem, _trackMapKey, trackService);
        }
      });

    } else {
      _persistentBottomSheetController.close();
      _persistentBottomSheetController = null;
      setState(() {
        trackService.markerInspectIdx = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrackInherited(
      trackService: trackService,
      child: Scaffold(
        key: _scaffoldKey,
        //backgroundColor: Colors.black87,
        appBar: AppBar(
          //backgroundColor: Colors.black87,
          title: Text('Track ${widget.track.name}'),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                child: const Center(
                  child: const Text('Track Settings'),
                ),
              ),
              ListTile(
                title: const Text("Set Start position to current location?"),
              ),
              ListTile(
                  title: Text("Add marker at tap"),
                  trailing: Icon(_mapTapAction == MapTapAction.ADD_MARKER
                      ? Icons.check
                      : Icons.not_interested),
                  onTap: () {
                    setMapTapAction(MapTapAction.ADD_MARKER);
                    Navigator.pop(context);
                  }),
              ListTile(
                title: Text('Add item at tap'),
                  trailing: Icon(_mapTapAction == MapTapAction.ADD_ITEM
                      ? Icons.check
                      : Icons.not_interested),
                  onTap: () {
                    setMapTapAction(MapTapAction.ADD_ITEM);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("Add marker to path"),
                  trailing: Icon( _mapTapAction == MapTapAction.SELECT_MARKER ? Icons.check : Icons.not_interested),
                  onTap: () {
                    setMapTapAction(MapTapAction.SELECT_MARKER);
                    Navigator.pop(context);
                  }
              ),
              ListTile(
                title: Text("Move marker to tap"),
                trailing: Icon(_mapTapAction == MapTapAction.MOVE_MARKER ? Icons.check : Icons.not_interested),
                onTap: () {
                  setMapTapAction(MapTapAction.MOVE_MARKER);
                  Navigator.pop(context);
                }
              ),
              gpxFilePathDisplay,
              ListTile(
                title: Text("Show current Position"),
                trailing: Icon(_currentPosition == true ? Icons.check : Icons.not_interested),
                onTap: () {},
              ),
              ListTile(
                  title: Text("Tracking enabled"),
                  trailing: Icon(_trackingEnabled == true ? Icons.check : Icons.not_interested),
                  onTap: () {
                    toggleTracking();
                  }
              ),
//              ListTile(
//                  title: Text("BottomSheet"),
//                  trailing: Icon(_trackingEnabled == true ? Icons.check : Icons.not_interested),
//                  onTap: () {
//                    openPersistentBottomSheet();
//                  }
//              ),
            ],
          ),
        ),
//        persistentFooterButtons: <Widget>[
//          IconButton(icon: Icon(Icons.assistant, color: Colors.red,), onPressed: () => openPersistentBottomSheet("trackPoints")),
//          IconButton(icon: Icon(Icons.info, color: Colors.red,), onPressed: () => openPersistentBottomSheet("trackItems")),
//        ],

        body: Column(
          children: <Widget>[
            _trackMap,
          ],
        ),

      ),
    );
  }

//  String _value = '';
//  void _onClick(String value) => openPersistentBottomSheet() ;

  /// Page widget's
  Widget get gpxFilePathDisplay {
    if (trackService.gpxFileData.gpxLatlng.length > 0) {
      return ListTile(
          title: Text("Show gpx file track"),
          trailing: Icon(_displayGpxFileTrack == true
              ? Icons.check
              : Icons.not_interested),
          onTap: () {
            _displayGpxFileTrack = !_displayGpxFileTrack;
            _streamController.add(new TrackPageStreamMsg(
                'displayGpxTileTrack', _displayGpxFileTrack));
            setState(() {});
          });
    } else {
      return Container();
    }
  }
}

/// To obtain the nearest instance of a particular type of inherited widget from a build context
class TrackInherited extends InheritedWidget {
  TrackInherited({
    Key key,
    @required this.trackService,
    @required Widget child,
  })  : assert(trackService != null),
        assert(child != null),
        super(key: key, child: child);

  final TrackService trackService;

  static TrackInherited of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(TrackInherited)
        as TrackInherited;
  }

  @override
  bool updateShouldNotify(TrackInherited old) {
    return trackService != trackService;
  }
}



