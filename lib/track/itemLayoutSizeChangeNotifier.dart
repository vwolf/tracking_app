import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef void SizeChangedCallBack(Size newSize);

/// LayoutChangedNotifictation to dispatch notifications whenever there is
/// a change in layout
class ItemLayoutSizeChangeNotification extends LayoutChangedNotification {
  ItemLayoutSizeChangeNotification(this.newSize) : super();
  Size newSize;
}

/// Notifier to listen that listens to the  notifications dispatched by
/// the widget
/// A widget that automatically dispatches a [SizeChangedLayoutNotification]
/// when the layout dimensions of its child change.
///
/// To listen for the notification dispatched by this widget, use a
/// [NotificationListener<SizeChangedLayoutNotification>].
///
/// The [Material] class listens for [LayoutChangedNotification]s, including
/// [SizeChangedLayoutNotification]s, to repaint [InkResponse] and [InkWell] ink
/// effects. When a widget is likely to change size, wrapping it in a
/// [SizeChangedLayoutNotifier] will cause the ink effects to correctly repaint
/// when the child changes size.
///
/// See also:
///
///  * [Notification], the base class for notifications that bubble through the
///    widget tree.
class ItemLayoutSizeChangeNotifier extends SingleChildRenderObjectWidget {
  const ItemLayoutSizeChangeNotifier({Key key, Widget child})
      : super(key: key, child: child);

  @override
  _SizeChangeRenderWithCallback createRenderObject(BuildContext context) {
    return new _SizeChangeRenderWithCallback(onLayoutChangedCallback: (size) {
      new ItemLayoutSizeChangeNotification(size).dispatch(context);
    });
  }
}

class _SizeChangeRenderWithCallback extends RenderProxyBox {
  _SizeChangeRenderWithCallback(
      {RenderBox child, @required this.onLayoutChangedCallback})
      : assert(onLayoutChangedCallback != null),
        super(child);

  final SizeChangedCallBack onLayoutChangedCallback;

  Size _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    // don't send the initial notification or this will be SizeObserver all over again
    if (size != _oldSize) onLayoutChangedCallback(size);
    _oldSize = size;
  }
}
