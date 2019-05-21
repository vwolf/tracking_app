import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import '../track/trackService.dart';


class MapStatusLayerOptions extends LayerOptions {
  final StreamController streamController;

  MapStatusLayerOptions({this.streamController});
}


/// Display map status on a map layer and trigger events.
///
/// String: status [statusMsg]
/// Icon: current position display [tracking]
/// Icon: show list of markers
/// Icon: show list of items
/// Icon: toggle display of coords as markers
class MapStatusLayer implements MapPlugin {

  String statusMsg = "Select in menu";
  bool tracking = false;
  bool showCoords = false;

  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream
      ) {
    if (options is MapStatusLayerOptions) {
      return MapStatus(
          streamCtrl: options.streamController,
          statusMsg: statusMsg,
          tracking: tracking,
          showCoords: showCoords,
      );
    }
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is MapStatusLayerOptions;
  }

  statusNotification(String newStatus) {
    print("statusLayer stateNotification $statusMsg");
    statusMsg = newStatus;
  }

  statusNotificationDummy(String newStatus) {
    statusMsg = newStatus;
  }

  trackingOnOff(bool trackingState) {
    tracking = trackingState;
  }

}

/// [streamCtrl] send and receive messages [TrackPageStreamMsg]
/// [statusMsg] String
/// [tracking] boolean
class MapStatus extends StatefulWidget {

  final streamCtrl;
  final statusMsg;
  final tracking;
  final showCoords;

  MapStatus({this.streamCtrl, this.statusMsg, this.tracking, this.showCoords});



  @override
  _MapStatusState createState() => _MapStatusState();

}


class _MapStatusState extends State<MapStatus> {


  Color containerColor = Colors.orange;

  /// Status row has equal left and right part
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: <Widget>[
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 4.0),
              child: Text(widget.statusMsg,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),),
            ),
          ),

        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.control_point,
                color: widget.showCoords == true ? Colors.orangeAccent: Colors.black26,
                size: 36.0,
              ),
              onPressed: () => iconAction("showTrackCoords"),
            ),
            IconButton(
              icon: Icon(
                widget.tracking == true ? Icons.gps_fixed : Icons.gps_off,
                color: Colors.orangeAccent,
                size: 36.0,
              ),
              onPressed: () => iconAction("trackingOnOff"),
            ),
            IconButton(
              icon: Icon(
                  Icons.assistant,
                  color: Colors.orangeAccent,
                size: 36.0,),
              onPressed: () => iconAction("trackPoints"),
            ),
            IconButton(
              icon: Icon(
                  Icons.info,
              color: Colors.orangeAccent,
              size: 36.0,),
              onPressed: () => iconAction("trackItems"),
            )
          ],
        ),
        ],
      ),
    );
  }



  iconAction(String action) {
    switch (action) {
      case "trackinOnOff" :
        bool trackingState = !widget.tracking;
        widget.streamCtrl.add(TrackPageStreamMsg("showPosition", trackingState));
        break;

//      case "toggleTrackPoints" :
//        bool showTrackCoords = !widget.showCoords;
//        widget.streamCtrl.add(TrackPageStreamMsg("showTrackCoords", showTrackCoords));
//        break;

      default:
        widget.streamCtrl.add(TrackPageStreamMsg("mapStatusAction", action));
    }

//    if (action == "trackingOnOff") {
//      bool trackingState = !widget.tracking;
//      widget.streamCtrl.add(TrackPageStreamMsg("showPosition", trackingState));
//    } else {
//      widget.streamCtrl.add(TrackPageStreamMsg("mapStatusAction", action));
//    }

  }

}

