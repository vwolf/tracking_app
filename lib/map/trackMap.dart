/// Provide map view
///
/// Uses TrackGpxData object for
/// - map center (first point in trackPoints list
/// _trackGpxData is inherited from trackDetailPage
///
/// tracksource can be:
///

///
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../track/trackService.dart';
import '../track/trackDetailPage.dart';
import 'mapStatusLayer.dart';
import '../services/geoLocationService.dart';
import 'trackPointDialog.dart';
import 'itemDialog.dart';

//typedef void MarkerCallBack(int);

/// OSM Map with different layers.
///
/// [streamController] Streams between [TrackDetailPage] and [TrackMapState].
/// marker layer, path layer, status layer.
/// Communication with page via streams [TrackPageStreamMsg]
class TrackMap extends StatefulWidget {
  final StreamController<TrackPageStreamMsg> streamController;
  final GlobalKey trackMapKey;

  TrackMap(this.streamController, this.trackMapKey);

  @override
  TrackMapState createState() => TrackMapState(streamController);
}


class TrackMapState extends State<TrackMap> {

  StreamController<TrackPageStreamMsg> streamController;
  StreamController trackerStreamController;

  TrackMapState(this.streamController);

  /// MapController and plugin layers
  MapController mapController;
  //DragableMapLayer _dragableMapLayer = DragableMapLayer();
  MapStatusLayer _mapStatusLayer = MapStatusLayer();


  MapTapAction _mapTapAction = MapTapAction.NOACTION;

  /// Add a path point to path
  AddPointToPath _addPointToPath;
  List<int> _activeMarker = [];

  LatLng get startPos => TrackInherited.of(context).trackService.getStartCoord();
  TrackService get _trackService => TrackInherited.of(context).trackService;

  /// State variables
  bool _showItem = false;
  bool _tracking = false;
  bool _moveMarker = false;
  int _markerToMove;
  bool displayGpxFileTrack = true;
  bool _showCoordsAsPoints = false;
  bool _showPosition = false;
  List<int> _selectedMarker = [];

  int _markerInspect;

  @override
  void initState() {
    super.initState();
    mapController = new MapController();
    streamSetup();
  }

  @override
  void dispose() {
    streamController.close();
    if (trackerStreamController != null ) {
      trackerStreamController.close();
    }

    super.dispose();
  }


  streamSetup() {
    streamController.stream.listen((event) {
      onPageEvent(event);
    });
  }

  /// Event messages from page which embedded the map
  /// Also StreamMsg from map status layer
  ///
  /// event: [TrackPageStreamMsg]
  onPageEvent(TrackPageStreamMsg event) {
    print('trackMap onPageEvent $event');
    switch (event.type) {
      case "newDefaultCoord" :
        setState(() {
          startPos;
          mapController.move(startPos, mapController.zoom);
        });
        break;
      case "moveTo" :
        setState(() {
          mapController.move(event.msg, mapController.zoom);
        });
        break;
      case "gpxFileData" :
        setState(() {});
        break;
      case "toggleTracker" :
        toggleTracker(event.msg);
        break;
      case "showPosition" :
        showPosition(event.msg);
        _mapStatusLayer.trackingOnOff(event.msg);
        //_mapStatusLayer.statusNotificationDummy("dummy notification");
        setState(() {});
        break;

      case "showTrackCoords" :
        //_mapStatusLayer.showCoords = event.msg;
        break;

      case "mapTapAction" :
        switch (event.msg) {
          case MapTapAction.ADD_MARKER:
            if (_mapTapAction == MapTapAction.SELECT_MARKER || _mapTapAction == MapTapAction.ADD_PATHMARKER) {
              _addPointToPath = null;
              _activeMarker = [];
              setState(() {});
            }
            _mapTapAction = event.msg;
            _mapStatusLayer.statusNotification('Add Marker at click');
          break;

          case MapTapAction.SELECT_MARKER:
            _addPointToPath = AddPointToPath();
            _mapTapAction = event.msg;
            _mapStatusLayer.statusNotification('Select markers where to add new marker');
            break;

          case MapTapAction.ADD_ITEM:
            _mapTapAction = event.msg;
            _mapStatusLayer.statusNotification('Add item at tap');
            break;

          case MapTapAction.MOVE_MARKER :
            _mapTapAction = event.msg;
            _mapStatusLayer.statusNotificationDummy('Move marker to tap position');
            break;

          case MapTapAction.NOACTION :
            if (_mapTapAction == MapTapAction.SELECT_MARKER || _mapTapAction == MapTapAction.ADD_PATHMARKER) {
              _addPointToPath = null;
              _activeMarker = [];
            }
            _mapTapAction = event.msg;
            _mapStatusLayer.statusNotification("Select in menu");
            break;
        }
        break;

        // StreamMsg's from map status layer
      case "mapStatusAction" :
        switch (event.msg) {
          case "trackingOnOff" :
            showPosition(!_showPosition);
            _mapStatusLayer.trackingOnOff(_showPosition);
            setState(() {});
            break;

          case "showTrackCoords" :
            _showCoordsAsPoints = !_showCoordsAsPoints;
            _mapStatusLayer.showCoords = _showCoordsAsPoints;
            setState(() {});
            break;
        }
        break;

      case "displayGpxFileTrack" :
        displayGpxFileTrack = event.msg;
        setState(() {});
        break;

      default:
        print('TrackMap.onPageEvent: unkonw event type ${event.type}');
    }
  }

