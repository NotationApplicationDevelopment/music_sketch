import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_sketch/timeline/timeline_data.dart';
import 'package:music_sketch/timeline/timeline_times.dart';

import 'multi_header_list_view.dart';
import 'scale.dart';

class TimelineEvents extends StatefulWidget {
  final double initialUnitWidth;
  final double initialTrackHeight;
  final TimelinePosition initialTrackEnd;
  final Map<String, Set<TimelineElementData>> initEventDatas;

  const TimelineEvents({
    required this.initialUnitWidth,
    required this.initialTrackHeight,
    required this.initialTrackEnd,
    this.initEventDatas = const {},
    Key? key,
  }) : super(key: key);

  @override
  _TimelineEventsState createState() => _TimelineEventsState();
}

class _TimelineEventsState extends State<TimelineEvents>
    implements TimelineDataFactry {
  double trackHeaderWidth = 100;
  double scaleHeaderHeight = 30;
  Set<String> editedTracks = {};
  Set<TimelineElementData> editedElements = {};
  final Map<String, Set<TimelineElementData>> selectedElements = {};
  final Map<String, Set<TimelineElementData>> notSelectedElements = {};

  late double trackHeight;
  late TimelinePosition trackEnd;
  late double _unitWidth;

  double _scallingUnitWidth = 0;

  double get unitWidth => _unitWidth;

  set unitWidth(double unitWidth) {
    if (_unitWidth == unitWidth) {
      return;
    }
    setState(() {
      _unitWidth = unitWidth;
    });
  }

  @override
  void initState() {
    super.initState();
    _unitWidth = widget.initialUnitWidth;
    trackHeight = widget.initialTrackHeight;
    trackEnd = widget.initialTrackEnd;
    addTracks(widget.initEventDatas);
  }

  void addTracks(Map<String, Set<TimelineElementData>> tracks) {
    notSelectedElements.addAll(tracks);
    selectedElements.addAll(tracks.map((key, value) => MapEntry(key, {})));
  }

  @override
  Widget build(BuildContext context) {
    var view = MultiHeaderListView(
      contentsSize: Size(
        unitWidth * trackEnd.position ,
        trackHeight * notSelectedElements.length,
      ),
      leftHeaderWidth: trackHeaderWidth,
      topHeaderHeight: scaleHeaderHeight,
      scrollMargin: EdgeInsets.fromLTRB(1, 1, 100, 100),
      topLeftHeader: const _TopLeftHeader(),
      headers: [
        MultiHeaderListViewTrack.fromList(
          Axis.horizontal,
          ScaleFactory.fromWidthAsUnit(
            height: scaleHeaderHeight,
            widthAsUnit: trackEnd.position + 100/unitWidth,
            unitWidth: unitWidth,
            subSplit: 4,
            color: Colors.grey,
            text: (i, d) {
              return i < trackEnd.position ? i.toString() : "";
            },
          ).asUnitList(),
        ),
        MultiHeaderListViewTrack.fromList(
          Axis.vertical,
          [Text("left")],
        )
      ],
      mainChildren: [
        MultiHeaderListViewTrack.fromList(
          Axis.horizontal,
          ScaleFactory.fromWidthAsUnit(
            height: trackHeight * notSelectedElements.length,
            widthAsUnit: trackEnd.position,
            unitWidth: unitWidth,
            subSplit: 4,
            color: Colors.grey,
          ).asUnitList(),
        ),
        MultiHeaderListViewTrack.fromList(
          Axis.vertical,
          notSelectedElements.entries.map((e) {
            return Container(
              height: trackHeight,
              width: unitWidth * trackEnd.position,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(e.key),
            );
          }),
        )
      ],
    );

    var gesture = GestureDetector(
      child: view,
      behavior: HitTestBehavior.translucent,
      onScaleStart: (detail) {
        _scallingUnitWidth = unitWidth;
      },
      onScaleUpdate: (detail) {
        unitWidth = _scallingUnitWidth * detail.scale;
      },
    );
    var model = TimelineEventsEditor(
      state: this,
      child: gesture,
    );

    editedTracks.clear();
    editedElements.clear();

    return model;
  }

  void updateElement(e) => editedElements.add(e);

  void updateTrack(t) => editedTracks.add(t);

  @override
  Map<String, List<TimelineElementData>> getDatas() {
    Map<String, List<TimelineElementData>> data = {};

    for (var item in notSelectedElements.entries) {
      data[item.key] =
          item.value.toList() + selectedElements[item.key]!.toList();
    }

    return data;
  }
}

