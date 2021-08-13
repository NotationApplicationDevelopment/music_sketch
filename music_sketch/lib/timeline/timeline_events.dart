import 'package:flutter/material.dart';
import 'package:music_sketch/timeline/multi_header_scroll_view.dart';
import 'package:music_sketch/timeline/timeline_element.dart';
import 'package:music_sketch/timeline/timeline_scale.dart';
import 'package:music_sketch/timeline/timeline_times.dart';
import 'timeline_data.dart';
import 'timeline_track.dart';

class TimelineEvents extends StatefulWidget {
  late final List<TimelineTrack> tracks;
  late final TimelinePosition trackEnd;
  final Map<TimelineTrack, TimelineTrackState> trackStates = {};

  factory TimelineEvents.sample(int lineCount, {Key? key}) {
    var tracks = List<TimelineTrack>.generate(
      lineCount,
      (i) => TimelineTrack.sample("Track $i"),
    );
    var end = TimelinePosition.fromPosition(30);
    return TimelineEvents._(tracks, end, key);
  }

  TimelineEvents._(this.tracks, this.trackEnd, Key? key) : super(key: key);

  @override
  TimelineEventsState createState() => TimelineEventsState();
}

class TimelineEventsState extends State<TimelineEvents>
    implements TimelineDataFactry {
  static const height_min = 20.0;
  static const height_max = 35.0;
  static const unit_min = 30.0;
  static const unit_max = 1000.0;
  List<TimelineTrack> get tracks => widget.tracks;
  Map<TimelineTrack, TimelineTrackState> get trackStates => widget.trackStates;
  late TimelinePosition _trackEnd;

  double _trackHeight = height_min + (height_max - height_min) * 0.5;
  double _widthUnit = unit_min + (unit_max - unit_min) * 0.5;
  double _headerWidth = 105;
  double _headerHeight = 40;
  double _zoom = 0.5;
  double _scaleStartZoom = 0.5;

  double get trackHeight => _trackHeight;
  double get unitWidth => _widthUnit;
  double get headerWidth => _headerWidth;
  double get zoom => _zoom;
  set zoom(double value) {
    _zoom = value.clamp(0.0, 1.0);

    setState(() {
      _widthUnit = unit_min + (unit_max - unit_min) * _zoom;
      _trackHeight = height_min + (height_max - height_min) * _zoom;
    });
    doAllTrack((state) {
      state.setState(() {});
      state.doAllElement((elementState) {
        elementState.setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _trackEnd = widget.trackEnd;
  }

  TimelinePosition get trackEnd => _trackEnd;
  set trackEnd(TimelinePosition value) {
    setState(() {
      this._trackEnd = value;
    });
    doAllTrack((state) {
      state.setState(() {});
    });
  }

  Future<void> expanding(double min, int length) async {
    await TimelineEventsExpanding.expandTrack(this.context, this, min, length);
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
    var width = trackEnd.position * _widthUnit;

    const underLine = const BoxDecoration(
      border: Border.fromBorderSide(
        BorderSide(
          width: 1,
          color: Colors.grey,
        ),
      ),
    );
    var size = MediaQuery.of(context).size;
    var whiteSpaceH = size.width * 0.5;
    var whiteSpaceV = size.height * 0.5;
    var view = MultiHeaderScrollView(
      topHeaderHeight: _headerHeight,
      leftHeaderWidth: _headerWidth,
      topLeftHeader: DecoratedBox(
        decoration: underLine,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              customBorder: const CircleBorder(
                side: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1),
                    color: _zoom == 0.0 ? Colors.grey : null),
                child: const SizedBox(
                  width: 25,
                  height: 25,
                  child: Icon(
                    Icons.zoom_out,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              onTap: _zoom == 0.0
                  ? null
                  : () {
                      zoom -= 0.05;
                    },
            ),
            InkWell(
              customBorder: const CircleBorder(
                side: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1),
                    color: _zoom == 1.0 ? Colors.grey : null),
                child: const SizedBox(
                  width: 25,
                  height: 25,
                  child: Icon(
                    Icons.zoom_in,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              onTap: _zoom == 1.0
                  ? null
                  : () {
                      zoom += 0.05;
                    },
            ),
          ],
        ),
      ),
      topHeader: SizedBox(
        width: width + whiteSpaceH,
        height: _headerHeight,
        child: DecoratedBox(
          decoration: underLine,
          child: TimelineScale(color: Colors.grey),
        ),
      ),
      leftHeader: SizedBox(
        height: _trackHeight * tracks.length + whiteSpaceV,
        width: headerWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tracks
              .map(
                (e) => SizedBox(
                  height: _trackHeight,
                  width: headerWidth,
                  child: DecoratedBox(
                    decoration: underLine,
                    child: e.header,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      child: SizedBox(
        width: width + whiteSpaceH,
        height: _trackHeight * tracks.length + whiteSpaceV,
        child: Stack(
          children: [
            SizedBox(
              width: width,
              height: _trackHeight * tracks.length,
              child: TimelineScale(isBack: true, color: Colors.grey),
            ),
            SizedBox(
              width: width + whiteSpaceH,
              height: _trackHeight * tracks.length + whiteSpaceV,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tracks
                    .map(
                      (e) => SizedBox(
                        width: width,
                        height: _trackHeight,
                        child: DecoratedBox(
                          decoration: underLine,
                          child: e,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      child: view,
      behavior: HitTestBehavior.translucent,
      onScaleStart: (detail) {
        _scaleStartZoom = zoom;
      },
      onScaleUpdate: (detail) {
        zoom = _scaleStartZoom * detail.scale;
      },
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

class TimelineEventsExpanding {
  static final Map<TimelineEventsState, TimelineEventsExpandingInfo> _states =
      {};
  static Future<void> expandTrack(
    BuildContext context,
    TimelineEventsState events,
    double min,
    int length,
  ) async {
    var info = _states[events];
    if (info == null) {
      info = TimelineEventsExpandingInfo(min, length, min, null);
      _states[events] = info;
      info.task = _show(context, events, info).then((_) {
        events.trackEnd = TimelinePosition.fromPosition(info!.value);
        _states.remove(events);
      });
      await info.task;
    } else {
      await Future.doWhile(() {
        if (info!.setState != null) {
          info.setState!.call(() {
            if (min > info!.min) {
              info.min = min;
            }
            info.length = length;
            info.value = info.value.clamp(info.min, info.min + info.length);
          });
          return false;
        }
        return Future.delayed(Duration(milliseconds: 4), () => true);
      });

      await info.task;
    }
  }

  static Future<void> _show(
    BuildContext context,
    TimelineEventsState events,
    TimelineEventsExpandingInfo info,
  ) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Expands the area."),
          content: Text("Expands the area, for the operation."),
          actions: <Widget>[
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                info.setState = setState;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            info.min.toInt().toString(),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            info.value.toString(),
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Text(
                            (info.min + info.length).toInt().toString(),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: info.value,
                              min: info.min,
                              max: info.min + info.length,
                              divisions: info.length,
                              onChanged: (e) {
                                setState(() {
                                  info.value = e;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }
}

class TimelineEventsExpandingInfo {
  double min;
  double value;
  int length;
  StateSetter? setState;
  Future<void>? task;
  TimelineEventsExpandingInfo(this.min, this.length, this.value, this.setState);
}
