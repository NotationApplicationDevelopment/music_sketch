import 'dart:ui';

import 'package:flutter/material.dart';
import 'timeline_events.dart';

class TimelineScale extends StatefulWidget {
  final int subSplit;
  final Color? color;
  final bool isBack;
  const TimelineScale({
    this.isBack = false,
    this.subSplit = 4,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  _TimelineScaleState createState() => _TimelineScaleState();
}

class _TimelineScaleState extends State<TimelineScale> {
  int get _subSplit => widget.subSplit;
  bool get _isBack => widget.isBack;
  Color get _color => widget.color ?? Colors.black;
  TimelineEventsState? eventsState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    eventsState = context.findAncestorStateOfType<TimelineEventsState>();
  }

  @override
  Widget build(BuildContext context) {
    var widthUnit = eventsState?.unitWidth ?? 100;
    var cont = CustomPaint(
      child: Row(
        children: _isBack
            ? []
            : List<Widget>.generate(
                eventsState?.trackEnd.position.floor() ?? 0,
                (index) => SizedBox(
                  width: widthUnit,
                  child: RichText(
                    text: TextSpan(
                      text: " ${index + 1}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2,
                    ),
                  ),
                ),
              ),
      ),
      painter: _ScalePainter(
        widthUnit,
        _subSplit,
        _color,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: cont,
      onDoubleTap: () {
        eventsState?.doAllElement((state) {
          state.setState(() {
            state.isSelected = false;
          });
        });
      },
      onLongPressStart: (detail) {
        if (eventsState != null) {
          for (var track in eventsState!.trackStates.values) {
            track.onLongPressStart(detail);
          }
        }
      },
      onLongPressMoveUpdate: (detail) {
        if (eventsState != null) {
          for (var track in eventsState!.trackStates.values) {
            track.onLongPressMoveUpdate(detail);
          }
        }
      },
      onLongPressEnd: (detail) {
        if (eventsState != null) {
          for (var track in eventsState!.trackStates.values) {
            track.onLongPressEnd(detail);
          }
        }
      },
    );
  }
}

class _ScalePainter extends CustomPainter {
  final int subSplit;
  final Color color;
  final double unitWidth;
  late final double _subWidth;

  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );

  _ScalePainter(this.unitWidth, this.subSplit, this.color) {
    _subWidth = unitWidth / subSplit;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint();
    painter.color = color;
    painter.isAntiAlias = false;
    int count = 0;
    painter.strokeWidth = 2 + 2 / 3;
    for (double pos = 0.0; pos <= size.width; pos += _subWidth) {
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), painter);
      if (count < subSplit - 1) {
        count++;
        painter.strokeWidth = 2 / 3;
      } else {
        count = 0;
        painter.strokeWidth = 2 + 2 / 3;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScalePainter oldDelegate) {
    return oldDelegate.unitWidth != unitWidth;
  }
}
