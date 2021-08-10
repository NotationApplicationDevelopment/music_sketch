import 'package:flutter/material.dart';
import 'timeline_events.dart';

class TimelineScale extends StatefulWidget {
  final int subSplit;
  final Color? color;
  final bool isBack;
  TimelineScale({
    this.isBack = false,
    this.subSplit = 4,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  _TimelineScaleState createState() =>
      _TimelineScaleState(isBack, subSplit, color ?? Colors.black);
}

class _TimelineScaleState extends State<TimelineScale> {
  TimelineEventsState? eventsState;
  bool _isBack;
  int _subSplit;
  Color _color;

  _TimelineScaleState(this._isBack, this._subSplit, this._color);

  @override
  Widget build(BuildContext context) {
    eventsState = context.findAncestorStateOfType<TimelineEventsState>();

    var widthUnit = eventsState?.widthUnit ?? 100;

    var cont = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;
        Color color = Color.fromARGB(
          _isBack ? _color.alpha ~/ 4 : _color.alpha,
          _color.red,
          _color.green,
          _color.blue,
        );
        var subLine = Container(width: 1, height: height, color: color);

        Widget mainLine(int index) {
          Widget mainLine;
          if (_isBack) {
            mainLine = Container(width: 3, height: height, color: color);
          } else {
            mainLine = Container(
              height: height,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 3, color: color),
                ),
              ),
              child: Text(
                " ${index + 1}",
                style: TextStyle(color: _color),
              ),
            );
          }
          return mainLine;
        }

        return Stack(
          children: List.generate(
            (_subSplit * width / widthUnit).floor() + 1,
            (index) {
              Widget w = (index % _subSplit == 0)
                  ? mainLine(index ~/ _subSplit)
                  : subLine;
              return Positioned(left: index * widthUnit / _subSplit, child: w);
            },
          ),
        );
      },
    );

    if (_isBack) {
      return cont;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: cont,
      onDoubleTap: () {
        eventsState = context.findAncestorStateOfType<TimelineEventsState>();
        if (eventsState != null) {
          eventsState!.doAllElement((state) {
            state.setState(() {
              state.isSelected = false;
            });
          });
        }
      },
      onLongPressStart: (detail) {
        eventsState = context.findAncestorStateOfType<TimelineEventsState>();
        if (eventsState != null) {
          for (var track in eventsState!.trackStates.values) {
            track.onLongPressStart(detail);
          }
        }
      },
      onLongPressMoveUpdate: (detail) {
        if (eventsState != null) {
          for (var track in eventsState!.trackStates.values) {
            track.onLongPressMoveUpdate(detail);
          }
        }
      },
      onLongPressEnd: (detail) {
        if (eventsState != null) {
          for (var track in eventsState!.trackStates.values) {
            track.onLongPressEnd(detail);
          }
        }
      },
    );
  }
}
