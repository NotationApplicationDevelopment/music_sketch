import 'timeline_times.dart';

abstract class TimelineDataFactry {
  Map<String, List<TimelineElementData>> getDatas();
}

class TimelineElementData {
  TimelinePositionRange positionRange;
  dynamic info;

  TimelineElementData(this.positionRange, this.info);
}
