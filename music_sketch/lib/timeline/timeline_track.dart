import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'timeline_data.dart';
import 'timeline_element.dart';
import 'timeline_times.dart';

class TimelineTrack<T> extends StatefulWidget {
  late final List<TimelineElement<T>> elements;
  factory TimelineTrack.sample() {
    var elements = [
      TimelineElement<T>(
          positionRange: TimelinePositionRange(TimelinePosition.fromPosition(1),
              TimelinePosition.fromPosition(2.5))),
      TimelineElement<T>(
        positionRange: TimelinePositionRange(
            TimelinePosition.fromPosition(4), TimelinePosition.fromPosition(7)),
      ),
      TimelineElement<T>(
        positionRange: TimelinePositionRange(TimelinePosition.fromPosition(7),
            TimelinePosition.fromPosition(10)),
      ),
    ];

    return TimelineTrack<T>(elements: elements);
  }

  TimelineTrack.empty({Key? key}) : this(elements: [], key: key);

  TimelineTrack({List<TimelineElement<T>>? elements, Key? key})
      : super(key: key) {
    this.elements = elements ?? [];
  }

  @override
  TimelineTrackState<T> createState() => TimelineTrackState<T>(elements);
}

class TimelineTrackState<T> extends State<TimelineTrack<T>>
    implements TimelineDataFactry<T> {
  final List<TimelineElement<T>> elements;
  final Map<TimelineElement<T>, TimelineElementState<T>> _elementStates = {};
  TimelineTrackState(this.elements);

  void initElement(TimelineElementState<T> elementState) {
    var w = elementState.widget;
    _elementStates[w] = elementState;
  }

  void setTopElement(TimelineElementState<T> elementState) {
    var w = elementState.widget;
    setState(() {
      elements.remove(w);
      elements.add(w);
    });
  }

  void doAllElement(void function(TimelineElementState<T> elementState)) {
    for (var e in _elementStates.values) {
      function(e);
    }
  }

  void add(TimelineElement<T> element) {
    setState(() {
      elements.add(element);
    });
  }

  void remove(TimelineElement<T> element) {
    setState(() {
      _elementStates.remove(element);
      elements.remove(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      height: 30,
      child: Stack(children: elements.length > 0 ? elements : [Text("Empty")]),
    );
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    return [_elementStates.values.map((e) => e.getDatas()[0][0]).toList()];
  }
}