class _TopLeftHeader extends StatelessWidget {
  const _TopLeftHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const underLine = const BoxDecoration(
      border: Border.fromBorderSide(
        BorderSide(
          width: 1,
          color: Colors.grey,
        ),
      ),
    );

    final model = TimelineEventsEditor.of(
      context,
      TimelineEventsEditInfo(
        type: TimelineEventsEditType.fromTopLeftHeader,
      ),
    );

    return DecoratedBox(
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
              ),
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
            onTap: () {
              model!.unitWidth /= 1.1;
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
              ),
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
            onTap: () {
              model!.unitWidth *= 1.1;
            },
          ),
        ],
      ),
    );
  }
}

class _EventsScaleUnit extends StatelessWidget {
  const _EventsScaleUnit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}

enum TimelineEventsEditType {
  fromTrack,
  fromElement,
  fromTopLeftHeader,
  fromTrackHeader,
  fromScaleHeader,
}

class TimelineEventsEditInfo {
  final TimelineEventsEditType type;
  final String? trackName;
  final TimelineElementData? elementData;

  const TimelineEventsEditInfo(
      {required this.type, this.trackName, this.elementData});

  bool operator ==(dynamic other) {
    return (other is TimelineEventsEditInfo) &&
        (this.type == other.type) &&
        (this.trackName == other.trackName) &&
        (this.elementData == other.elementData);
  }

  @override
  int get hashCode => type.hashCode ^ trackName.hashCode ^ elementData.hashCode;
}

typedef TimelineElementAction = void Function(
  TimelineElementData elementData,
  String trackName,
  bool isSelected,
);

class TimelineEventsEditor extends InheritedModel<TimelineEventsEditInfo> {
  final _TimelineEventsState _state;

  TimelineEventsEditor._create(
    this._state,
    Widget child,
    Key? key,
  ) : super(child: child, key: key);

  factory TimelineEventsEditor({
    required _TimelineEventsState state,
    required Widget child,
    Key? key,
  }) {
    return TimelineEventsEditor._create(
      state,
      child,
      key,
    );
  }

  double get trackHeight => _state.trackHeight;
  TimelinePosition get trackEnd => _state.trackEnd;
  Map<String, Set<TimelineElementData>> get _selectedElements =>
      _state.selectedElements;
  Map<String, Set<TimelineElementData>> get _notSelectedElements =>
      _state.notSelectedElements;
  double get viewWidth => unitWidth * trackEnd.position;
  double get wiewHeight => trackHeight * _selectedElements.length;

  double get unitWidth => _state.unitWidth;
  set unitWidth(double value) {
    _state.unitWidth = value;
  }

  set trackHeight(double value) {
    _state.trackHeight = value;
  }

  set trackEnd(TimelinePosition value) {
    _state.trackEnd = value;
  }

  void addTracks(Map<String, Set<TimelineElementData>> tracks) {
    _notSelectedElements.addAll(tracks);
    _selectedElements.addAll(tracks.map((key, value) => MapEntry(key, {})));
  }

  /// トラックの更新をEventsに伝える
  void updateTrack(String trackName) => _state.updateTrack(trackName);

  /// エレメントの更新をEventsに伝える
  void updateElement(TimelineElementData elementData) =>
      _state.updateElement(elementData);

  /// エレメントの選択状態を変更する
  bool setSelectedOfElement(
      TimelineElementData elementData, String trackName, bool isSelected) {
    var trackS = _selectedElements[trackName];
    var trackNS = _notSelectedElements[trackName];

    if (trackS == null || trackNS == null) {
      return false;
    }

    if (isSelected) {
      if (!trackNS.remove(elementData)) {
        return false;
      }
      trackS.add(elementData);
    } else {
      if (!trackS.remove(elementData)) {
        return false;
      }
      trackNS.add(elementData);
    }

    updateElement(elementData);
    return true;
  }

