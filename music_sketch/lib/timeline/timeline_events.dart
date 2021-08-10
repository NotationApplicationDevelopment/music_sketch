import 'package:flutter/material.dart';
import 'package:music_sketch/timeline/multi_header_scroll_view.dart';
import 'package:music_sketch/timeline/timeline_element.dart';
import 'package:music_sketch/timeline/timeline_scale.dart';
import 'package:music_sketch/timeline/timeline_times.dart';
import 'timeline_data.dart';
import 'timeline_track.dart';

class TimelineEvents extends StatefulWidget {
  late final List<TimelineTrack> tracks;
  late final double _trackHeight;
  late final TimelinePosition _trackEnd;

  factory TimelineEvents.sample(int lineCount, {Key? key}) {
    var tracks = List<TimelineTrack>.generate(
      lineCount,
      (i) => TimelineTrack.sample(),
    );
    var end = TimelinePosition.fromPosition(30);
    return TimelineEvents._(tracks, end, 40, key);
  }

  TimelineEvents._(this.tracks, this._trackEnd, this._trackHeight, Key? key)
      : super(key: key);

  @override
  TimelineEventsState createState() =>
      TimelineEventsState(tracks, _trackEnd, _trackHeight);
}

class TimelineEventsState extends State<TimelineEvents>
    implements TimelineDataFactry {
  late final List<TimelineTrack> tracks;
  final Map<TimelineTrack, TimelineTrackState> trackStates = {};

  double _trackHeight;
  TimelinePosition _trackEnd;
  double _widthUnit = 50;
  double _headerWidth = 50;

  TimelineEventsState(this.tracks, this._trackEnd, this._trackHeight);
  double get trackHeight => _trackHeight;
  TimelinePosition get trackEnd => _trackEnd;
  double get widthUnit => _widthUnit;
  double get headerWidth => _headerWidth;

  @override
  void initState() {
    super.initState();
  }

  set trackEnd(TimelinePosition value) {
    setState(() {
      _trackEnd = value;
    });
  }

  void initTrack(TimelineTrackState trackState) {
    var w = trackState.widget;
    trackStates[w] = trackState;
  }

  void doAllTrack(void function(TimelineTrackState state)) {
    for (var e in trackStates.values) {
      function(e);
    }
  }

  void doAllElement(void function(TimelineElementState state)) {
    for (var e in trackStates.values) {
      e.doAllElement(function);
    }
  }

  void add(TimelineTrack track) {
    setState(() {
      tracks.add(track);
    });
  }

  void remove(TimelineTrack track) {
    setState(() {
      trackStates.remove(track);
      tracks.remove(track);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiHeaderScrollView(
      topHeaderHeight: _trackHeight,
      leftHeaderWidth: _headerWidth,
      topLeftHeader: () => Text((_trackEnd.position * _widthUnit).toString()),
      topHeader: () => Container(
        width: _trackEnd.position * _widthUnit,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
        ),
        child: TimelineScale(
          showCount: true,
        ),
      ),
      leftHeader: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tracks
            .map(
              (e) => Container(
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black26),
                    ),
                  ),
                  child: e.header),
            )
            .toList(),
      ),
      child: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tracks
            .map(
              (e) => Container(
                  height: _trackHeight,
                  width: _trackEnd.position * _widthUnit,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black26),
                    ),
                  ),
                  child: e),
            )
            .toList(),
      ),
    );
  }

  @override
  List<List<TimelineElementData>> getDatas() {
    return trackStates.values.map((value) => value.getDatas()[0]).toList();
  }
}
