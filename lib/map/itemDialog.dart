import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/models/trackCoord.dart';
import '../database/models/trackItem.dart';
import 'package:intl/intl.dart';

/// Modal to add a item
/// Constructor get's an TourItem Object
/// Use TourItem properties to initialize
class ItemDialog extends StatefulWidget {
  final context;
  final int trackIndex;
//  final ValueSetter<Map> onReflectItemDialog;
//  final ValueSetter<List> onImagesInItemDialog;
  final TrackItem trackItem;

  ItemDialog(this.context,
      this.trackIndex,
      this.trackItem);
//      this.onReflectItemDialog,
//      this.onImagesInItemDialog,


  @override
  ItemDialogState createState() => ItemDialogState();
}


class ItemDialogState extends State<ItemDialog> {
  /// layout properties
  double _edgeInsetHorz = 12.0;

  String _markerImagePath;
  AssetImage _markerImage;

  List<AssetImage> images = [];
  List<String> imagesPath = [];

  TextEditingController _textCtrlName = TextEditingController();
  TextEditingController _textCtrlInfo = TextEditingController();

  bool _editMode = false;

  DateFormat _dateFormat = DateFormat.yMd().add_Hm();

  bool showImages = false;

  OverlayEntry _overlayEntry;
  List<int> imagesToDelete = [];

  @override
  initState() {
    super.initState();
//    _overlayEntry = getOverlayEntry();
//    Overlay.of(context).insert(_overlayEntry);

    if (widget.trackItem.name != null ) {
      _textCtrlName.text = widget.trackItem.name;
      _textCtrlInfo.text = widget.trackItem.info;
      for (var imgPath in widget.trackItem.images) {
        imagesPath.add(imgPath);
      }
      loadImage();
      //imagesPath = widget.trackItem.images;
      _editMode = true;
    }

  }

  addImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery
    );
    if (image != null) {
      print("Selected image: ${image.path}");
      _markerImagePath = image.path;
      AssetImage selectedImage = await AssetImage(_markerImagePath);
      images.add(selectedImage);
      imagesPath.add(_markerImagePath);

      setState((){});
    }
  }


  loadImage() async {
    for (var imgPath in imagesPath) {
      AssetImage imgPathImage = await AssetImage(imgPath);

      images.add(imgPathImage);
    }
    setState(() {});
  }

  _getContent() {
    return SimpleDialog(
      title: Text( _editMode == false ? "New Item" : "Edit Item" ),
      children: <Widget>[
        Divider(height: 10.0, color: Colors.white70,),
        Padding(
          padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: _trackItemData(),
        ),
        Padding(
          padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: TextFormField(
            controller: _textCtrlName,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: "Name",
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: TextField(
            controller: _textCtrlInfo,
            keyboardType: TextInputType.text,
            maxLines: null,
            decoration: InputDecoration(
              labelText: "Marker Info",
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
          child: imagesRow,
        ),


        Padding(
            padding: EdgeInsets.only(left: _edgeInsetHorz, right: _edgeInsetHorz),
            child: SimpleDialogOption(
              child: RaisedButton(
                child: Text('Add Image'),
                onPressed: () {addImage(); },
              ),
            )
        ),

        Divider(height: 10.0, color: Colors.white70,),

        Row (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SimpleDialogOption(
              child: Text("SAVE"),
              onPressed: (){
//                widget.onReflectItemDialog({
//                  'name': _textCtrlName.text,
//                  'info': _textCtrlInfo.text
//                });
//                widget.onImagesInItemDialog(imagesPath);
                widget.trackItem.name = _textCtrlName.text;
                widget.trackItem.info = _textCtrlInfo.text;
                widget.trackItem.images = imagesPath;
                Navigator.pop(context, "SAVE");
              },
            ),
            SimpleDialogOption(
              child: Text("CANCEL"),
              onPressed: (){
                Navigator.pop(context, "CANCEL");
                },
            ),
            _itemDialogDeleteButton()
          ],
        ),

      ],
    );
  }

  /// Return TrackItem data for existing trackItem
  Widget _trackItemData() {
    if (_editMode == true) {
      return Text("Created at: ${_dateFormat.format(widget.trackItem.timestamp)}");
    }

    return Container(
      height: 0.0,
    );
  }

  /// Return REMOVE button if [_editMode] is true
  Widget _itemDialogDeleteButton() {
    if(_editMode == true) {
      return SimpleDialogOption(
        child: Text('REMOVE'),
        onPressed: () {
          Navigator.pop(context, "REMOVE");
        },
      );
    }

    return Container(
      height: 0.0,
    );
  }


  /// Add width property to Container ( IntrinsicWidth error)
  Widget get imagesRow {
    if (images.length > 0 ) {
      return Container(
          width: double.maxFinite,
          height: 64.0,
          color: Colors.orangeAccent,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: images.map((img) => InkWell(
              onTap: () {
                print('tap on images');
                //showImages = true;
                // test Overlay
                _overlayEntry = getOverlayEntry(img);
                Overlay.of(context).insert(_overlayEntry);
              },
              child: Container(
                width: 64.0,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.redAccent,
                  image: DecorationImage(
                      image: img,
                      fit: BoxFit.fitHeight
                  ),
                ),
              ),
            )).toList(),
//            children: images.map((img) => Container(
//              //height: 64.0,
//              width: 64.0,
//              decoration: BoxDecoration(
//                  shape: BoxShape.rectangle,
//                  color: Colors.redAccent,
//                  image: DecorationImage(
//                      image: img,
//                      fit: BoxFit.fitHeight
//                  )
//              ),
//            )).toList(),
          )
      );
    } else {
      return Container(
        height: 2.0,
        color: Colors.greenAccent,
      );
    }
  }


  Widget get markerImage {
    if ( images.length == 0) {
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

//  Widget get overlay {
//    OverlayEntry overlayEntry = getOverlayEntry();
//    Overlay.of(context).insert(overlayEntry);
////    return Overlay(
////      initialEntries: getOverlayEntry(),
////    );
//  }

  OverlayEntry getOverlayEntry(AssetImage img) {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: 0.0,
        top: 0.0,
        width: size.width,
        child: Container(
          color: Colors.blueGrey,
          //height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //Text('Overlay'),
//              RaisedButton(
//                child: Text('BTN'),
//                onPressed: () {
//                  print('Overlay Btn');
//                  removeOverlay();
//                },
//              ),

              Container(
                height: size.height,
                //width: size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.redAccent,
                  image: DecorationImage(
                    image: img,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: <Widget> [
                    Positioned(
                      child: Material(
                        child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteImage(img);
                              removeOverlay();
                              setState(() {
                                imagesRow;
                              });
                            }
                              ),

                      ),
                      right: 8.0,
                      top: 24.0,
//                      child: Icon(Icons.delete, size: 48.0,),
//                      right: 30.0,
//                      top: 40.0,
                    ),

                    Positioned(
                        child: Material(
                          child: IconButton(icon: Icon(Icons.close), onPressed: () {removeOverlay();}),
                        ),
                        left: 8.0,
                        top: 24.0,
                    )



//                    Positioned(
//                      child: Container(
//                        child: IconButton(icon: Icon(Icons.close), onPressed: () {}),
//                      ),
//                      child: IconButton(
//                          icon: Icon(Icons.close), onPressed: () {}),
//                    )
                  ]

                )
               // child: Icon(Icons.remove),
              ),
//              Positioned(
//                right: 0.0,
//                  bottom: 0.0,
//                child: new Icon(Icons.remove),
//              )
            ],
          ),
        ),
      )
    );
  }

  removeOverlay() {
    _overlayEntry.remove();
  }



  deleteImage(AssetImage img) {
    if  (images.contains(img)) {
      print('Index of images: ' + images.indexOf(img).toString());
      int imgIdx = images.indexOf(img);
      if (imgIdx >= 0) {
        imagesToDelete.add(imgIdx);
        images.removeAt(imgIdx);
        imagesPath.removeAt(imgIdx);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}