  /// Tap anywhere on map except marker and path
  /// Close bottom sheet if open
  _handleTap(LatLng latlng) {
    print('_handleTap at $latlng');
    if (_showItem == true) {
      _showItem = false;
      streamController.add(TrackPageStreamMsg("hideItem", 0));
    }


    switch (_mapTapAction) {
      case MapTapAction.NOACTION :
        break;

      case MapTapAction.ADD_MARKER :
        streamController.add(TrackPageStreamMsg("tapOnMap", latlng));
        break;

      case MapTapAction.ADD_PATHMARKER :
        int index = _addPointToPath.getLastPathMarker();
        _trackService.addTrackCoordAtIndex(latlng, index);
        streamController.add(TrackPageStreamMsg("tapOnMap", latlng));
        setState(() {});
        break;

      case MapTapAction.SELECT_MARKER :
        break;

      case MapTapAction.ADD_ITEM :
        break;

      case MapTapAction.MOVE_MARKER :
        if (_moveMarker == true && _activeMarker.length == 1) {
          _trackService.changeTrackCoord(_activeMarker[0], latlng);
          setState(() {});
        }
        break;
    }

  }

  _handleLongPress(LatLng latlng) {
    print("handleLongPress at $latlng");
  }


  /// Tap on marker on maps.
  /// Use coords to get in marker list (_tourGpxData.trackPoints).
  _handleTapOnMarker(LatLng latlng, int index) {
    print('Tap on marker at $latlng with index: $index');

    // _trackService.getTrackPointAtIndex(index);

    if (_mapTapAction == MapTapAction.SELECT_MARKER) {
      /// deselect marker if already in _activeMarker
      if (_activeMarker.indexOf(index) >= 0) {
        _addPointToPath.removePathMarker(index);
        _activeMarker.remove(index);
        setState(() {});
        return;
      }

      int markerCount = _addPointToPath.addPathMarker(index, context);
      /// always add first marker
      if (markerCount == 1 && _activeMarker.length < 1) {
        _activeMarker.add(index);
      }

      if (markerCount == 2 && _activeMarker.length < 2) {
        _activeMarker.add(index);
        _mapTapAction = MapTapAction.ADD_PATHMARKER;
      }
//      if (markerCount < 3 || markerCount > 1) {
//        _activeMarker.add(index);
//        if (markerCount == 2) {
//          _mapTapAction = MapTapAction.ADD_PATHMARKER;
//        }
//      }
      setState(() {});
      return;
    }


    if (_mapTapAction == MapTapAction.ADD_PATHMARKER) {
      int markerCount =_addPointToPath.removePathMarker(index);
      if (markerCount < 2) {
        _activeMarker.remove(index);
        _mapTapAction = MapTapAction.SELECT_MARKER;
      }
      setState(() {});
      return;
    }


    /// Marker Dialog
    _trackService.selectMarker(trackPointIdx: index);
    _markerDialog(index, latlng);
  }


  /// save marker for later actions (move or add marker to path)
  _handleLongPressOnMarker(BuildContext context, LatLng latlng, int index) {
    if (_mapTapAction == MapTapAction.ADD_PATHMARKER) {
      return;
    }

    _moveMarker = true;
    _activeMarker.length == 0 ? _activeMarker.add(index) : _activeMarker[0] = index;
    setState(() {});
  }

  /// Called when touching a track segment.
  _onTap(String msg, Polyline polyline, LatLng latlng, int polylinePoint) {
    print("$msg at $polyline at point $polylinePoint");
    // convert point to marker
    int markerIdx = (polylinePoint / 2).toInt();

    setState(() {
      _activeMarker = [markerIdx, markerIdx + 1];
    });

    // now add a point to track at position polylinePoint + 1
    _trackService.addTrackCoordAtIndex(latlng, markerIdx + 1);
  }

  moveMapToMarker(int trackPointIdx) {
    mapController.move(_trackService.trackLatlngPoints[trackPointIdx], mapController.zoom);
  }

