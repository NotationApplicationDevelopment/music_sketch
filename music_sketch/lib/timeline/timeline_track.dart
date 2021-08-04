import 'package:flutter/material.dart';
import 'timeline_data.dart';
import 'timeline_element.dart';
import 'timeline_times.dart';

class TimelineTrack<T> extends StatelessWidget
    implements TimelineDataFactry<T> {
  late final List<TimelineElement<T>> elements;

  factory TimelineTrack.sample() {
    var key1 = GlobalKey<TimelineElementState<T>>();
    var key2 = GlobalKey<TimelineElementState<T>>();
    var key3 = GlobalKey<TimelineElementState<T>>();

    var elements = [
      TimelineElement<T>(
        TimelinePositionRange(TimelinePosition.fromPosition(1),
            TimelinePosition.fromPosition(2.5)),
        key1,
        nextKey: key2,
      ),
      TimelineElement<T>(
        TimelinePositionRange(
            TimelinePosition.fromPosition(4), TimelinePosition.fromPosition(7)),
        key2,
        prevKey: key1,
        nextKey: key3,
      ),
      TimelineElement<T>(
        TimelinePositionRange(TimelinePosition.fromPosition(7),
            TimelinePosition.fromPosition(10)),
        key3,
        prevKey: key2,
      ),
    ];

    return TimelineTrack<T>(elements);
  }

  TimelineTrack.empty({Key? key}) : this([], key: key);
  TimelineTrack(this.elements, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Row(children: elements));
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    var d = elements
        .map((e) => e.stateKey!.currentState!.getDatas()[0][0])
        .toList();
    return [d];
  }
}
