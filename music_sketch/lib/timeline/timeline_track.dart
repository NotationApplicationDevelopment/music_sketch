import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_sketch/timeline/timeline_data.dart';
import 'package:music_sketch/timeline/timeline_events.dart';
import 'timeline_element.dart';
import 'timeline_times.dart';
import 'timeline_track_header.dart';

class TimelineTrack extends StatefulWidget {
  final String trackName;
  late final List<TimelineElement> elements;
  late final TimelineTrackHeader? header;
  factory TimelineTrack.sample(String trackName) {
    var elements = [
      TimelineElement(
        elementData: TimelineElementData(
          TimelinePositionRange(
            TimelinePosition.fromPosition(1),
            TimelinePosition.fromPosition(1.5),
          ),
          null,
        ),
      ),
      TimelineElement(
        elementData: TimelineElementData(
          TimelinePositionRange(
            TimelinePosition.fromPosition(2),
            TimelinePosition.fromPosition(2.25),
          ),
          null,
        ),
      ),
      TimelineElement(
        elementData: TimelineElementData(
          TimelinePositionRange(
            TimelinePosition.fromPosition(2.5),
            TimelinePosition.fromPosition(2.75),
          ),
          null,
        ),
      ),
    ];
    var key = GlobalKey<TimelineTrackState>();
    return TimelineTrack(
      key: key,
      elements: elements,
      trackName: trackName,
      header: TimelineTrackHeader(
        icon: Icon(Icons.audiotrack),
        text: Text(trackName),
        additional: ElevatedButton(
          child: const Text("additional widget"),
          onPressed: () {},
        ),
      ),
    );
  }

  TimelineTrack({
    required this.trackName,
    List<TimelineElement>? elements,
    this.header,
    Key? key,
  }) : super(key: key) {
    this.elements = elements ?? [];
  }

  @override
  TimelineTrackState createState() => TimelineTrackState();
}

class TimelineTrackState extends State<TimelineTrack> {
  String get trackName => widget.trackName;
  List<TimelineElement> get _elements => widget.elements;

  TimelineEventsState? _eventsState;
  final Map<TimelineElement, TimelineElementState> elementStates = {};
  DateTime _beforeTapDown = DateTime.utc(0);
  TimelinePosition _trackEnd = TimelinePosition.fromPosition(100);
  TimelinePositionRange? _selectAreaValue;

  double get unitWidth => _eventsState?.unitWidth ?? 100;
  TimelinePosition get trackEnd => _eventsState?.trackEnd ?? _trackEnd;
  double get trackWidth => unitWidth * trackEnd.position;
  double get trackHeight => _eventsState?.trackHeight ?? 30;
  set trackEnd(TimelinePosition value) {
    _trackEnd = value;
    _eventsState?.trackEnd = value;
  }

  Future<void> expanding(double min, int length) async {
    if (_eventsState != null) {
      await _eventsState!.expanding(min, length);
    }else{
      trackEnd = TimelinePosition.fromPosition(min);
    }
  }

  void initElement(TimelineElementState elementState) {
    elementStates[elementState.widget] = elementState;
  }

  void setTopElement(TimelineElementState elementState) {
    var w = elementState.widget;
    var index = _elements.indexOf(w);
    if (index >= 0 && index < _elements.length - 1)
      setState(() {
        _elements.removeAt(index);
        _elements.add(w);
      });
  }

  void doAllElement(void function(TimelineElementState elementState)) {
    for (var e in elementStates.values) {
      function(e);
    }
  }

  void doAllElementInEvents(void function(TimelineElementState elementState)) {
    _eventsState == null
        ? doAllElement(function)
        : _eventsState!.doAllElement(function);
  }

  void add(TimelineElement element) {
    setState(() {
      _elements.add(element);
    });
  }

  void remove(TimelineElement element) {
    setState(() {
      elementStates.remove(element);
      _elements.remove(element);
    });
  }

  void selectArea(TimelinePositionRange area) {
    for (var e in elementStates.values) {
      if (area.contain(e.positionRange)) {
        e.setState(() {
          e.isSelected = true;
        });
      }
    }
  }

  void onLongPressStart(Offset localPosition) {
    var pos = localPosition.dx / unitWidth;
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue == null) {
      _selectAreaValue = TimelinePositionRange(timePos, timePos);
    }
  }

  void onLongPressMoveUpdate(Offset localPosition) {
    var pos = localPosition.dx / unitWidth;
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue != null) {
      setState(() {
        _selectAreaValue =
            TimelinePositionRange(_selectAreaValue!.start, timePos);
      });
    }
  }

  void onLongPressEnd(Offset localPosition) {
    var pos = localPosition.dx / unitWidth;
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue != null) {
      var area = TimelinePositionRange(_selectAreaValue!.start, timePos);
      if (area.isNegative) {
        area = area.fliped();
      }
      selectArea(area);

      setState(() {
        _selectAreaValue = null;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventsState = context.findAncestorStateOfType<TimelineEventsState>();
    _eventsState?.initTrack(this);
  }

  @override
  Widget build(BuildContext context) {
    var unitWidth = this.unitWidth;
    var trackHeight = this.trackHeight;
    var list = <Widget>[];
    if (_selectAreaValue == null) {
      list = _elements
          .map(
            (e) => SizedBox(
              height: trackHeight,
              key: ValueKey(e.elementData),
              child: e,
            ),
          )
          .toList();
    } else {
      var zero = TimelinePosition.fromPosition(0);
      var area = _selectAreaValue!.isNegative
          ? _selectAreaValue!.fliped()
          : _selectAreaValue!;

      area = area.seted(
        start: area.start >= zero ? null : zero,
        end: area.end <= trackEnd ? null : trackEnd,
      );

      list = _elements
          .map<Widget>(
            (e) => SizedBox(
              height: trackHeight,
              key: ValueKey(e.elementData),
              child: e,
            ),
          )
          .toList();

      list.add(
        Padding(
          padding: EdgeInsets.only(left: area.start.position * unitWidth),
          child: SizedBox(
            height: trackHeight,
            width: area.range.range * unitWidth,
            child: const ColoredBox(color: const Color.fromARGB(50, 0, 0, 255)),
          ),
        ),
      );
    }

    Widget cont = Stack(
      children: list,
    );

    var gest = GestureDetector(
      child: SizedBox(
        width: trackWidth,
        height: trackHeight,
      ),
      behavior: HitTestBehavior.translucent,
      onTapDown: (detail) {
        _beforeTapDown = DateTime.now();
      },
      onTapUp: (detail) {
        var now = DateTime.now();
        var pos = detail.localPosition.dx / this.unitWidth;
        var timePos = TimelinePosition.fromPosition(pos);

        if (now.isBefore(_beforeTapDown.add(Duration(milliseconds: 250)))) {
          var element = TimelineElement(
            elementData: TimelineElementData(
              TimelinePositionRange.fromRange(
                timePos,
                TimelineRange.fromRange(0.25),
              ),
              null,
            ),
          );
          add(element);
        }
      },
      onLongPressStart: (d) => onLongPressStart(d.localPosition),
      onLongPressMoveUpdate: (d) => onLongPressMoveUpdate(d.localPosition),
      onLongPressEnd: (d) => onLongPressEnd(d.localPosition),
    );

    return Stack(
      children: [
        gest,
        cont,
      ],
    );
  }
}
