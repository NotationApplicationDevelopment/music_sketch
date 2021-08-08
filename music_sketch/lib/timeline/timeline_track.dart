import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'timeline_data.dart';
import 'timeline_element.dart';
import 'timeline_times.dart';

class TimelineTrack<T> extends StatefulWidget {
  late final List<TimelineElement<T>> elements;
  final Widget? headerIcon;
  final Text? headerText;
  final Widget? headerAdditional;
  final Axis headerAxis;
  final double headerWidth;

  factory TimelineTrack.sample() {
    var elements = [
      TimelineElement<T>(
          positionRange: TimelinePositionRange(TimelinePosition.fromPosition(1),
              TimelinePosition.fromPosition(2.5))),
      TimelineElement<T>(
        positionRange: TimelinePositionRange(
            TimelinePosition.fromPosition(4), TimelinePosition.fromPosition(7)),
      ),
      TimelineElement<T>(
        positionRange: TimelinePositionRange(TimelinePosition.fromPosition(7),
            TimelinePosition.fromPosition(10)),
      ),
    ];

    return TimelineTrack<T>(
      elements: elements,
      headerIcon: Icon(Icons.audiotrack),
      headerText: Text("trackName"),
      headerAdditional: Text("additional"),
    );
  }

  TimelineTrack.empty({Widget? icon, Text? text, Widget? additional, Key? key})
      : this(
            elements: [],
            headerIcon: icon,
            headerText: text,
            headerAdditional: additional,
            key: key);

  TimelineTrack(
      {List<TimelineElement<T>>? elements,
      this.headerIcon,
      this.headerText,
      this.headerAdditional,
      this.headerWidth = 150,
      this.headerAxis = Axis.horizontal,
      Key? key})
      : super(key: key) {
    this.elements = elements ?? [];
  }

  @override
  TimelineTrackState<T> createState() => TimelineTrackState<T>(elements,
      headerIcon, headerText, headerAxis, headerAdditional, headerWidth);
}

class TimelineTrackState<T> extends State<TimelineTrack<T>>
    implements TimelineDataFactry<T> {
  final List<TimelineElement<T>> elements;
  Widget? headerIcon;
  Text? headerText;
  Widget? headerAdditional;
  Axis headerAxis;
  double headerWidth;
  GlobalKey headerKey = GlobalKey();

  final Map<TimelineElement<T>, TimelineElementState<T>> _elementStates = {};
  TimelineTrackState(this.elements, this.headerIcon, this.headerText,
      this.headerAxis, this.headerAdditional, this.headerWidth);

  void initElement(TimelineElementState<T> elementState) {
    var w = elementState.widget;
    _elementStates[w] = elementState;
  }

  void setTopElement(TimelineElementState<T> elementState) {
    var w = elementState.widget;
    setState(() {
      elements.remove(w);
      elements.add(w);
    });
  }

  void doAllElement(void function(TimelineElementState<T> elementState)) {
    for (var e in _elementStates.values) {
      function(e);
    }
  }

  void add(TimelineElement<T> element) {
    setState(() {
      elements.add(element);
    });
  }

  void remove(TimelineElement<T> element) {
    setState(() {
      _elementStates.remove(element);
      elements.remove(element);
    });
  }

  TimelineTrackHeader get header => TimelineTrackHeader(
        key: headerKey,
        icon: headerIcon,
        text: headerText,
        additional: headerAdditional,
        axix: headerAxis,
        width: headerWidth,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
        child: Row(
          children: [
            header,
            Stack(children: elements.length > 0 ? elements : [Text("Empty")]),
          ],
        ));
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    return [_elementStates.values.map((e) => e.getDatas()[0][0]).toList()];
  }
}

class TimelineTrackHeader extends StatelessWidget {
  final Widget? icon;
  final Text? text;
  final Widget? additional;
  final Axis axix;
  final double width;
  const TimelineTrackHeader(
      {this.icon,
      this.text,
      this.additional,
      this.axix = Axis.vertical,
      this.width = 150,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 1),
          color: Colors.grey.shade200),
      width: width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            constraints: BoxConstraints(minWidth: width - 2),
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Row(
                  children: [icon ?? Container(), text ?? Container()],
                ),
                additional ?? Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
