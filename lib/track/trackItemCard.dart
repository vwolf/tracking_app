import 'package:flutter/material.dart';
import '../database/models/trackItem.dart';
import 'trackService.dart';

class TrackItemCard extends StatefulWidget {
  final TrackItem _trackItem;
  final GlobalKey _trackMapKey;
  final TrackService _trackService;

  TrackItemCard(this._trackItem, this._trackMapKey, this._trackService);

  @override
  TrackItemCardState createState() => TrackItemCardState(_trackItem);
}

class TrackItemCardState extends State<TrackItemCard> {
  final TrackItem trackItem;

  TrackItemCardState(this.trackItem);

  String editableContent = "nothing";
  TextEditingController _formNameController = TextEditingController();
  TextEditingController _formInfoController = TextEditingController();

  /// Form style
  TextStyle _formTextStyle = TextStyle(color: Colors.white, fontSize: 18.0);
  InputDecoration _formInputDecoration = InputDecoration(
      labelText: 'Edit name', labelStyle: TextStyle(color: Colors.white));

  /// Images
  List<AssetImage> images = [];
  List<String> imagesPath = [];
  bool showImage = false;

  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();

    for (var imgPath in trackItem.images) {
      imagesPath.add(imgPath);
    }
    loadImage();
  }

  loadImage() async {
    for (var imgPath in imagesPath) {
      AssetImage imgPathImage = await AssetImage(imgPath);

      images.add(imgPathImage);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _formNameController.dispose();
    _formInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.blueGrey,
        width: double.infinity,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: _getNameWidget('name')),
                Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: _getInfoWidget('info'),
                ),
                Divider(
                  height: 8.0,
                  color: Colors.white70,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: _imagesRow,
                ),
                Divider(
                  height: 4.0,
                    color: Colors.white70,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12.0, top: 6.0),
                  child: RaisedButton(
                    child: Text('Save'),
                    onPressed: saveItem,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// ToDo Save edit text in TextFormField or TextField
  setEditMode(String contentName) {

    switch (editableContent) {
      case "name" :
        trackItem.name = _formNameController.text;
        break;

      case "info" :
        trackItem.info = _formInfoController.text;
        break;

      default:
        _formNameController.text = trackItem.name;
        _formInfoController.text = trackItem.info;
    }

    editableContent = contentName;

    setState(() {});
  }

  /// called when hidding keyboard
  _onEditingComplete() {
    print("_onEditingComplete");

    switch (editableContent) {
      case "name" :
        trackItem.name = _formNameController.text;
        break;

      case "info" :
        trackItem.info = _formInfoController.text;
        break;
    }

    // trackItem.name = _formNameController.text;
    setEditMode("nothing");
  }

  saveItem() async {
    await widget._trackService.updateItem(trackItem, trackItem.markerId);
  }

  Widget _getNameWidget(String contentType) {
    _formNameController.text = trackItem.name;
    if (editableContent == "name") {
      return Column(
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: TextFormField(
                style: _formTextStyle,
                controller: _formNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                cursorColor: Colors.white,
                decoration: _formInputDecoration,
                onEditingComplete: () {
                  _onEditingComplete();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter a name";
                  }
                },
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white70,
              ),
              onPressed: () => setEditMode("nothing"),
            )
          ])
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: Text(
            trackItem.name,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          )),
          IconButton(
           // alignment: Alignment.centerRight,
            icon: Icon(
              Icons.edit,
              color: Colors.white70,
            ),
            onPressed: () => setEditMode("name"),
          ),
        ],
      );
    }
  }

  Widget _getInfoWidget(String contentType) {
    _formInfoController.text = trackItem.info;

    if (editableContent == "info") {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                 child: TextField(
                  style: _formTextStyle,
                  controller: _formInfoController,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "Edit Info",
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white70,
                ),
                onPressed: () => setEditMode("nothing"),
              )
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Text(
              trackItem.info,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white70,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white70,
            ),
            onPressed: () => setEditMode("info"),
          )
        ],
      );
    }
  }

  Widget get _imagesRow {
    if (images.length > 0) {
      return Container(
        width: double.maxFinite,
        height: 64.0,
        color: Colors.blueGrey,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: images
              .map((img) => InkWell(
                    onTap: () {
                      _overlayEntry = getOverlayEntry(img);
                      Overlay.of(context).insert(_overlayEntry);
                    },
                    child: Container(
                      width: 64.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.redAccent,
                          image: DecorationImage(
                              image: img, fit: BoxFit.fitHeight)),
                    ),
                  ))
              .toList(),
        ),
      );
    } else {
      return Container(
        height: 2.0,
        color: Colors.green,
      );
    }
  }

  OverlayEntry getOverlayEntry(AssetImage img) {
    //RenderBox renderBox = context.findRenderObject();
    final RenderBox renderBox =
        widget._trackMapKey.currentContext.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
            left: 0.0,
            top: 0.0,
            width: size.width,
            child: Container(
              color: Colors.blueGrey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: size.height,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.redAccent,
                      image: DecorationImage(
                        image: img,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Material(
                            child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteImage(img);
                                  removeOverlay();
                                  setState(() {
                                    _imagesRow;
                                  });
                                }),
                          ),
                          right: 8.0,
                          top: 24.0,
                        ),
                        Positioned(
                          child: Material(
                            child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                ),
                                onPressed: () {
                                  removeOverlay();
                                }),
                          ),
                          left: 8.0,
                          top: 24.0,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  removeOverlay() {
    _overlayEntry.remove();
  }

  deleteImage(AssetImage img) {
    if (images.contains(img)) {
      int imgIdx = images.indexOf(img);
      if (imgIdx >= 0) {
        images.removeAt(imgIdx);
        imagesPath.removeAt(imgIdx);
      }
    }
  }
}
