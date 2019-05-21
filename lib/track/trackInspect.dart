import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import '../database/models/track.dart';
import '../database/models/trackItem.dart';
import 'trackService.dart';

/// Service class to inspect TrackPoints and TrackItems
class TrackInspect extends StatefulWidget {

  final TrackService trackService;
  final callBack;

  TrackInspect(this.trackService, this.callBack);

  @override
  _TrackInspectState createState() => _TrackInspectState();
}

class _TrackInspectState extends State<TrackInspect> {

  DateFormat _dateFormat = DateFormat.yMd().add_Hm();

  makeCall() {
    widget.callBack("call");
  }

  @override
  void initState() {
    super.initState();

    //initializeDateFormatting('de_DE', null).then((_) => localDate());
  }

//  localDate() {
//    print(widget.trackService.track.timestamp);
//    String d = widget.trackService.track.timestamp.toIso8601String();
//    print(d);
//    DateTime aDateTime = DateTime.parse(d);
//    print(aDateTime.day);
//    DateFormat f = DateFormat.yMd('de').add_Hm();
//    var dateString = f.format(new DateTime.now());
//    print ('dateString: $dateString');
//    print (new DateTime.now());
//    print (f.format(widget.trackService.track.timestamp));
//  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0.0),
      //constraints: BoxConstraints.loose(Size(300.0, 300.0)),
      constraints: BoxConstraints.loose(Size(double.infinity, 240)),
      color: Colors.blueGrey,
      child: ListView.builder(
        padding: EdgeInsets.all(0.0),
        itemCount: widget.trackService.trackCoords.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                'Marker ${widget.trackService.trackCoords[index].id} created at ${_dateFormat.format(
                    widget.trackService.trackCoords[index].timestamp)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              subtitle: Text(
                  ' ${widget.trackService.trackCoords[index].latitude.toString()} / ${widget.trackService.trackCoords[index].longitude.toString()}',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                widget.callBack(index);
              },
            );
          }),
//            return Card(
//              child: InkWell(
//                onTap: () {
//                  print('tap on card with index $index');
//                  widget.callBack(index);
//                },
//                child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                    padding: EdgeInsets.only(left: 4.0),
//                    child: Text(
//                        'Marker ${widget.trackService.trackPoints[index].id} created at '
//                            '${_dateFormat.format(widget.trackService.trackPoints[index].timestamp)}',
//                    style: TextStyle(fontWeight: FontWeight.bold),),
//                    ),
//
//                  Container(
//                    padding: EdgeInsets.only(left: 4.0),
//                    child: Text('Lat: ${widget.trackService.trackPoints[index].latitude.toString()}'),
//                  ),
//                  Container(
//                    padding: EdgeInsets.only(left: 4.0),
//                    child: Text('Lng: ${widget.trackService.trackPoints[index].longitude.toString()}'),
//
//                  ),
//
//                  Container(
//                    padding: EdgeInsets.only(left: 4.0),
//                    child:  Text('Marker Item Id: ${widget.trackService.trackPoints[index].item}'),
//                  ),
//
//                ],
//              )
//
////              child: Column(
////
////                crossAxisAlignment: CrossAxisAlignment.start,
////                mainAxisAlignment: MainAxisAlignment.start,
////                children: <Widget>[
////                  Text('Marker Id: ${widget.trackService.trackPoints[index].id}'),
////                  Text('CreatedAt: ${_dateFormat.format(widget.trackService.trackPoints[index].timestamp)}'),
////                  Text('Latitude: ${widget.trackService.trackPoints[index].latitude.toString()}'),
////                  Text('Longitude: ${widget.trackService.trackPoints[index].longitude.toString()}'),
////                  Text('Marker Item Id: ${widget.trackService.trackPoints[index].item}'),
////                ],
////              )
//              ),
//              //child: Text("marker ${widget.trackService.trackPoints[index].id}"),
//            );
//          })
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          Text("Persistent Bottom Bar"),
//                SizedBox(
//                  height: 20,
//                ),
//                Text(
//                  "This is a simple demo of flutter persistent bottom sheet",
//                  style: TextStyle(fontSize: 20),
//                ),
//        ],
//      ),
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.all(16.0),
//           // child: Text('marker'),
//            child: ListView.builder(
//                itemCount: widget.trackService.trackPoints.length,
//                itemBuilder: (context, int) {
//                  return Card(
//                    child: Text(
//                      "marker"
//                    )
//                  );
//                })
//          ),
//        ],
//      ),
//    );
//  }

}