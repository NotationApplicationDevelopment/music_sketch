import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_sketch/timeline/timeline_events.dart';
import 'timeline_data.dart';
import 'timeline_element.dart';
import 'timeline_times.dart';
import 'timeline_track_header.dart';

class TimelineTrack extends StatefulWidget {
  late final List<TimelineElement> elements;
  late final TimelineTrackHeader header;
  factory TimelineTrack.sample() {
    var elements = [
      TimelineElement(
          positionRange: TimelinePositionRange(TimelinePosition.fromPosition(1),
              TimelinePosition.fromPosition(2.5))),
      TimelineElement(
        positionRange: TimelinePositionRange(
            TimelinePosition.fromPosition(4), TimelinePosition.fromPosition(7)),
      ),
      TimelineElement(
        positionRange: TimelinePositionRange(TimelinePosition.fromPosition(7),
            TimelinePosition.fromPosition(10)),
      ),
    ];

    return TimelineTrack(
      elements: elements,
      icon: Icon(Icons.audiotrack),
      trackName: const Text("tack name"),
      additionalInfo: ElevatedButton(
        child: const Text("additional widget"),
        onPressed: () {},
      ),
    );
  }

  TimelineTrack(
      {List<TimelineElement>? elements,
      Widget? icon,
      Text? trackName,
      Widget? additionalInfo,
      Key? key,
      Key? headerKey})
      : super(key: key) {
    this.elements = elements ?? [];
    header = TimelineTrackHeader(
        icon: icon,
        text: trackName,
        additional: additionalInfo,
        key: headerKey);
  }

  @override
  TimelineTrackState createState() => TimelineTrackState(elements);
}

class TimelineTrackState extends State<TimelineTrack>
    implements TimelineDataFactry {
  TimelineEventsState? _eventsState;
  final List<TimelineElement> _elements;
  final Map<TimelineElement, TimelineElementState> _elementStates = {};
  DateTime _beforeTapDown = DateTime.utc(0);
  DateTime _beforeTapUp = DateTime.utc(0);
  TimelineTrackState(this._elements);

  TimelinePositionRange? _selectAreaValue;

  TimelineEventsState? get eventsState => _eventsState;

  void initElement(TimelineElementState elementState) {
    var w = elementState.widget;
    _elementStates[w] = elementState;
  }

  void setTopElement(TimelineElementState elementState) {
    var w = elementState.widget;
    setState(() {
      _elements.remove(w);
      _elements.add(w);
    });
  }

  void doAllElement(void function(TimelineElementState elementState)) {
    for (var e in _elementStates.values) {
      function(e);
    }
  }

  void add(TimelineElement element) {
    setState(() {
      _elements.add(element);
    });
  }

  void remove(TimelineElement element) {
    setState(() {
      _elementStates.remove(element);
      _elements.remove(element);
    });
  }

  void selectArea(TimelinePositionRange area) {
    for (var e in _elementStates.values) {
      if (area.contain(e.positionRange)) {
        e.setState(() {
          e.isSelected = true;
        });
      }
    }
  }

  void onLongPressStart(LongPressStartDetails detail) {
    var pos = detail.localPosition.dx / (_eventsState?.widthUnit ?? 100);
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue == null) {
      _selectAreaValue = TimelinePositionRange(timePos, timePos);
    }
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails detail) {
    var pos = detail.localPosition.dx / (_eventsState?.widthUnit ?? 100);
    var timePos = TimelinePosition.fromPosition(pos);
    if (_selectAreaValue != null) {
      setState(() {
        _selectAreaValue =
            TimelinePositionRange(_selectAreaValue!.start, timePos);
      });
    }
  }

  void onLongPressEnd(LongPressEndDetails detail) {
    var pos = detail.localPosition.dx / (_eventsState?.widthUnit ?? 100);
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
      if (area.start.position < 0) {
        area = TimelinePositionRange(TimelinePosition.fromPosition(0) , area.end);
      }
      if (_eventsState!= null && area.end > _eventsState!.trackEnd) {
        area = TimelinePositionRange(area.start, _eventsState!.trackEnd);
      }
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
        var pos = detail.localPosition.dx / (_eventsState?.widthUnit ?? 100);
        var timePos = TimelinePosition.fromPosition(pos);
        _beforeTapUp = now;
        if (now.isBefore(_beforeTapDown.add(Duration(milliseconds: 250)))) {
          var element = TimelineElement(
            positionRange: TimelinePositionRange.fromRange(
              timePos,
              TimelineRange.fromRange(0.5),
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

  @override
  List<List<TimelineElementData>> getDatas() {
    return [_elementStates.values.map((e) => e.getDatas()[0][0]).toList()];
  }
}
