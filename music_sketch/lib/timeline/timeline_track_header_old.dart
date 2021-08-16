import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TimelineTrackHeader extends StatefulWidget {
  final Widget? icon;
  final Text? text;
  final Widget? additional;
  const TimelineTrackHeader({this.icon, this.text, this.additional, Key? key})
      : super(key: key);

  @override
  _TimelineTrackHeaderState createState() => _TimelineTrackHeaderState();
}

class _TimelineTrackHeaderState extends State<TimelineTrackHeader> {
  Widget? get icon => widget.icon;
  Text? get text => widget.text;
  Widget? get additional => widget.additional;
  _TimelineTrackHeaderState();

  @override
  Widget build(BuildContext context) {
    var cont = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) FittedBox(child: icon),
        if (text != null) FittedBox(child: text),
        if (additional != null)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 2, top:2, bottom: 2, right: 2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1),
                  ),
                  child: PopupMenuButton(
                    child: const FittedBox(
                      child: const Icon(
                        Icons.more_horiz,
                      ),
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: additional,
                          value: null,
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return FractionallySizedBox(
      widthFactor: 1.0,
      child: cont,
    );
  }
}
