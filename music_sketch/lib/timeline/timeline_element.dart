import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'timeline_data.dart';
import 'timeline_times.dart';

class TimelineElement<T> extends StatefulWidget {
  final TimelinePositionRange positionRange;
  final GlobalKey<TimelineElementState<T>>? stateKey;
  final GlobalKey<TimelineElementState<T>>? nextKey;
  final GlobalKey<TimelineElementState<T>>? prevKey;
  TimelineElement(this.positionRange, this.stateKey,
      {this.nextKey, this.prevKey})
      : super(key: stateKey);

  @override
  TimelineElementState createState() =>
      TimelineElementState(positionRange, nextKey: nextKey, prevKey: prevKey);
}

class TimelineElementState<T> extends State<TimelineElement<T>>
    implements TimelineDataFactry<T> {
  late TimelinePositionRange _positionRange;
  late final TimelineElementData<T> _elementData;
  late double _width;
  late double _space;
  double _widthUnit = 100;
  GlobalKey<TimelineElementState>? nextKey;
  GlobalKey<TimelineElementState>? prevKey;

  TimelineElementState? get _next => nextKey?.currentState;
  TimelineElementState? get _prev => prevKey?.currentState;
  T? get additionalInfo => _elementData.info;
  set additionalInfo(T? value) {
    _elementData.info = value;
  }

  TimelineElementState(TimelinePositionRange positionRange,
      {GlobalKey<TimelineElementState>? prevKey,
      GlobalKey<TimelineElementState>? nextKey}) {
    this.prevKey = prevKey;
    this.nextKey = nextKey;
    _positionRange = positionRange;
    _elementData = TimelineElementData<T>(_positionRange, null);
    _positionRangeUpdate(setState: false);
  }

  void shift(TimelineRange shift) {
    if (shift.range > 0) {
      shift = _checkRight(shift)!;
    } else {
      shift = _checkLeft(shift)!;
    }
    _positionRange = _positionRange.shift(shift);
    _positionRangeUpdate();
    _next?._positionRangeUpdate();
  }

  void move({TimelineRange? start, TimelineRange? end}) {
    start = _checkLeft(start);
    end = _checkRight(end);
    _positionRange = _positionRange.move(start: start, end: end);
    _positionRangeUpdate();
    _next?._positionRangeUpdate();
  }

  void set({TimelinePosition? start, TimelinePosition? end}) {
    TimelineRange? sr, se;
    if (start != null) {
      sr = _positionRange.start.to(start);
    }
    if (end != null) {
      se = _positionRange.end.to(end);
    }
    move(start: sr, end: se);
  }

  TimelineRange? _checkLeft(TimelineRange? start) {
    if (start == null) {
      return null;
    }
    if (start.range > 0) {
      return start;
    }
    if (_prev != null) {
      var def = _positionRange.start.to(_prev!._positionRange.end);
      return start > def ? start : def;
    } else {
      return start;
    }
  }

  TimelineRange? _checkRight(TimelineRange? end) {
    if (end == null) {
      return null;
    }
    if (end.range < 0) {
      return end;
    }
    if (_next != null) {
      var def = _positionRange.end.to(_next!._positionRange.start);
      return end < def ? end : def;
    } else {
      return end;
    }
  }

  void _positionRangeUpdate({bool setState = true}) {
    void update() {
      if (_positionRange.isNegative) {
        _positionRange = _positionRange.flip();
      }

      _width = _widthUnit * _positionRange.range.range;
      if (_prev == null) {
        _space = _widthUnit * _positionRange.start.position;
      } else {
        _space = _widthUnit *
            _positionRange.start.from(_prev!._positionRange.end).range;
      }

      if (_space < 0) {
        shift(TimelineRange.fromRange(-_positionRange.start.position));
        update();
      }
      _elementData.positionRange = _positionRange;
    }

    if (setState) {
      this.setState(update);
    } else {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _space + _width,
      padding: const EdgeInsets.all(1),
      child: Row(
        children: [
          Container(
            width: _space,
            child: null,
          ),
          Container(
              color: Colors.red,
              width: _width - 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MyButton(() {
                    move(start: TimelineRange.fromRange(-0.5));
                  }, () {
                    move(start: TimelineRange.fromRange(0.5));
                  }),
                  _MyButton(() {
                    shift(TimelineRange.fromRange(-0.5));
                  }, () {
                    shift(TimelineRange.fromRange(0.5));
                  }),
                  _MyButton(() {
                    move(end: TimelineRange.fromRange(-0.5));
                  }, () {
                    move(end: TimelineRange.fromRange(0.5));
                  }),
                ],
              )),
        ],
      ),
    );
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    return [
      [_elementData]
    ];
  }
}

class _MyButton extends StatelessWidget {
  final VoidCallback onPressedL;
  final VoidCallback onPressedR;
  const _MyButton(this.onPressedL, this.onPressedR, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ButtonTheme(
            child: SizedBox(
          width: 20,
          child: MaterialButton(
              color: Colors.redAccent, onPressed: onPressedL, child: Text("<")),
        )),
        ButtonTheme(
            child: SizedBox(
          width: 20,
          child: MaterialButton(
              color: Colors.redAccent, onPressed: onPressedR, child: Text(">")),
        )),
      ],
    );
  }
}
