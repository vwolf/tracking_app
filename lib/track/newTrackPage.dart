import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';

import '../services/geoLocationService.dart';
import '../database/database.dart';
import '../database/models/track.dart';
import '../readWrite/readFile.dart';
import '../gpx/gpxParser.dart';

/// Create or update an track
class NewTrackPage extends StatefulWidget {
  Track tour = Track();

  NewTrackPage();

  NewTrackPage.withTour(Track tour) {
    this.tour = tour;
  }

  @override
  _NewTrackPageState createState() => _NewTrackPageState();
}


class _NewTrackPageState extends State<NewTrackPage> {

  Track savedTour;
  bool _newTrack = true;
  bool _formSaved = false;
  String _offlineMapPath;
  String _gpxFilePath;
  String _trackType = "walk";

  // form key and controller
  final _formkey = GlobalKey<FormState>();
  final _formNameController = TextEditingController();
  final _formDescriptionController = TextEditingController();
  final _formLocationController = TextEditingController();
  final _formStartLatitudeController = TextEditingController();
  final _formStartLongitudeController = TextEditingController();

  /// Form style
  TextStyle _formTextStyle = TextStyle(color: Colors.white);

  InputDecoration _formInputDecoration = InputDecoration(
      labelText: 'Enter name', labelStyle: TextStyle(color: Colors.white));

