import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_sketch/timeline/timeline_track.dart';
import 'timeline_data.dart';
import 'timeline_times.dart';

class TimelineElement extends StatefulWidget {
  final TimelineElementData elementData;
  final BoxDecoration? decoration;
  final BoxDecoration? selectedDecoration;
  final Widget? child;
  TimelineElement(
      {required this.elementData,
      this.child,
      this.decoration,
      this.selectedDecoration,
      Key? key})
      : super(key: key);

  @override
  TimelineElementState createState() {
    return TimelineElementState();
  }
}

class TimelineElementState extends State<TimelineElement> with AutomaticKeepAliveClientMixin{
  TimelineTrackState? _trackState;
  TimelinePosition _trackEnd = TimelinePosition.fromPosition(100);
  int _dragMode = -1;
  double sizeChangeArea = 30;
  bool isSelected = false;
  Offset _tapStartLocalPos = Offset.zero;

  @override
  void initState() {
    super.initState();
  }

  TimelineElementData get elementData => widget.elementData;
  TimelinePositionRange get positionRange => widget.elementData.positionRange;
  set positionRange(TimelinePositionRange value) {
    widget.elementData.positionRange = value;
  }

  dynamic get additionalInfo => widget.elementData.info;
  set additionalInfo(dynamic value) {
    widget.elementData.info = value;
  }

  double get unitWidth => _trackState?.unitWidth ?? 100;
  double get trackHeight => _trackState?.trackHeight ?? 30;
  TimelinePosition get trackEnd => _trackState?.trackEnd ?? _trackEnd;
  set trackEnd(TimelinePosition value) {
    _trackEnd = value;
    _trackState?.trackEnd = value;
  }

  Widget? get child => widget.child;

  BoxDecoration get decoration {
    return widget.decoration ??
        BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.red.shade900, width: 2),
          color: Colors.red,
        );
  }

  BoxDecoration get selectedDecoration {
    return widget.selectedDecoration ??
        BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.redAccent.shade200, width: 2),
          color: Colors.redAccent.shade100,
        );
  }

  void shift(TimelineRange shift) {
    positionRange = positionRange.shifted(shift);
  }

  void move({TimelineRange? start, TimelineRange? end}) {
    positionRange = positionRange.moved(start: start, end: end);
  }

  void set({TimelinePosition? start, TimelinePosition? end}) {
    positionRange = positionRange.seted(start: start, end: end);
  }

  void positionRangeCheck() {
    var start = positionRange.start;
    var end = positionRange.end;
    if (start >= positionRange.end) {
      switch (_dragMode) {
        case 1:
          positionRange = TimelinePositionRange(end, end);
          break;
        case 2:
          positionRange = TimelinePositionRange(start, start);
          break;
      }
    }

    if (start.position < 0) {
      var delta = start.to(TimelinePosition.fromPosition(0));
      switch (_dragMode) {
        case -1:
        case 0:
          positionRange = positionRange.shifted(delta);
          end = positionRange.end;
          break;

        case 1:
          positionRange = positionRange.moved(start: delta);
          break;
      }
    }

    if (this.trackEnd < end) {
      _trackState
          ?.expanding(end.position.floorToDouble() + 1, 20)
          .then((value) => setState(() {}));
    }
  }

  void _doAllElementInEvents(void function(TimelineElementState elementState)) {
    _trackState == null
        ? function(this)
        : _trackState!.doAllElementInEvents(function);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trackState = context.findAncestorStateOfType<TimelineTrackState>();
    _trackState?.initElement(this);
    Future(() {
      positionRangeCheck();
    });
  }


  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var unitWidth = this.unitWidth;
    var trackEnd = unitWidth * this.trackEnd.position;
    var space =
        (unitWidth * positionRange.start.position).clamp(0.0, trackEnd - 1);
    var width =
        (unitWidth * positionRange.range.range).clamp(1.0, trackEnd - space);

    Widget element = SizedBox(
      height: trackHeight,
      width: width,
      child: DecoratedBox(
        decoration: isSelected ? selectedDecoration : decoration,
        child: child,
      ),
    );

    element = GestureDetector(
      child: element,
      onTapDown: (details) {
        _tapStartLocalPos = details.localPosition;
      },
      onTap: () {
        if (isSelected) {
          setState(() {
            isSelected = false;
          });
          return;
        }
        _trackState?.setTopElement(this);
        _doAllElementInEvents((e) {
          bool s = e == this;
          if (e.isSelected != s) {
            e.setState(() {
              e.isSelected = s;
            });
          }
        });
      },
      onLongPress: () {
        _trackState?.setTopElement(this);
        if (!isSelected) {
          setState(() {
            isSelected = true;
          });
        }
      },
      onHorizontalDragDown: (details) {
        _tapStartLocalPos = details.localPosition;
      },
      onHorizontalDragStart: (details) {
        var pos = _tapStartLocalPos.dx;
        var width = this.unitWidth * positionRange.range.range;
        if (width <= sizeChangeArea * 3) {
          if (pos < width * (1.0 / 3.0)) {
            _dragMode = 1;
          } else if (width * (2.0 / 3.0) < pos) {
            _dragMode = 2;
          } else {
            _dragMode = 0;
          }
        } else {
          if (pos <= sizeChangeArea) {
            _dragMode = 1;
          } else if (width - sizeChangeArea <= pos) {
            _dragMode = 2;
          } else {
            _dragMode = 0;
          }
        }
        if (!isSelected) {
          _trackState?.setTopElement(this);
          _doAllElementInEvents((e) {
            bool s = e == this;
            if (e.isSelected != s) {
              e.setState(() {
                e.isSelected = e == this;
              });
            }
          });
        } else {
          _doAllElementInEvents((e) {
            if (e.isSelected) {
              e._dragMode = _dragMode;
            }
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (!isSelected) {
          return;
        }
        _doAllElementInEvents((e) {
          e._dragMode = -1;
          if (e.positionRange.isZeroLength) {
            Future(() {
              e._trackState?.remove(e.widget);
            });
          }
        });
      },
      onHorizontalDragUpdate: (details) {
        if (!isSelected) {
          return;
        }
        var dist = TimelineRange.fromRange(details.delta.dx / unitWidth);
        switch (_dragMode) {
          case 0:
            _doAllElementInEvents((e) {
              if (e.isSelected) {
                e.setState(() {
                  e.shift(dist);
                  e.positionRangeCheck();
                });
              }
            });
            break;
          case 1:
            _doAllElementInEvents((e) {
              if (e.isSelected) {
                e.setState(() {
                  e.move(start: dist);
                  e.positionRangeCheck();
                });
              }
            });
            break;
          case 2:
            _doAllElementInEvents((e) {
              if (e.isSelected) {
                e.setState(() {
                  e.move(end: dist);
                  e.positionRangeCheck();
                });
              }
            });
            break;
        }
      },
    );

    return Padding(
      padding: EdgeInsets.only(left: space),
      child: element,
    );
  }
}
