import 'package:flutter/material.dart';

/// Modal dialog for a track point
class TrackPointDialog extends StatelessWidget {
  final context;
  final int trackIndex;
  final String latlng;
  final int itemId;

  TrackPointDialog( context, trackIndex, latlng, itemId)
      : context = context,
        trackIndex = trackIndex,
        latlng = latlng,
        itemId = itemId;


  _getContent() {
    return SimpleDialog(
      title: Text("Marker $trackIndex"),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Text(latlng),
        ),

        Divider(
            height: 12.0,
            color: Colors.blueGrey),
        SimpleDialogOption(
          child: Text(itemId != null ? "Show Info" : "Add Info"),
          onPressed: (){ Navigator.pop(context, "ADD");},
        ),
        SimpleDialogOption(
          child: Text("Remove Marker"),
          onPressed: (){Navigator.pop(context, "REMOVE");},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}