  Color _getMarkeIconColor(int trackPointIdx) {
    if (_activeMarker.contains(trackPointIdx)) {
      return Colors.redAccent;
    }

    if (_trackService.markerInspectIdx == trackPointIdx) {
      return Colors.blueAccent;
    }

    if (_trackService.trackCoords[trackPointIdx].item != null) {
      return Colors.orangeAccent;
    }

    return Colors.green;
  }


  @override
  Widget build(BuildContext context) {
    final TrackInherited state = TrackInherited.of(context);
    return Flexible(
      child: FlutterMap(
          key: widget.trackMapKey,
          mapController: mapController,
          options: MapOptions(
            center: startPos,
            zoom: 15,
            minZoom: 4,
            maxZoom: 18,
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            plugins: [
              _mapStatusLayer,
            ],
          ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: _trackService.trackLatlngPoints,
                strokeWidth: 4.0,
                color: Colors.blueAccent,
              ),
            ],
              //onTap: _onTap("Tapped on"),
              onTap: (Polyline polyline, LatLng latlng, int polylineIdx ) => _onTap("track", polyline, latlng, polylineIdx)
            //onTap: _onTap("Tapped on PolylineLayer"),
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: displayGpxFileTrack == true ? _trackService.gpxFileData.gpxLatlng : <LatLng>[],
                strokeWidth: 4.0,
              )
            ]
          ),
          MarkerLayerOptions(
            markers: markerList,
            //markers: activePointsMarker(),
          ),
          MarkerLayerOptions(
            markers: gpsPosList,
          ),
          MarkerLayerOptions(
            markers: coordsMarkerList,
          ),
          MapStatusLayerOptions(streamController: streamController),
        ],
      ),
    );
  }

  List<Marker> get gpsPosList => makeGpsPosList();

  List<Marker> makeGpsPosList({LatLng currentPos}) {
    List<Marker> ml = [];

    if (_trackService.trackLatlngPoints.length > 0 && _mapStatusLayer.tracking == true ) {
      Marker gpsMarker = Marker(
          width: 80,
          height: 80,
          point: currentPos == null ? _trackService.trackLatlngPoints.last : currentPos,
          builder: (ctx) =>
              Container(
                child: Icon(
                    Icons.gps_fixed
                ),
              )
      );
      ml.add(gpsMarker);
    }
    return ml;
  }


  List<Marker> get markerList => makeMarkerList();
  List<GlobalKey> markerKeyList = [];

  List<Marker> makeMarkerList() {
    List<Marker> ml = [];
   // List p = _trackService.trackLatlngPoints;

      for (var i = 0; i < _trackService.trackLatlngPoints.length; i++) {
        Marker newMarker = Marker(
            width: 40.0,
            height: 40.0,
            point: _trackService.trackLatlngPoints[i],
            builder: (ctx) =>
                Container(
                  child: GestureDetector(
                    onTap: () {
                      _handleTapOnMarker(_trackService.trackLatlngPoints[i], i);
                    },
                    onLongPress: () {
                      _handleLongPressOnMarker(
                          ctx, _trackService.trackLatlngPoints[i], i);
                    },
                    child: Icon(
                      Icons.location_on,
                      color: _getMarkeIconColor(i),
                    ),
                  ),
                )
        );
        ml.add(newMarker);
      }

    return ml;
  }

  /// display gpx file tracks, each track coord as marker
  List<Marker> get coordsMarkerList => makeCoordsMarkerList();

  List<Marker> makeCoordsMarkerList() {
    List<Marker> ml = [];
    if (_trackService.gpxFileData != null && _showCoordsAsPoints == true) {
      for (var i = 0; i < _trackService.gpxFileData.gpxCoords.length; i++) {
        LatLng latLng = LatLng(_trackService.gpxFileData.gpxCoords[i].lat,
            _trackService.gpxFileData.gpxCoords[i].lon);
        Marker newMarker = Marker(
            width: 30.0,
            height: 30.0,
            point: latLng,
            builder: (ctx) =>
                Container(
                  child: GestureDetector(
                    onTap: () {
                      _handleTapOnMarker(latLng, i);
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                  ),
                )
        );
        ml.add(newMarker);
      }
    }
    return ml;
  }


  /// Display active Marker or track points.
  /// Used to display start and end point of an track segment.
  List<Marker> activePointsMarker() {
    List<Marker> ml = [];
    for (var i = 0; i < _activeMarker.length; i++) {
      Marker newMarker = Marker(
        width: 40.0,
        height: 40.0,
        point: _trackService.trackLatlngPoints[_activeMarker[i]],
        builder: (ctx) =>
            Container(
              child: Icon(
                Icons.location_on,
                color: _getMarkeIconColor(_activeMarker[i]),
              ),
            )
      );
      ml.add(newMarker);
    }
    return ml;
  }

  /// Subscribe / Unsubscribe to PositionStream in Geolocation
  toggleTracker(bool trackState) {
    print("tourmap.toggleTracker to $trackState");
    if (trackState == true && _tracking == false) {
      trackerStreamSetup();
      GeoLocationService.gls.subscribeToPositionStream(trackerStreamController);
      //GeolocationService.gls.streamGenerator(trackerStreamController);
      _tracking = true;
    } else {
      GeoLocationService.gls.unsubcribeToPositionStream();
      _tracking = false;
    }
  }

  trackerStreamSetup() {
    trackerStreamController = StreamController();
    trackerStreamController.stream.listen((coords) {
      onTrackerEvent(coords);
    });
  }

  /// trackStreamController stream msg
  /// Two possible listener tracking and show current Position, both possible
  onTrackerEvent(Position coords) {
    print(coords);
    // add coord
    if (_tracking) {
      _trackService.addTrackPoint(LatLng(coords.latitude, coords.longitude));
    }

    // update current position marker
    if (_mapStatusLayer.tracking == true) {
      LatLng currentPos = LatLng(coords.latitude, coords.longitude);
      makeGpsPosList(currentPos: currentPos);
    }
  }


  /// Switch display of current position
  /// Subscribe to position stream in GeoLocationService
  showPosition(bool positionDisplayState) {
    _showPosition = positionDisplayState;
    if (positionDisplayState) {
      if (!_tracking) {
        trackerStreamSetup();
        GeoLocationService.gls.subscribeToPositionStream((trackerStreamController));
      }
    } else {
      if (!_tracking) {
        GeoLocationService.gls.unsubcribeToPositionStream();
      }
    }
//    if (!_tracking) {
//      trackerStreamSetup();
//      GeoLocationService.gls.subscribeToPositionStream((trackerStreamController));
//    } else {
//      if (!_tracking) {
//        GeoLocationService.gls.unsubcribeToPositionStream();
//      }
//    }
  }


  /// Marker dialog
  Future _markerDialog(int trackpointIdx, LatLng latlng) async {
    String coords = "${latlng.longitude.toStringAsFixed(6)}/${latlng.latitude.toStringAsFixed(6)}";
    int trackPointId = _trackService.trackCoords[trackpointIdx].id;
    /// marker has an item?
    int itemId = _trackService.trackCoords[trackpointIdx].item;

    /// New Item (MarkerDialog) or show Item (ItemDialog)
    if (itemId == null) {
      switch(await showDialog(
        context: context,
        child: TrackPointDialog(context, trackPointId, coords, itemId),
      )) {
        case "ADD":
          print('trackPointDialog ADD');
          _itemDialog(trackpointIdx, coords);
          setState(() {});
          break;

        case "REMOVE":
          print('tackPointDialog REMOVE');
          _trackService.deleteTrackPoint(trackpointIdx);
          setState(() {});
          break;

        case "EDIT" :
          break;
      }
    } else {
      streamController.add(TrackPageStreamMsg("showItem", trackpointIdx));
      _showItem = true;
      //_itemDialog(trackpointIdx, coords);
    }

  }


  /// show modal to enter item data
  /// new empty info object for modal data
  Future _itemDialog(int trackPointIdx, String latlng) async {
    var trackItem = await _trackService.getTrackItem(trackPointIdx);
    if (trackItem != null) {
      switch (await showDialog(
          context: context,
          builder: (context) {
            return ItemDialog(context, trackPointIdx, trackItem);
          }
      )) {
        case "SAVE" :
          if (trackItem.id == null) {
            await _trackService.saveItem(trackItem, trackPointIdx);
          } else {
            await _trackService.updateItem(trackItem, trackPointIdx);
          }
          await _trackService.getTrackItems();
          setState(() { markerList; });
          break;
        case "CANCEL" :

          break;
        case "REMOVE":
          await _trackService.deleteItem(trackItem, trackPointIdx);
          _trackService.getDatabaseData();
          setState(() {});
          break;
      }
    }
  }

  OverlayEntry getOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    //var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
          left: 0.0,
          top: 0.0,
          width: 400.0,
          child: Container(
            color: Colors.blueGrey,
            height: 600.0,
          ),
        )
    );
  }
    //await _trackService.itemDialog(context, trackPointIdx, latlng);
    //return true;

//    if(_trackService.markerSelected.item != null) {
//
//    } else {
//
//    }
//
//    switch ( await showDialog(
//        context: context,
//        builder: (context) {
//
//        }))
//  }
}

/// Possible action for a track amp
enum MapTapAction {
  NOACTION,
  ADD_MARKER,
  ADD_ITEM,
  SELECT_MARKER,
  ADD_PATHMARKER,
  MOVE_MARKER,
}