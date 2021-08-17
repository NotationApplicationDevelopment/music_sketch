import 'timeline_times.dart';

abstract class TimelineDataFactry {
  Map<String, List<TimelineElementData>> getDatas();
}

class TimelineElementData {
  TimelinePositionRange positionRange;
  dynamic info;

  TimelineElementData(this.positionRange, this.info);

  bool operator ==(dynamic other) {
    return (other is TimelineElementData) &&
        (this.positionRange == other.positionRange) &&
        (this.info == other.info);
  }

  @override
  int get hashCode => positionRange.hashCode ^ info.hashCode;

}
