import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_sketch/timeline/timeline_data.dart';
import 'package:music_sketch/timeline/timeline_events.dart';
import 'package:music_sketch/timeline/timeline_times.dart';

class TimelineTrack extends StatefulWidget {
  final String trackName;
  const TimelineTrack({Key? key, required this.trackName}) : super(key: key);

  @override
  TimelineTrackState createState() => TimelineTrackState();
}

class TimelineTrackState extends State<TimelineTrack> {
  String get trackName => widget.trackName;

  Widget testElement(
      TimelineEventsEditor editor, TimelineElementData data, bool isSelected) {
    var deco1 = BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.red.shade900, width: 2),
      color: Colors.red,
    );

    var deco2 = BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Colors.redAccent.shade200, width: 2),
      color: Colors.redAccent.shade100,
    );

    return Padding(
      key: ValueKey(data),
      padding: EdgeInsets.only(
        left: data.positionRange.start.position * editor.unitWidth,
      ),
      child: GestureDetector(
        onTapDown: (detail) {
          setState(() {
            editor.setSelectedOfElement(trackName, data, true);
            editor.edited(trackName: trackName);
          });
        },
        onLongPress: () {
          setState(() {
            editor.setSelectedOfElement(trackName, data, false);
            editor.edited(trackName: trackName);
          });
        },
        onHorizontalDragUpdate: (detail) {
          editor.doAllSelectedElement((elementData, trackName, isSelected) {
            editor.getTrack(trackName)?.setState(() {
              elementData.positionRange = elementData.positionRange.shifted(
                TimelineRange.fromRange(detail.delta.dx / editor.unitWidth),
              );
              editor.edited(trackName: trackName);
            });
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: isSelected ? deco2 : deco1,
              width: data.positionRange.range.range * editor.unitWidth,
              height: 10,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build $trackName");
    var events = TimelineEventsEditor.of(
      context,
      TimelineEventsEditInfo(
        updateWith: {},
        trackName: trackName,
      ),
    );

    assert(events != null);

    events!.registerTrack(this);

    List<Widget> _selectedElements = [];
    List<Widget> _notSelectedElements = [];

    events.doAllElementOfTrack(
      trackName,
      (elementData, trackName, isSelected) {
        _selectedElements.add(
          testElement(events, elementData, isSelected),
        );
      },
    );

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[const _TrackResizer()] +
          _notSelectedElements +
          _selectedElements,
    );
  }
}

class _TrackResizer extends StatelessWidget {
  const _TrackResizer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var events = TimelineEventsEditor.of(
      context,
      TimelineEventsEditInfo(
        updateWith: {
          TimelineEventsUpdateWith.trackHeight,
          TimelineEventsUpdateWith.unitWidth,
          TimelineEventsUpdateWith.trackEnd,
        },
      ),
    );
    assert(events != null);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: SizedBox(
        width: events!.trackWidth,
        height: events.trackHeight,
      ),
    );
  }
}
