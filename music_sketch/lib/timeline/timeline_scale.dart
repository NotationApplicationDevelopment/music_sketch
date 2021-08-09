import 'package:flutter/material.dart';
import 'timeline_events.dart';

class TimelineScale extends StatefulWidget {
  final bool showCount;
  final int subSplit;
  final Color? color;
  TimelineScale({
    required this.showCount,
    this.subSplit = 4,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  _TimelineScaleState createState() =>
      _TimelineScaleState(showCount, subSplit, color ?? Colors.black);
}

class _TimelineScaleState extends State<TimelineScale> {
  bool _showCount;
  int _subSplit;
  Color _color;

  _TimelineScaleState(this._showCount, this._subSplit, this._color);

  @override
  Widget build(BuildContext context) {
    var eventsState = context.findAncestorStateOfType<TimelineEventsState>();

    var widthUnit = eventsState?.widthUnit ?? 100;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;

        var subLine = Container(width: 1, height: height, color: _color);

        Widget mainLine(int index) {
          Widget mainLine;
          if (_showCount) {
            mainLine = Container(
              height: height,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 3, color: _color),
                ),
              ),
              child: Text(
                " ${index+1}",
                style: TextStyle(color: _color),
              ),
            );
          } else {
            mainLine = Container(width: 3, height: height, color: _color);
          }
          return mainLine;
        }

        return Stack(
          children: List.generate(
            (_subSplit * width / widthUnit).floor() + 1,
            (index){ 
              Widget w = (index % _subSplit == 0) ?  mainLine(index~/_subSplit) : subLine;
              return Positioned(left: index * widthUnit / _subSplit, child: w);
            },
          ),
        );
      },
    );
  }
}
