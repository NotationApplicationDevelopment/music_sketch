import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_sketch/timeline/timeline_data.dart';
import 'package:music_sketch/timeline/timeline_times.dart';
import 'package:music_sketch/timeline/timeline_track.dart';

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
  final Map<String, Set<TimelineElementData>> selectedElements = {};
  final Map<String, Set<TimelineElementData>> notSelectedElements = {};
  late final _ScaleBuilder _topScale;
  late final _ScaleBuilder _backScale;

  late double trackHeight;
  late TimelinePosition trackEnd;
  late double _unitWidth;

  double _scallingUnitWidth = 0;
  double _scallingTrackHeight = 0;

  final Map<String, TimelineTrackState> _tracks = {};

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

    _topScale = _ScaleBuilder(
      ScaleFactory(text: (i, d) {
        return i < this.trackEnd.position ? (i + 1).toString() : "";
      }),
      TimelineEventsEditInfo(updateWith: {
        TimelineEventsUpdateWith.scaleHedaerHeight,
        TimelineEventsUpdateWith.unitWidth,
        TimelineEventsUpdateWith.trackEnd,
      }),
    );

    _backScale = _ScaleBuilder(
      ScaleFactory(text: null),
      TimelineEventsEditInfo(updateWith: {
        TimelineEventsUpdateWith.unitWidth,
        TimelineEventsUpdateWith.trackEnd,
      }),
    );
  }

  void addTracks(Map<String, Set<TimelineElementData>> tracks) {
    notSelectedElements.addAll(tracks);
    selectedElements.addAll(tracks.map((key, value) => MapEntry(key, {})));
  }

  @override
  Widget build(BuildContext context) {
    _topScale.scale.updateWith(
      widthAsUnit: trackEnd.position + 100 / _unitWidth,
      height: scaleHeaderHeight,
      unitWidth: unitWidth,
      subSplit: 4,
    );

    _backScale.scale.updateWith(
      widthAsUnit: trackEnd.position,
      height: trackHeight * notSelectedElements.length,
      unitWidth: unitWidth,
      subSplit: 4,
    );
    int count = 0;
    for (var track in selectedElements.values) {
      count += track.length;
    }
    var view = MultiHeaderListView(
      contentsSize: Size(
        unitWidth * trackEnd.position,
        trackHeight * notSelectedElements.length,
      ),
      leftHeaderWidth: trackHeaderWidth,
      topHeaderHeight: scaleHeaderHeight,
      scrollMargin: EdgeInsets.fromLTRB(1, 1, 100, 100),
      topLeftHeader: const _TopLeftHeader(),
      headers: [
        _topScale.builder(),
        MultiHeaderListViewTrack.fromList(
          Axis.vertical,
          [
            SizedBox(
              height: trackHeight * notSelectedElements.length * 1.5,
              child: FittedBox(
                child: Text("left"),
              ),
            )
          ],
        )
      ],
      mainChildren: [
        _backScale.builder(),
        MultiHeaderListViewTrack(
          Axis.vertical,
          () => notSelectedElements.length,
          (context, index) {
            var name = notSelectedElements.keys.elementAt(index);
            return TimelineTrack(trackName: name);
          },
        ),
      ],
    );

    var gesture = GestureDetector(
      child: view,
      behavior: HitTestBehavior.translucent,
      onScaleStart: (detail) {
        _scallingUnitWidth = unitWidth;
        _scallingTrackHeight = trackHeight;
      },
      onScaleUpdate: (detail) {
        unitWidth = _scallingUnitWidth * detail.scale;
        trackHeight = _scallingTrackHeight * detail.scale;
      },
    );

    var model = TimelineEventsEditor(
      state: this,
      child: gesture,
    );

    return model;
  }

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
        updateWith: {
          TimelineEventsUpdateWith.trackHeaderWidth,
          TimelineEventsUpdateWith.scaleHedaerHeight,
        },
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
              model.trackHeight /= 1.1;
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
              model.trackHeight *= 1.1;
            },
          ),
        ],
      ),
    );
  }
}

class _ScaleBuilder {
  ScaleFactory scale;
  TimelineEventsEditInfo editInfo;
  _ScaleBuilder(this.scale, this.editInfo);

  MultiHeaderListViewTrack builder() {
    return MultiHeaderListViewTrack(
      Axis.horizontal,
      () => scale.length,
      (context, index) {
        TimelineEventsEditor.of(context, editInfo);
        return scale.asUnitAtIndex(index);
      },
    );
  }
}

enum TimelineEventsUpdateWith {
  trackHeaderWidth,
  scaleHedaerHeight,
  unitWidth,
  trackHeight,
  trackEnd,
  trackCount,
  elementSelection,
  editedTrack,
  editedElement,
}

class _TimelineEventsUpdateData {
  final double _trackHeaderWidth;
  final double _scaleHedaerHeight;
  final double _unitWidth;
  final double _trackHeight;
  final TimelinePosition _trackEnd;
  final int _trackCount;
  final Map<String, Map<TimelineElementData, bool>> _elementSelections;
  final Set<String> _editedTracks = {};
  final Set<TimelineElementData> _editedElements = {};

  factory _TimelineEventsUpdateData(_TimelineEventsState state) {
    final Map<String, Map<TimelineElementData, bool>> elementSelections = {};
    int count = 0;
    for (var item in state.selectedElements.entries) {
      count += item.value.length;
      elementSelections[item.key] = Map.fromIterable(
        item.value,
        value: (i) => true,
      );
    }
    for (var item in state.notSelectedElements.entries) {
      elementSelections[item.key]!.addAll(
        Map.fromIterable(
          item.value,
          value: (i) => false,
        ),
      );
    }

    return _TimelineEventsUpdateData._init(
        state.trackHeaderWidth,
        state.scaleHeaderHeight,
        state._unitWidth,
        state.trackHeight,
        state.trackEnd,
        state.notSelectedElements.length,
        elementSelections);
  }