  void shiftElementOnTrack(
      Map<String, List<TimelineElementData>> elementData, int diff) {
    int i = 0;
    var keyIndex = Map.fromEntries(
      _notSelectedElements.keys.map(
        (e) => MapEntry(
          e,
          i++,
        ),
      ),
    );

    var removedSelected = Map<String, List<TimelineElementData>>.fromIterables(
      elementData.keys,
      List.generate(elementData.length, (index) => []),
    );

    var removedNotSelected =
        Map<String, List<TimelineElementData>>.fromIterables(
      elementData.keys,
      List.generate(elementData.length, (index) => []),
    );

    for (var element in elementData.entries) {
      var sel = removedSelected[element.key]!;
      var notSel = removedNotSelected[element.key]!;

      _selectedElements[element.key]?.removeWhere((e) {
        if (element.value.remove(e)) {
          updateElement(e);
          sel.add(e);
          return true;
        }
        return false;
      });

      _notSelectedElements[element.key]?.removeWhere((e) {
        if (element.value.remove(e)) {
          updateElement(e);
          notSel.add(e);
          return true;
        }
        return false;
      });
    }

    for (var from in removedNotSelected.entries) {
      var to = keyIndex[from.key]!;
      _notSelectedElements.values.elementAt(to).addAll(from.value);
      _selectedElements.values.elementAt(to).addAll(removedSelected[from.key]!);
    }
  }

  /// 全てのエレメントに変更を加える
  void doAllElement(TimelineElementAction action) {
    doAllSelectedElement(action);
    doAllNotSelectedElement(action);
  }

  /// 選択された全てのエレメントに変更を加える
  void doAllSelectedElement(TimelineElementAction action) {
    //actionでmapを編集されても良いように、toList()する。
    for (var track in _selectedElements.entries.toList()) {
      for (var element in track.value.toList()) {
        action(element, track.key, true);
      }
    }
  }

  /// 選択されていない全てのエレメントに変更を加える
  void doAllNotSelectedElement(TimelineElementAction action) {
    //actionでmapを編集されても良いように、toList()する。
    for (var track in _notSelectedElements.entries.toList()) {
      for (var element in track.value.toList()) {
        action(element, track.key, false);
      }
    }
  }

  /// 複数トラックのエレメントに変更を加える
  bool doAllElementOfTracks(
      List<String> trackNames, TimelineElementAction action) {
    for (var trackName in trackNames) {
      if (!doAllElementOfTrack(trackName, action)) {
        return false;
      }
    }
    return true;
  }

  /// 特定トラックのエレメントに変更を加える
  bool doAllElementOfTrack(String trackName, TimelineElementAction action) {
    var trackS = _selectedElements[trackName];
    var trackNS = _notSelectedElements[trackName];
    if (trackS == null || trackNS == null) {
      return false;
    }

    for (var element in trackS.toList()) {
      action(element, trackName, true);
    }

    for (var element in trackNS.toList()) {
      action(element, trackName, false);
    }

    return true;
  }

  static TimelineEventsEditor? of(
      BuildContext context, TimelineEventsEditInfo aspect) {
    return InheritedModel.inheritFrom<TimelineEventsEditor>(context,
        aspect: aspect);
  }

  @override
  bool updateShouldNotify(covariant TimelineEventsEditor old) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(covariant TimelineEventsEditor old,
      Set<TimelineEventsEditInfo> dependencies) {
    for (var depend in dependencies) {
      switch (depend.type) {
        case TimelineEventsEditType.fromTrack:
          return true;
        case TimelineEventsEditType.fromElement:
          return true;
        case TimelineEventsEditType.fromTopLeftHeader:
          return true;
        case TimelineEventsEditType.fromTrackHeader:
          return true;
        case TimelineEventsEditType.fromScaleHeader:
          return true;
      }
    }
    return false;
  }
}
