import 'package:flutter/material.dart';
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
    return TimelineEvents._(tracks, end, 30, key);
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
  final Map<TimelineTrack, TimelineTrackState> _trackStates = {};
  final _scrollController = ScrollController();
  double _trackHeight;
  TimelinePosition _trackEnd;
  double _widthUnit = 100;
  double _headerWidth = 150;

  TimelineEventsState(this.tracks, this._trackEnd, this._trackHeight);

  ScrollController get scrollController => _scrollController;
  double get trackHeight => _trackHeight;
  TimelinePosition get trackEnd => _trackEnd;
  double get widthUnit => _widthUnit;
  double get headerWidth => _headerWidth;

  set trackEnd(TimelinePosition value) {
    setState(() {
      _trackEnd = value;
    });
  }

  void initTrack(TimelineTrackState trackState) {
    var w = trackState.widget;
    _trackStates[w] = trackState;
  }

  void doAllTrack(void function(TimelineTrackState state)) {
    for (var e in _trackStates.values) {
      function(e);
    }
  }

  void add(TimelineTrack track) {
    setState(() {
      tracks.add(track);
    });
  }

  void remove(TimelineTrack track) {
    setState(() {
      _trackStates.remove(track);
      tracks.remove(track);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, BoxConstraints constraints) {
        return Row(
          children: [
            Container(
              width: _headerWidth,
              child: Column(
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
            ),
            Container(
              width: constraints.maxWidth - _headerWidth,
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
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
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  List<List<TimelineElementData>> getDatas() {
    return _trackStates.values.map((value) => value.getDatas()[0]).toList();
  }
}