  _TimelineEventsUpdateData._init(
    this._trackHeaderWidth,
    this._scaleHedaerHeight,
    this._unitWidth,
    this._trackHeight,
    this._trackEnd,
    this._trackCount,
    this._elementSelections,
  );

  bool hasChange(_TimelineEventsUpdateData other) {
    return (this._trackHeaderWidth != other._trackHeaderWidth) ||
        (this._scaleHedaerHeight != other._scaleHedaerHeight) ||
        (this._unitWidth != other._unitWidth) ||
        (this._trackHeight != other._trackHeight) ||
        (this._trackEnd != other._trackEnd) ||
        (this._trackCount != other._trackCount) ||
        _elementSelectionsEquals(other) ||
        _editedTracks.isNotEmpty ||
        _editedElements.isNotEmpty;
  }

  bool operator ==(dynamic other) {
    if ((other is! _TimelineEventsUpdateData) ||
        (this._trackHeaderWidth != other._trackHeaderWidth) ||
        (this._scaleHedaerHeight != other._scaleHedaerHeight) ||
        (this._unitWidth != other._unitWidth) ||
        (this._trackHeight != other._trackHeight) ||
        (this._trackEnd != other._trackEnd) ||
        (this._trackCount != other._trackCount)) {
      return false;
    }

    return _elementSelectionsEquals(other);
  }

  bool updateShouldNotifyDependent(
      TimelineEventsEditor old, Set<TimelineEventsEditInfo> dependencies) {
    for (var depend in dependencies) {
      for (var updateWith in depend.updateWith) {
        switch (updateWith) {
          case TimelineEventsUpdateWith.trackHeaderWidth:
            if (this._trackHeaderWidth != old._update._trackHeaderWidth) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.scaleHedaerHeight:
            if (this._scaleHedaerHeight != old._update._scaleHedaerHeight) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.unitWidth:
            if (this._unitWidth != old._update._unitWidth) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.trackHeight:
            if (this._trackHeight != old._update._trackHeight) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.trackEnd:
            if (this._trackEnd != old._update._trackEnd) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.trackCount:
            if (this._trackEnd != old._update._trackEnd) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.elementSelection:
            if (this._elementSelectionsEquals(
              old._update,
              trackName: depend.trackName,
              element: depend.elementData,
            )) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.editedTrack:
            if (this._editedTracks.contains(depend.trackName)) {
              return true;
            }
            break;
          case TimelineEventsUpdateWith.editedElement:
            if (this._editedElements.contains(depend.elementData)) {
              return true;
            }
            break;
        }
      }
    }

    return false;
  }

  bool _elementSelectionsEquals(_TimelineEventsUpdateData other,
      {String? trackName, TimelineElementData? element}) {
    var thisSels = this._elementSelections;
    var otherSels = other._elementSelections;

    if (trackName != null) {
      var thisT = thisSels[trackName];
      var otherT = otherSels[trackName];

      if (element != null) {
        var thisE = thisT?[element];
        var otherE = otherT?[element];
        return thisE == otherE;
      }

      return mapEquals(
        thisT,
        otherT,
      );
    }

    return thisSels.entries.every((item) {
      return mapEquals(
        item.value,
        otherSels[item.key],
      );
    });
  }

  @override
  int get hashCode => hashValues(
        this._trackHeaderWidth,
        this._scaleHedaerHeight,
        this._unitWidth,
        this._trackHeight,
        this._trackEnd,
        this._trackCount,
      );
}

class TimelineEventsEditInfo {
  final Set<TimelineEventsUpdateWith> updateWith;
  final String? trackName;
  final TimelineElementData? elementData;

  const TimelineEventsEditInfo(
      {required this.updateWith, this.trackName, this.elementData});

  bool operator ==(dynamic other) {
    return (other is TimelineEventsEditInfo) &&
        setEquals(this.updateWith, other.updateWith) &&
        (this.trackName == other.trackName) &&
        (this.elementData == other.elementData);
  }

  @override
  int get hashCode => hashValues(hashList(updateWith), trackName, elementData);
}

typedef TimelineElementAction = void Function(
  TimelineElementData elementData,
  String trackName,
  bool isSelected,
);

class TimelineEventsEditor extends InheritedModel<TimelineEventsEditInfo> {
  final _TimelineEventsState _state;
  final _TimelineEventsUpdateData _update;

  TimelineEventsEditor._create(
    this._state,
    this._update,
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
      _TimelineEventsUpdateData(state),
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
  double get trackWidth => unitWidth * trackEnd.position;
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

  TimelineTrackState? getTrack(String trackName) => _state._tracks[trackName];

  void registerTrack(TimelineTrackState trackState) {
    _state._tracks[trackState.trackName] = trackState;
  }

  void edited({String? trackName, TimelineElementData? elementData}) {
    if (trackName != null) {
      _update._editedTracks.add(trackName);
    }
    if (elementData != null) {
      _update._editedElements.add(elementData);
    }
  }

  /// エレメントの選択状態を変更する
  bool setSelectedOfElement(
      String trackName, TimelineElementData elementData, bool isSelected) {
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
          sel.add(e);
          return true;
        }
        return false;
      });

      _notSelectedElements[element.key]?.removeWhere((e) {
        if (element.value.remove(e)) {
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
    var ret = _update != old._update;
    return ret;
  }

  @override
  bool updateShouldNotifyDependent(covariant TimelineEventsEditor old,
      Set<TimelineEventsEditInfo> dependencies) {
    return _update.updateShouldNotifyDependent(old, dependencies);
  }
}
