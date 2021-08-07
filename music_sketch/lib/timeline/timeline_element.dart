import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_sketch/timeline/timeline_track.dart';
import 'timeline_data.dart';
import 'timeline_times.dart';

class TimelineElement<T> extends StatefulWidget {
  final TimelinePositionRange positionRange;
  final T? additionalInfo;
  final BoxDecoration? decoration;
  final BoxDecoration? selectedDecoration;
  final Widget? child;
  TimelineElement(
      {required this.positionRange,
      this.child,
      this.additionalInfo,
      this.decoration,
      this.selectedDecoration})
      : super(key: UniqueKey());

  @override
  TimelineElementState<T> createState() {
    return TimelineElementState<T>(
        positionRange, child, additionalInfo, decoration, selectedDecoration);
  }
}

class TimelineElementState<T> extends State<TimelineElement<T>>
    implements TimelineDataFactry<T> {
  TimelineTrackState<T>? trackState;
  late final TimelineElementData<T> _elementData;
  late BoxDecoration _decoration;
  late BoxDecoration _selectedDecoration;
  Widget? _child;
  late double _width;
  late double _space;
  double _widthUnit = 100;
  int _dragMode = 0;
  double sizeChangeArea = 50;
  bool isSelected = false;

  TimelineElementState(
      TimelinePositionRange positionRange,
      Widget? child,
      T? additionalInfo,
      BoxDecoration? decoration,
      BoxDecoration? selectedDecoration) {
    _elementData = TimelineElementData<T>(positionRange, additionalInfo);
    _decoration = decoration ??
        BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.red.shade900, width: 2),
            color: Colors.red);
    _selectedDecoration = selectedDecoration ??
        BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.redAccent.shade200, width: 2),
            color: Colors.redAccent.shade100);

    _child = child;
    _positionRangeUpdate(setState: false);
  }

  TimelinePositionRange get positionRange => _elementData.positionRange;
  T? get additionalInfo => _elementData.info;
  set additionalInfo(T? value) {
    _elementData.info = value;
  }

  void shift(TimelineRange shift) {
    _elementData.positionRange = _elementData.positionRange.shifted(shift);
    _positionRangeUpdate();
  }

  void move({TimelineRange? start, TimelineRange? end}) {
    _elementData.positionRange =
        _elementData.positionRange.moved(start: start, end: end);
    _positionRangeUpdate();
  }

  void set({TimelinePosition? start, TimelinePosition? end}) {
    TimelineRange? sr, se;
    if (start != null) {
      sr = _elementData.positionRange.start.to(start);
    }
    if (end != null) {
      se = _elementData.positionRange.end.to(end);
    }
    move(start: sr, end: se);
  }

  void _positionRangeUpdate({bool setState = true}) {
    void update() {
      var start = _elementData.positionRange.start;
      if (start >= _elementData.positionRange.end) {
        _elementData.positionRange = TimelinePositionRange(start, start);
      }

      if (start.position < 0) {
        _elementData.positionRange = _elementData.positionRange
            .shifted(TimelineRange.fromRange(-start.position));
      }

      _width = _widthUnit * _elementData.positionRange.range.range;
      _space = _widthUnit * _elementData.positionRange.start.position;
    }

    if (setState) {
      this.setState(update);
    } else {
      update();
    }
  }

  void _doAllElement(void function(TimelineElementState<T> elementState)) {
    trackState == null ? function(this) : trackState!.doAllElement(function);
  }

  @override
  Widget build(BuildContext context) {
    trackState = context.findAncestorStateOfType<TimelineTrackState<T>>();
    trackState?.initElement(this);

    var width2 = max(_width, 1.0);
    var element = Container(
      width: _space + width2,
      child: Row(
        children: [
          Container(
            width: _space,
          ),
          Container(
            decoration: isSelected ? _selectedDecoration : _decoration,
            height: trackState == null ? 30 : null,
            width: width2,
            child: _child,
          ),
        ],
      ),
    );

    return GestureDetector(
        child: element,
        onTap: () {
          trackState?.setTopElement(this);
          if (isSelected) {
            setState(() {
              isSelected = false;
            });
            return;
          }
          _doAllElement((e) {
            Future(() {
              bool s = e == this;
              if(e.isSelected != s){
                e.setState(() {
                  e.isSelected = s;
                });
              }
            });
          });
        },
        onLongPress: () {
          trackState?.setTopElement(this);
          if(!isSelected){
            setState(() {
              isSelected = true;
            });
          }
        },
        onHorizontalDragStart: (details) {
          if (!isSelected) {
            trackState?.setTopElement(this);
            _doAllElement((e) {
              Future(() {
                bool s = e == this;
                if(e.isSelected != s){
                  e.setState(() {
                    e.isSelected = e == this;
                  });
                }
              });
            });
          }
          var pos = details.localPosition.distance - _space;
          if (_width <= sizeChangeArea * 3) {
            if (pos < _width * (1.0 / 3.0)) {
              _dragMode = 1;
            } else if (_width * (2.0 / 3.0) < pos) {
              _dragMode = 2;
            } else {
              _dragMode = 0;
            }
          } else {
            if (pos <= sizeChangeArea) {
              _dragMode = 1;
            } else if (_width - sizeChangeArea <= pos) {
              _dragMode = 2;
            } else {
              _dragMode = 0;
            }
          }
        },
        onHorizontalDragEnd: (details) {
          if (!isSelected) {
            return;
          }
          _doAllElement((e) {
            Future(() {
              if (e._elementData.positionRange.isZeroLength) {
                trackState?.remove(e.widget);
              }
            });
          });
        },
        onHorizontalDragUpdate: (details) {
          if (!isSelected) {
            return;
          }
          var dist = TimelineRange.fromRange(details.delta.dx / _widthUnit);
          switch (_dragMode) {
            case 0:
              _doAllElement((e) {
                if (e.isSelected) {
                  e.shift(dist);
                }
              });
              break;
            case 1:
              _doAllElement((e) {
                if (e.isSelected) {
                  e.move(start: dist);
                }
              });
              break;
            case 2:
              _doAllElement((e) {
                if (e.isSelected) {
                  e.move(end: dist);
                }
              });
              break;
          }
        });
  }

  @override
  List<List<TimelineElementData<T>>> getDatas() {
    return [
      [_elementData]
    ];
  }
}
