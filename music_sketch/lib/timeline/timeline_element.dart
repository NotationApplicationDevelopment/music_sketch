import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:music_sketch/timeline/timeline_track.dart';
import 'timeline_data.dart';
import 'timeline_times.dart';

class TimelineElement extends StatefulWidget {
  final TimelinePositionRange positionRange;
  final dynamic additionalInfo;
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
  TimelineElementState createState() {
    return TimelineElementState(
        positionRange, child, additionalInfo, decoration, selectedDecoration);
  }
}

class TimelineElementState extends State<TimelineElement>
    implements TimelineDataFactry {
  TimelineTrackState? _trackState;
  late final TimelineElementData _elementData;
  late BoxDecoration _decoration;
  late BoxDecoration _selectedDecoration;
  Widget? _child;
  late double _width;
  late double _space;
  double _widthUnit = 100;
  int _dragMode = -1;
  double sizeChangeArea = 50;
  bool isSelected = false;

  TimelineElementState(
      TimelinePositionRange positionRange,
      Widget? child,
      dynamic additionalInfo,
      BoxDecoration? decoration,
      BoxDecoration? selectedDecoration) {
    _elementData = TimelineElementData(positionRange, additionalInfo);
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
  dynamic get additionalInfo => _elementData.info;
  set additionalInfo(dynamic value) {
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
      var end = _elementData.positionRange.end;
      if (start >= _elementData.positionRange.end) {
        switch (_dragMode) {
          case 1:
            _elementData.positionRange = TimelinePositionRange(end, end);
            break;
          case 2:
            _elementData.positionRange = TimelinePositionRange(start, start);
            break;
        }
      }

      if (start.position < 0) {
        var delta = start.to(TimelinePosition.fromPosition(0));
        switch (_dragMode) {
          case -1:
          case 0:
            _elementData.positionRange =
                _elementData.positionRange.shifted(delta);
            end = _elementData.positionRange.end;
            break;

          case 1:
            _elementData.positionRange =
                _elementData.positionRange.moved(start: delta);
            break;
        }
      }

      var trackEnd = _trackState?.eventsState?.trackEnd;
      if (trackEnd != null && trackEnd < end) {
        int minCount = (end.position + 1).floor();
        double count = minCount.toDouble();
        bool ok = true;
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Expands the area."),
              content: Text("Expands the area, for the operation."),
              actions: <Widget>[
                TextFormField(
                  initialValue: minCount.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Range of area(min value : $minCount)",
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value == null) {
                      value = "";
                    }
                    final n = num.tryParse(value);
                    if (n == null || n < minCount) {
                      ok = false;
                      return 'min value is $minCount';
                    }
                    ok = true;
                    count = n.toDouble();
                    return null;
                  },
                ),
                ElevatedButton(
                  child: Text("OK"),
                  onPressed: () {
                    if (!ok) {
                      return;
                    }
                    _trackState!.eventsState!.trackEnd =
                        TimelinePosition.fromPosition(count);
                    if (setState) {
                      Future.delayed(Duration(milliseconds: 100), () {
                        this.setState(() {
                          _width = _widthUnit *
                              _elementData.positionRange.range.range;
                        });
                      });
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
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

  void _doAllElement(void function(TimelineElementState elementState)) {
    _trackState == null ? function(this) : _trackState!.eventsState == null ? _trackState!.doAllElement(function): _trackState!.eventsState!.doAllElement(function);
  }

  @override
  Widget build(BuildContext context) {
    _trackState = context.findAncestorStateOfType<TimelineTrackState>();
    _trackState?.initElement(this);
    var unit = _trackState?.eventsState?.widthUnit;
    var trackEnd = _trackState?.eventsState?.trackEnd;
    if (unit != null && _widthUnit != unit) {
      _widthUnit = unit;
      _width = _widthUnit * _elementData.positionRange.range.range;
      _space = _widthUnit * _elementData.positionRange.start.position;
    }
    if (trackEnd != null && trackEnd < _elementData.positionRange.end) {
      _width = _widthUnit * _elementData.positionRange.start.to(trackEnd).range;
    }
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
            height: _trackState == null ? 30 : null,
            width: width2,
            child: _child,
          ),
        ],
      ),
    );

    return GestureDetector(
        child: element,
        onTap: () {
          _trackState?.setTopElement(this);
          if (isSelected) {
            setState(() {
              isSelected = false;
            });
            return;
          }
          _doAllElement((e) {
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
        onHorizontalDragStart: (details) {
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
          if (!isSelected) {
            _trackState?.setTopElement(this);
            _doAllElement((e) {
              bool s = e == this;
              if (e.isSelected != s) {
                e.setState(() {
                  e.isSelected = e == this;
                });
              }
            });
          } else {
            _doAllElement((e) {
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
          _doAllElement((e) {
            e._dragMode = -1;
            if (e._elementData.positionRange.isZeroLength) {
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
  List<List<TimelineElementData>> getDatas() {
    return [
      [_elementData]
    ];
  }
}
