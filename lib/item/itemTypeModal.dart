import 'package:flutter/material.dart';


class ItemTypeModal extends StatefulWidget {

  final List<String> types;
  final List<bool> typesState;
  final selectType;

  ItemTypeModal(this.types, this.typesState, this.selectType);

  _ItemTypeModalState createState() => _ItemTypeModalState();
}

class _ItemTypeModalState extends State<ItemTypeModal> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        constraints: BoxConstraints.loose(Size(double.infinity, 240.0)),
        color: Colors.amber,
      child: ListView.builder(
        itemCount: widget.types.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(widget.types[index]),
            value: widget.typesState[index],
            onChanged: (val) {
              widget.selectType(index);
              setState(() {});

            },
          );
        }),
    );
  }
}