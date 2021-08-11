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
  late final TimelineTrackHeader header;
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

    return TimelineTrack(
      elements: elements,
      trackName: trackName,
      icon: Icon(Icons.audiotrack),
      headerText: Text(trackName),
      additionalInfo: ElevatedButton(
        child: const Text("additional widget"),
        onPressed: () {},
      ),
    );
  }

  TimelineTrack(
      {required this.trackName,
      List<TimelineElement>? elements,
      Widget? icon,
      Text? headerText,
      Widget? additionalInfo,
      Key? key,
      Key? headerKey})
      : super(key: key) {
    this.elements = elements ?? [];
    header = TimelineTrackHeader(
        icon: icon,
        text: headerText,
        additional: additionalInfo,
        key: headerKey);
  }

  @override
  TimelineTrackState createState() => TimelineTrackState(elements, trackName);
}

class TimelineTrackState extends State<TimelineTrack> {
  final String trackName;
  TimelineEventsState? _eventsState;
  final List<TimelineElement> _elements;
  final Map<TimelineElement, TimelineElementState> elementStates = {};
  DateTime _beforeTapDown = DateTime.utc(0);
  TimelinePosition _trackEnd = TimelinePosition.fromPosition(100);

  TimelineTrackState(this._elements, this.trackName);

  TimelinePositionRange? _selectAreaValue;

  double get widthUnit => _eventsState?.widthUnit ?? 100;
  TimelinePosition get trackEnd => _eventsState?.trackEnd ?? _trackEnd;
  set trackEnd(TimelinePosition value) {
    _eventsState?.trackEnd = _trackEnd = value;
  }

  void initElement(TimelineElementState elementState) {
    var w = elementState.widget;
    elementStates[w] = elementState;
  }

  void setTopElement(TimelineElementState elementState) {
    var w = elementState.widget;
    setState(() {
      _elements.remove(w);
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

  void onLongPressStart(LongPressStartDetails detail) {
    var pos = detail.localPosition.dx / widthUnit;
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue == null) {
      _selectAreaValue = TimelinePositionRange(timePos, timePos);
    }
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails detail) {
    var pos = detail.localPosition.dx / widthUnit;
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue != null) {
      setState(() {
        _selectAreaValue =
            TimelinePositionRange(_selectAreaValue!.start, timePos);
      });
    }
  }

  void onLongPressEnd(LongPressEndDetails detail) {
    var pos = detail.localPosition.dx / widthUnit;
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
  Widget build(BuildContext context) {
    _eventsState = context.findAncestorStateOfType<TimelineEventsState>();
    _eventsState?.initTrack(this);
    Container cont;
    if (_selectAreaValue == null) {
      cont = Container(
        constraints: BoxConstraints(minHeight: 10),
        child: Stack(
          children: _elements,
        ),
      );
    } else {
      var area = _selectAreaValue!.isNegative
          ? _selectAreaValue!.fliped()
          : _selectAreaValue!;

      var zero = TimelinePosition.fromPosition(0);
      area = area.seted(
        start: area.start >= zero ? null : zero,
        end: area.end <= trackEnd ? null : trackEnd,
      );

      var widthUnit = _eventsState?.widthUnit ?? 100;
      cont = Container(
        constraints: BoxConstraints(minHeight: 10),
        child: Stack(
          children: _elements.cast<Widget>() +
              [
                Row(
                  children: [
                    Container(
                      width: area.start.position * widthUnit,
                    ),
                    Container(
                      color: Color.fromARGB(50, 0, 0, 255),
                      width: area.range.range * widthUnit,
                    ),
                  ],
                )
              ],
        ),
      );
    }

    var gest = GestureDetector(
      child: Container(),
      behavior: HitTestBehavior.translucent,
      onTapDown: (detail) {
        _beforeTapDown = DateTime.now();
      },
      onTapUp: (detail) {
        var now = DateTime.now();
        var pos = detail.localPosition.dx / widthUnit;
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
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressEnd: onLongPressEnd,
    );

    return Stack(
      children: [
        gest,
        cont,
      ],
    );
  }
}
