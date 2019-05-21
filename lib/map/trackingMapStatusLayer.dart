import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import '../track/trackService.dart';



class TrackingMapStatusLayerOptions extends LayerOptions {
  final StreamController streamController;
  
  TrackingMapStatusLayerOptions({this.streamController});
}

class TrackingMapStatusLayer implements MapPlugin {
  //final status;
  String tracking_status;

  TrackingMapStatusLayer(this.tracking_status);


  
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream
      ) {
    if (options is TrackingMapStatusLayerOptions) {
      return TrackingMapStatus(streamCtrl: options.streamController, tracking_status: tracking_status);
    }
  }
  
  @override
  bool supportsLayer(LayerOptions options) {
    return options is TrackingMapStatusLayerOptions;
  }

  statusNotification(String newStatus) {
    print("statusLayer stateNotification $tracking_status : newStatus: $newStatus");
    tracking_status = newStatus;
  }
}


class TrackingMapStatus extends StatefulWidget {
  
  final streamCtrl;
  final tracking_status;
  
  TrackingMapStatus({this.streamCtrl, this.tracking_status});
  
  @override
  _TrackingMapStatusState createState() => _TrackingMapStatusState();
}


class _TrackingMapStatusState extends State<TrackingMapStatus> {

  @override
  void initState(){
    super.initState();
  }



  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text(widget.tracking_status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            ),
          ),
        ),
        
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.location_on,
                color: widget.tracking_status == "location_on" ? Colors.orangeAccent : Colors.white70,
                size: 36.0,
              ),
              onPressed: () => iconAction('location_on'),
            ),
            IconButton(
              icon: Icon(
                Icons.camera,
                color: Colors.orangeAccent,
                size: 36.0,
              ),
              onPressed: () => iconAction('camera'),
            )
          ],
        ),
      ],
    );
  }
  
  iconAction(String action) {
    widget.streamCtrl.add(TrackPageStreamMsg("trackingMapStatusAction", action));
  }

}