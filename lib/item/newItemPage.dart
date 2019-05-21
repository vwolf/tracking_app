import 'package:flutter/material.dart';
import 'dart:async';

import 'itemTypeModal.dart';

class NewItemPage extends StatefulWidget {

  NewItemPage();

  @override
  _NewItemPageState createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {

  bool _newPoint = true;

  // form key and controller
  final _formkey = GlobalKey<FormState>();
  final _formItemNameController = TextEditingController();
  final _formItemDescriptionController = TextEditingController();
  final _formItemLocationController = TextEditingController();

  // form style
  TextStyle _formTextStyle = TextStyle(color: Colors.white);

  EdgeInsets _formEdgeInsets = EdgeInsets.symmetric(horizontal: 16.0);

  InputDecoration _formInputDecoration = InputDecoration(
      labelText: 'Enter name', labelStyle: TextStyle(color: Colors.white));


  // persistent bottom sheet for type list
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _persistentBottomSheetController;

  List<String> _typesList = ["Common", "Nature", "Urban", "Plants", "Mushroom",];
  List<bool> _typesState = [true, false, false, false, false];

  String _selectedTypes;

  Map type = {
    "Nature": true,
    "Plants": false,

  };

  @override
  void initState() {
    super.initState();

    _selectedTypes = _typesList[0];
  }

  @override
  void dispose() {
    super.dispose();
  }


  // form functions
  submitForm() {}

  getImage() {}

  getCamera() {}

  selectType(index) {
    print("selectType $index");

    setState(() {
      _selectedTypes = "";
      _typesState[index] = !_typesState[index];
      for (var i = 0; i < _typesList.length; i++) {
        if (_typesState[i] == true) {
          _selectedTypes += "${_typesList[i]} ";
        }
      }
    });
  }

  showTypes() {
    print("showTypes");
    //openPersistentBottomSheet();
    //openTypes();

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ItemTypeModal(_typesList, _typesState, selectType);
        });
  }


  void bottomSheetEvent( int index, BuildContext context) {
    print("bottomSheetEvent $index");

//    if (_typesState[index] == false) {
//      _selectedTypes += ", ${_typesList[index]}";
//    }

    setState(() {
      _selectedTypes = "";
      _typesState[index] = !_typesState[index];
      for (var i = 0; i < _typesList.length; i++) {
        if (_typesState[i] == true) {
          _selectedTypes += "${_typesList[i]} ";
        }
      }
    });

    //_persistentBottomSheetController.setState(() => {});
  }

  openPersistentBottomSheet() {
    if (_persistentBottomSheetController == null) {
      _persistentBottomSheetController = _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
        return _types;
      });

    } else {
      _persistentBottomSheetController.close();
      _persistentBottomSheetController = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blueGrey,

      appBar: AppBar(
        title: _newPoint == true ? Text("New Item") : Text("Update Item"),
      ),
      body:
//        InkWell(
//          child: ListView(
//            children: <Widget>[
//              _form,
//              _typeList,
//              Divider(
//                color: Colors.amber,
//                height: 12.0,
//                ),
//              _buttonRow,
//              _sumbmitBtn,
//            ],
//          ),
//
//          onTap: () {
//            print("tape on bodx");
//          },
//        )
      ListView(
        children: <Widget>[
          _form,
          _typeList,
          Divider(
            color: Colors.amber,
            height: 12.0,
          ),
          _buttonRow,
          Divider(),
          _sumbmitBtn,
        ],
      ),
    );
  }

  /// Form Widget
  Widget get _form {
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: _formEdgeInsets,
            child: TextFormField(
              style: _formTextStyle,
              controller: _formItemNameController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: _formInputDecoration,
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a name";
                }
              },
            )
          ),
          Padding(
            padding: _formEdgeInsets,
            child: TextFormField(
              style: _formTextStyle,
              controller: _formItemDescriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: _formTextStyle,
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter description";
                }
              },
              maxLines: null,

            ),
          ),
          Padding(
            padding: _formEdgeInsets,
            child: TextFormField(
              style: _formTextStyle,
              controller: _formItemLocationController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: _formTextStyle,
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a location description.";
                }
              },
            )
          ),
//          Padding(
//            padding: _formEdgeInsets,
//            child: CheckboxListTile(
//                title: const Text("Nature"),
//                value: type["Nature"],
//                onChanged: (val) {
//                  setState(() =>
//                  type["Nature"] = val);
//                  }
//            ),
//          ),

        ],
      ),
    );

  }

  Widget get _typeList {
      return ListTile(
        leading: Text("Type", style: _formTextStyle,),
        title: Text(_selectedTypes, style: _formTextStyle,),

        trailing: IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: showTypes,
        ),
      );
  }


  Widget get _imageBtn {
    return RaisedButton.icon(
        onPressed: getImage,
        icon: Icon(Icons.image),
        label: Text("Add Image"),
    );
  }

  Widget get _cameraBtn {
    return RaisedButton.icon(
      onPressed: getCamera,
      icon: Icon(Icons.camera),
      label: Text("Take Picture"),
    );
  }

  Widget get _buttonRow {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _imageBtn,
        _cameraBtn,
      ],
    );
  }


  Widget get _sumbmitBtn {
    return Padding(
      padding: _formEdgeInsets,
      child: FlatButton(
          onPressed: submitForm,
          child: Text("Submit"),
          color: Colors.white,
      ),
    );
//    return FlatButton(
//      color: Colors.white70,
//      child: Text("Submit"),
//      onPressed: submitForm,
//    );
  }

  ScaffoldFeatureController _bottomSheet;
  var bottomSheet;
//  void openTypes() {
//    _bottomSheet = _scaffoldKey.currentState.showBottomSheet((_) {
//      return Container(
//        constraints: BoxConstraints.loose(Size(double.infinity, 240.0)),
//        color: Colors.amber,
//      );
//
//    });
//  }
  openTypes() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints.loose(Size(double.infinity, 240.0)),
            color: Colors.amber,
            child: ListView.builder(
                itemCount: _typesList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_typesList[index]),
                    value: _typesState[index],
                    onChanged: (val) {
                      bottomSheetEvent(index, context);
                      //setState(() {});
                      setState(() {});
                    },
                  );
                }),
          ) ;
        }
    );

  }

  Widget get _types {
    return Container(
      padding: EdgeInsets.all(0.0),
      constraints: BoxConstraints.loose(Size(double.infinity, double.infinity)),
      color: Colors.white10,

      child: Container(
        constraints: BoxConstraints.loose(Size(double.infinity, 240.0)),
        color: Colors.amber,
        child: ListView.builder(
            itemCount: _typesList.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(_typesList[index]),
                value: _typesState[index],
                onChanged: (val) {
                  bottomSheetEvent(index, context);
                  setState(() { });
                },
              );
            }),
      )

    );
  }
}