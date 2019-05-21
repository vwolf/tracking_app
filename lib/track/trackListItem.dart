import 'dart:async';

import 'package:flutter/material.dart';

import 'itemLayoutSizeChangeNotifier.dart';


class TrackListItem extends StatefulWidget {

  final List<ActionItems> items;
  final Widget child;
  final Color backgroundColor;

  TrackListItem({
    Key key,
    @required this.items,
    @required this.child,
    this.backgroundColor
  }) : super(key: key);

  @override
  _TrackListItemState createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> {

  ScrollController controller = ScrollController();
  bool isOpen = false;
  Size childSize;

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _handleScrollNotification(null);
    super.dispose();
  }


  void microTaskDone() {
    print("microtask done");
  }

  bool _handleScrollNotification(dynamic notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels >= (widget.items.length * 70.0) / 2
          && notification.metrics.pixels < widget.items.length * 70.0) {
        scheduleMicrotask(() {
          controller.animateTo(widget.items.length * 80.0,
              duration: new Duration(milliseconds: 600),
              curve: Curves.decelerate);
              isOpen = true;
        });

      } else if (notification.metrics.pixels > 0.0 && notification.metrics.pixels < (widget.items.length * 70.0) / 2) {
        scheduleMicrotask(() {
          print("_handleScrollNotification(notification) to 0.0");
          controller.animateTo(0.0, duration: new Duration(milliseconds: 600), curve: Curves.decelerate);
          isOpen = false;
        });
      }
    }
    return true;
  }

  /// ToDo controller.jumpTo is used to reset item - there should be a feddback
  @override void didUpdateWidget(TrackListItem oldWidget) {
    print('trackListItem didUpdateWidget & childSize: $childSize');
    controller.animateTo(0.0, duration: new Duration(milliseconds: 1), curve: Curves.decelerate);
    //controller.jumpTo(2.0);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if(childSize == null) {
      return NotificationListener(
          child: ItemLayoutSizeChangeNotifier(
            child: widget.child,
          ),
        onNotification: (ItemLayoutSizeChangeNotification notification ) {
            childSize = notification.newSize;
            scheduleMicrotask(() {
              setState(() { });
            });
            print(childSize);
        },
      );
    }


    List<Widget> above = <Widget>[Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: widget.child,

    ),];

    List<Widget> under = <Widget>[];
    for (ActionItems item in widget.items) {
      under.add(
        Container(
          alignment: Alignment.center,
          color: widget.backgroundColor,
          width: 80.0,
          height: childSize.height,
          child: item.icon,
        )
      );

      above.add(
        InkWell(
          child: Container(
            alignment: Alignment.center,
            width: 80.0,
            height: childSize.height,
          ),
          onTap: () {
            controller.jumpTo(2.0);
            item.onPress();
          },
        )
      );
    }

    Widget items = Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: under,
      ),
    );

    Widget scrollView = new NotificationListener(
      child: new ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: above,
      ),
      onNotification: _handleScrollNotification,
    );

    return new Stack(
      children: <Widget>[
        items,
        new Positioned(child: scrollView, left: 0.0, bottom: 0.0, right: 0.0, top: 0.0,)
      ],
    );
  }

}



/// ActionItems used by slideable item
class ActionItems extends Object {
  ActionItems(
      {@required this.icon,
        @required this.onPress,
        this.backgroundColor: Colors.blueAccent}) {
    assert(icon != null);
    assert(onPress != null);
  }

  final Widget icon;
  final VoidCallback onPress;
  final Color backgroundColor;
}
