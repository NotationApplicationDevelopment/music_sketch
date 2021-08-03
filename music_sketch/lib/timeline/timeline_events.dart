import 'package:flutter/material.dart';
import 'timeline_data.dart';
import 'timeline_track.dart';

class TimelineEvents<T> extends StatelessWidget  implements  TimelineDataFactry<T> {
  late final List<TimelineTrack<T>> lines;

  TimelineEvents.test(int lineCount, {Key? key}) : super(key: key) {
    lines =
        List<TimelineTrack<T>>.generate(lineCount, (i) => TimelineTrack<T>.test());
  }

  TimelineEvents.empty(int lineCount, {Key? key}) : super(key: key) {
    lines =
        List<TimelineTrack<T>>.generate(lineCount, (i) => TimelineTrack<T>.empty());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lines,
    );
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    var d = lines.map((e)=> e.getDatas()[0]).toList();
    return d;
  }
}
