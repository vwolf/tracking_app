/// SimpleDialog for Geo Markers
/// Create, display and modify
/// Name, info, image(s) can change
/// LanLng is final

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../database/database.dart';
import '../database/models/trackItem.dart';

class MarkerDialog extends StatefulWidget {
  final String title;
  final LatLng latlng;


  MarkerDialog(
      title, latlng)
      : title = title,
        latlng = latlng;

  //static String _title = "$title";

  _MarkerDialogState createState() => _MarkerDialogState();
}


class _MarkerDialogState extends State<MarkerDialog> {


  final _formkey = GlobalKey<FormState>();
  final _dialogMarkerNameController = TextEditingController();
  final _dialogMarkerInfoController = TextEditingController();

  /// layout properties
  double _edgeInsetHorz = 12.0;
  String _title;

  String _markerImagePath;
  AssetImage _markerImage;

  @override
  void initState() {
    super.initState();
    _title = widget.title;

    _dialogMarkerNameController.text = _title;
    _getContent();
  }

  /// events
  addImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery
    );

    print("Selected image: ${image.path}");
    _markerImagePath = image.path;
    _markerImage = await AssetImage(_markerImagePath);
    setState((){});
  }


  /// save marker to db

  saveMarker() {
    TrackItem trackItem = TrackItem(
      name: _dialogMarkerNameController.text,
      info: _dialogMarkerInfoController.text,
      latlng: json.encode(widget.latlng),
    );

  }


  _getContent() {
    return SimpleDialog(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: TextFormField(
            controller: _dialogMarkerNameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Enter marker name',
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 6.0, left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: Text(
            "(${widget.latlng.latitude}, ${widget.latlng.longitude})",
            style: TextStyle(
                fontSize: 12.0
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: TextField(
            controller: _dialogMarkerInfoController,
            keyboardType: TextInputType.text,
            maxLines: null,
            decoration: InputDecoration(
              labelText: "Marker Info",
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 4.0, left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: SimpleDialogOption(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        addImage();
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Add Image",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Divider(
          height: 8.0,
          color: Colors.white70,
        ),
        markerImage
      ],
    );
  }


  Widget get markerImage {
    if (_markerImagePath == null) {
      return Container();
    } else {
      return Container(
        height: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          image: DecorationImage(
            image: getMarkerImage(),
            fit: BoxFit.fitHeight,
          ),
        ),
      );
    }
  }

  getMarkerImage() {
    return AssetImage(_markerImagePath);
  }


  @override
  Widget build(BuildContext contesxt) {
    return _getContent();
  }

}