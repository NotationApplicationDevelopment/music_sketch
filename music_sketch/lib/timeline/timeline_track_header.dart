import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TimelineTrackHeader extends StatefulWidget {
  final Widget? icon;
  final Text? text;
  final Widget? additional;
  const TimelineTrackHeader({this.icon, this.text, this.additional, Key? key})
      : super(key: key);

  @override
  _TimelineTrackHeaderState createState() =>
      _TimelineTrackHeaderState(icon, text, additional);
}

class _TimelineTrackHeaderState extends State<TimelineTrackHeader> {
  Widget? icon;
  Text? text;
  Widget? additional;

  _TimelineTrackHeaderState(this.icon, this.text, this.additional);

  @override
  Widget build(BuildContext context) {
    var cont = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 1),
          color: Colors.grey.shade200),
      height: 10,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

    return FractionallySizedBox(
      widthFactor: 1.0,
      child: cont,
    );
  }
}
