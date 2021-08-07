import 'package:flutter/material.dart';
import 'timeline_data.dart';
import 'timeline_track.dart';

class TimelineEvents<T> extends StatelessWidget
    implements TimelineDataFactry<T> {
  late final List<TimelineTrack<T>> lines;
  final Map<TimelineTrack<T>, TimelineTrackState<T>> trackState = {};

  TimelineEvents.sample(int lineCount, {Key? key}) : super(key: key) {
    lines = List<TimelineTrack<T>>.generate(
        lineCount, (i) => TimelineTrack<T>.sample());
  }

  TimelineEvents.empty(int lineCount, {Key? key}) : super(key: key) {
    lines =
        List<TimelineTrack<T>>.generate(lineCount, (i) => TimelineTrack<T>());
  }

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    trackState.clear();
    return FractionallySizedBox(
        widthFactor: 1.0,
        child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines),
            )));
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    return trackState.values.map((value) => value.getDatas()[0]).toList();
  }
}
