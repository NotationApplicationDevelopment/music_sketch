import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'timeline_times.dart';

class TimelineElement extends StatefulWidget {
  final TimelinePositionRange positionRange;
  TimelineElement(this.positionRange, {Key? key}) : super(key: key);

  @override
  _TimelineElementState createState() => _TimelineElementState(positionRange);
}

class _TimelineElementState extends State<TimelineElement> {
  late TimelinePositionRange _positionRange;
  late double _width;
  late double _tempSpace;
  double _widthUnit = 100;

  _TimelineElementState(TimelinePositionRange positionRange) {
    if (positionRange.isNegative) {
      _positionRange = positionRange.flip();
    } else {
      _positionRange = positionRange;
    }
    _width = _widthUnit * _positionRange.range.range;
    _tempSpace = _widthUnit * positionRange.start.position;
  }

  void shift(TimelineRange shift) {
    _positionRange = _positionRange.shift(shift);
  }

  void move({TimelineRange? start, TimelineRange? end}) {
    _positionRange = _positionRange.move(start: start, end: end);
    _flip();
    _sizeUpdate();
  }

  void set({TimelinePosition? start, TimelinePosition? end}) {
    _positionRange = _positionRange.set(start: start, end: end);
    _flip();
  }

  void _flip() {
    if (_positionRange.isNegative) {
      _positionRange = _positionRange.flip();
    }
  }

  void _sizeUpdate() {
    setState(() {
      _width = _widthUnit * _positionRange.range.range;
      _tempSpace = _widthUnit * _positionRange.start.position;
      if (_tempSpace < 0) {
        _tempSpace = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: Row(
        children: [
          Container(
            width: _tempSpace,
            child: null,
          ),
          ElevatedButton(
              onPressed: () => {move(start: TimelineRange.fromRange(-0.5))},
              child: Text("<")),
          ElevatedButton(
              onPressed: () => {move(start: TimelineRange.fromRange(0.5))},
              child: Text(">")),
          Container(
            color: Colors.redAccent,
            width: _width,
            child:
                Text("Element", style: Theme.of(context).textTheme.headline4),
          ),
          ElevatedButton(
              onPressed: () => {move(end: TimelineRange.fromRange(-0.5))},
              child: Text("<")),
          ElevatedButton(
              onPressed: () => {move(end: TimelineRange.fromRange(0.5))},
              child: Text(">")),
        ],
      ),
    );
  }
}
