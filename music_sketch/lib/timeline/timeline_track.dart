import 'package:flutter/material.dart';
import 'timeline_element.dart';
import 'timeline_times.dart';

class TimelineTrack extends StatelessWidget {
  late final List<TimelineElement> elements;

  factory TimelineTrack.test() {
    var key1 = GlobalKey<TimelineElementState>();
    var key2 = GlobalKey<TimelineElementState>();
    var key3 = GlobalKey<TimelineElementState>();

    var elements = [
      TimelineElement(
        TimelinePositionRange(TimelinePosition.fromPosition(1),
            TimelinePosition.fromPosition(2.5)),
        stateKey: key1,
        nextKey: key2,
      ),
      TimelineElement(
        TimelinePositionRange(
            TimelinePosition.fromPosition(4), TimelinePosition.fromPosition(7)),
        prevKey: key1,
        stateKey: key2,
        nextKey: key3,
      ),
      TimelineElement(
        TimelinePositionRange(TimelinePosition.fromPosition(7),
            TimelinePosition.fromPosition(10)),
        prevKey: key2,
        stateKey: key3,
      ),
    ];

    return TimelineTrack(elements);
  }

  TimelineTrack.empty({Key? key}) : this([], key: key);
  TimelineTrack(this.elements, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Row(children: elements));
  }
}