  @override
  void initState() {

    super.initState();

    print("newTrackPage track id: ${widget.tour.id}");
    if (widget.tour.name != null) {
      _newTrack = false;
      _formSaved = true;
      _formNameController.text = widget.tour.name;
      _formDescriptionController.text = widget.tour.description;
      _formLocationController.text = widget.tour.location;

      if (widget.tour.coords != null) {
        LatLng tourCoords = GeoLocationService.gls.stringToLatLng(widget.tour.coords);
        _formStartLatitudeController.text = tourCoords.latitude.toString();
        _formStartLongitudeController.text = tourCoords.longitude.toString();
      } else {
        _formStartLatitudeController.text = '0.00';
        _formStartLongitudeController.text = '0.00';
      }

      if (widget.tour.options != null) {
        _gpxFilePath = widget.tour.getOption('_gpxFilePath');
        _offlineMapPath = widget.tour.getOption('_offlineMapPath');
      }
      savedTour = widget.tour;

    } else {
      _formStartLatitudeController.text = '0.00';
      _formStartLongitudeController.text = '0.00';
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: _newTrack == true ? Text("New Track") : Text("Update Track"),
      ),
      body: ListView(
        children: <Widget>[
          _form,
          _tourImage,
          _loadFromStorage,
        ],
      ),
    );
  }

  /// Read track data from gpx file
  /// ToDo fileType GPX or Gpx or gpX?
  Future getTrack() async {
    final filePath = await ReadFile().getPath();
    String fileType = path.extension(filePath);
    if (fileType != '.gpx') {
      print("Wrong type of file");
      bottomSheet(fileType);
      return null;
    }
    /// right file type
    _gpxFilePath = filePath;

    final fileContent = await ReadFile().readFile(filePath);
    //GpxFileData trackGpxData = GpxFileData();
    GpxFileData trackGpxData = await GpxParser(fileContent).parseData();

    /// fill form
    _formNameController.text = trackGpxData.trackName;
    _formDescriptionController.text = trackGpxData.trackSeqName;
    _formLocationController.text = trackGpxData.trackName;

    /// translate first point to an address
    GpxCoords firstPoint = trackGpxData.gpxCoords.first;

    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        firstPoint.lat, firstPoint.lon,
        localeIdentifier: "de_DE");
    print(placemark);
    if (placemark.isNotEmpty && placemark != null) {
      String loc = placemark[0].country + ", " + placemark[0].locality;
      _formLocationController.text = loc;
    }

    // use first point as startCoords
    _formStartLatitudeController.text = firstPoint.lat.toString();
    _formStartLongitudeController.text = firstPoint.lon.toString();
  }


  bottomSheet(String fileType) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.error, color: Colors.redAccent,),
                title: Text('Can\' read file of type $fileType. Choose a gps file. '),
              ),
            ],
          );
        });
  }

  Future getImage() async {}

  loadFromExternal() async {}


  /// Get current position,
  /// TODO GeoloctionService can fail - set default values
  getStartPosition() async {
    LatLng currentPosition = await GeoLocationService.gls.simpleLocation();
    _formStartLatitudeController.text = currentPosition.latitude.toString();
    _formStartLongitudeController.text = currentPosition.longitude.toString();

    /// startPosition to country, locality and administrativeArea
    String description = await GeoLocationService.gls.getCoordDescription(currentPosition);
    _formLocationController.text = description;
  }

  /// Used as closure in SubmitBtnWithState
  /// Track exists?
  Future submitEvent(int i) async {
    print('submit event $i');
    //var trackExists = await DBProvider.db.trackExists(_formNameController.text);
    if (_newTrack == false) {
      /// TODO Track update
      /// tour name changed? - then create new track and item table and copy data
      /// rename table???

      widget.tour.description = _formDescriptionController.text;
      widget.tour.location = _formLocationController.text;

      if (widget.tour.name != _formNameController.text) {
        var savedTourName = savedTour.name;
        widget.tour.name = _formNameController.text;
        var result = await DBProvider.db.cloneTrack(widget.tour, savedTourName);
      } else {
        var result = await DBProvider.db.updateTrack(widget.tour);
        return false;
      }

      return false;
    }

    /// New Track
    if (_formkey.currentState.validate()) {
      widget.tour.name = _formNameController.text;
      widget.tour.description = _formDescriptionController.text;
      widget.tour.location = _formLocationController.text;
      widget.tour.open = false;

      /// Start coordinates
      LatLng startCoords = LatLng(
          _formStartLatitudeController.text.isNotEmpty
              ? double.parse(_formStartLatitudeController.text)
              : 0.0,
          _formStartLongitudeController.text.isNotEmpty
              ? double.parse(_formStartLongitudeController.text)
              : 0.0);
      widget.tour.coords = GeoLocationService.gls.latlngToJson(startCoords);

      /// options
      Map<String, dynamic> options = {"type" : _trackType};

      /// Gpx file path
      if (_gpxFilePath != null) {
        //widget.tour.options = jsonEncode({"gpxFilePath": _gpxFilePath});
        options["gpxFilePath"] =  _gpxFilePath;
      }

      widget.tour.options = jsonEncode(options);

      /// Add timestamp to track (created or modified)
      widget.tour.timestamp = DateTime.now();

      /// Write to db, returns int
      var dbResult = await DBProvider.db.newTrack(widget.tour);
      print(dbResult);
      _formSaved = true;
    }
  }


  setTrackType(String type) {

    setState(() {
      _trackType = type;
    });
  }


  Widget get _form {
    return Form(
      key: _formkey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                style: _formTextStyle,
                controller: _formNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                cursorColor: Colors.white,
                decoration: _formInputDecoration,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter a name";
                  }
                },
                maxLines: 1,
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _formDescriptionController,
                  style: _formTextStyle,
                  decoration: InputDecoration(
                    labelText: 'Enter Description',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                  },
                  maxLines: null,
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                      onPressed: () => setTrackType('walk'),
                      icon: Icon(Icons.directions_walk,
                      color: !(_trackType == "walk") ? Colors.white30 : Colors.white,),
                      label: Text('')),
                  FlatButton.icon(
                      onPressed: () => setTrackType('bike'), //() => { setState(() {_trackType = "bike"; })},
                      icon: Icon(Icons.directions_bike,
                      color: !(_trackType == "bike") ? Colors.white30 : Colors.white),
                      label: Text('')),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _formLocationController,
                style: _formTextStyle,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Enter Location name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter location name';
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'Start Coordinates',
                style: _formTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                      child: TextFormField(
                    controller: _formStartLatitudeController,
                    style: _formTextStyle,
                    decoration: InputDecoration(
                        labelText: 'Latitude',
                        labelStyle: TextStyle(color: Colors.white)),
                    keyboardType: TextInputType.number,
                  )),
                  Flexible(
                    child: TextFormField(
                      controller: _formStartLongitudeController,
                      style: _formTextStyle,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  FlatButton.icon(
                    onPressed: getStartPosition,
                    icon: Icon(Icons.add,
                    color: Colors.white,),
                    label: Text(' '),
                  ),
                ],
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SubmitBtnWithState(submitEvent, 'Processing'),
                    RaisedButton(
                      child: Text('Load GPX'),
                      color: Colors.blue,
                      onPressed: getTrack,
                    ),
                    FlatButton.icon(
                      onPressed: _formSaved == true ? getImage : null,
                      icon: new Icon(Icons.image),
                      label: Text('Add Image'),
                      disabledColor: Colors.white30,
                      color: Colors.blue,
                    ),
                  ],
                )),
          ]),
    );
  }

  Widget get _tourImage {
    if (widget.tour.tourImage != null) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Container(
            height: 80.0,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage(widget.tour.tourImage),
              ),
            ),
          ));
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget get _loadFromStorage {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: RaisedButton(
          child: Text("Load Saved Tour"),
          color: Colors.blue,
          onPressed: loadFromExternal,
        )
      );
  }

}

class SubmitBtnWithState extends StatefulWidget {
  final void Function(int) callback;
  final String btnText;

  SubmitBtnWithState(this.callback, this.btnText);

  @override
  _SubmitBtnWithState createState() => _SubmitBtnWithState();
}


/// State for class SubmitBtnWithState
class _SubmitBtnWithState extends State<SubmitBtnWithState> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Submit'),
      color: Colors.blue,
      onPressed: () {
        widget.callback(1);
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(widget.btnText),
          duration: Duration(seconds: 2),
        ));
      },
    );
  }
}
