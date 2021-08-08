import 'package:flutter/material.dart';
import 'timeline_data.dart';
import 'timeline_track.dart';

class TimelineEvents extends StatefulWidget {
  late final List<TimelineTrack> tracks;

  TimelineEvents.sample(int lineCount, {Key? key}) : super(key: key) {
    tracks =
        List<TimelineTrack>.generate(lineCount, (i) => TimelineTrack.sample());
  }

  TimelineEvents.empty(int lineCount, {Key? key}) : super(key: key) {
    tracks = List<TimelineTrack>.generate(lineCount, (i) => TimelineTrack());
  }

  @override
  TimelineEventsState createState() => TimelineEventsState(tracks);
}

class TimelineEventsState extends State<TimelineEvents>
    implements TimelineDataFactry {
  late final List<TimelineTrack> tracks;
  final Map<TimelineTrack, TimelineTrackState> _trackStates = {};

  final _scrollController = ScrollController();

  TimelineEventsState(this.tracks);

  ScrollController get scrollController => _scrollController;

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
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tracks
                    .map(
                      (e) => Container(
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
              width: constraints.maxWidth-150,
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
