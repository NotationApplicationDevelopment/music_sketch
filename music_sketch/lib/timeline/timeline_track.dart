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
  DateTime _beforeTaped = DateTime.utc(0);
  TimelineTrackState(this._elements);

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
    if (_eventsState == null) {
      for (var e in _elementStates.values) {
        function(e);
      }
    } else {
      _eventsState!.doAllTrack((state) {
        for (var e in state._elementStates.values) {
          function(e);
        }
      });
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

  @override
  Widget build(BuildContext context) {
    _eventsState = context.findAncestorStateOfType<TimelineEventsState>();
    _eventsState?.initTrack(this);
    var cont = Container(
      constraints: BoxConstraints(minHeight: 10),
      child: Stack(
        children: _elements.length > 0 ? _elements : [Text("Empty Track.")],
      ),
    );

    var gest = GestureDetector(
      child: Container(),
      behavior: HitTestBehavior.translucent,
      onTapDown: (detail) {
        _beforeTaped = DateTime.now();
      },
      onTapUp: (detail) {
        var now = DateTime.now();
        if (now.isBefore(_beforeTaped.add(Duration(milliseconds: 250)))) {
          var pos = detail.localPosition.dx / (_eventsState?.widthUnit ?? 100);
          var element = TimelineElement(
            positionRange: TimelinePositionRange.fromRange(
              TimelinePosition.fromPosition(pos),
              TimelineRange.fromRange(0.5),
            ),
          );
          add(element);
        }
      },
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
