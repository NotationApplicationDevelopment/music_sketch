import 'timeline_times.dart';

abstract class TimelineDataFactry {
  Map<String, List<TimelineElementData>> getDatas();
}

class TimelineElementData {
  TimelinePositionRange positionRange;
  dynamic info;

  TimelineElementData(this.positionRange, this.info);
}

class TimelineData {
  late final Map<String, List<TimelineElementData>> dataList;
  final TimelineDataFactry factry;

  TimelineData(this.factry, {Map<String, List<TimelineElementData>>? dataList}) {
    this.dataList = dataList ?? {};
  }

  void update() {
    dataList.clear();
    dataList.addAll(factry.getDatas());
  }
}
