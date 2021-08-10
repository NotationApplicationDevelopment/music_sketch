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
      (i) => TimelineTrack.sample("Track $i"),
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
  double _headerWidth = 100;
  bool _sideOpen = false;

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
      topHeaderHeight: 30,
      leftHeaderWidth: _headerWidth,
      topLeftHeader: () => Switch(value: _sideOpen, onChanged: (value){
        _sideOpen = value;
        if(value){
          setState(() {
            _trackHeight = 50;
            _widthUnit = 200;
            _headerWidth = 150;
          });
        }else{
          setState(() {
            _trackHeight = 20;
            _widthUnit = 50;
            _headerWidth = 50;
          });
        }
      }),
      topHeader: () => Container(
        width: _trackEnd.position * _widthUnit,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey),
          ),
        ),
        child: TimelineScale(),
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
      child: () => Container(
        width: _trackEnd.position * _widthUnit,
        height: _trackHeight * tracks.length,
        
        child: Stack(
          children: [
            TimelineScale(
              isBack: true,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tracks
                  .map(
                    (e) => Container(
                        width: _trackEnd.position * _widthUnit,
                        height: _trackHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black26),
                          ),
                        ),
                        child: e),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, List<TimelineElementData>> getDatas() {
    Map<String, List<TimelineElementData>> data = {};
    for (var track in trackStates.values) {
      var trackData = <TimelineElementData>[];
      for (var element in track.elementStates.values) {
        trackData.add(element.elementData);
      }
      data[track.trackName] = trackData;
    }
    return data;
  }
}
