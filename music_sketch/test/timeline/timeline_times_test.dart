import 'package:music_sketch/timeline/timeline_times.dart';
import 'package:test/test.dart';

void main() {
  // #region Init

  var timelinePositionA = TimelinePosition(1, 0);
  var timelinePositionA2 = TimelinePosition(1, 0);
  var timelinePositionB = TimelinePosition(2, 0.5);
  var timelinePositionB2 = TimelinePosition(2, 0.5);
  var timelineRangeA = TimelineRange(1, 0.5);
  var timelineRangeA2 = TimelineRange(1, 0.5);
  var timelineRangeB = TimelineRange(1, 1.5);
  var timelinePositionRangeA =
      TimelinePositionRange(timelinePositionA, timelinePositionB);
  var timelinePositionRangeA2 =
      TimelinePositionRange(timelinePositionA2, timelinePositionB2);
  var timelinePositionRangeB =
      TimelinePositionRange(timelinePositionB, timelinePositionA);

  // #endregion

  // #region Position
  test('timeline_times_position_to', () {
    var to = timelinePositionA.to(timelinePositionB);
    expect(to.range, 1 + 0.5);
  });

  test('timeline_times_position_from', () {
    var to = timelinePositionA.from(timelinePositionB);
    expect(to.range, -1 - 0.5);
  });

  test('timeline_times_position_getAsDateTime', () {
    var zero = DateTime.fromMicrosecondsSinceEpoch(0);
    var asDateTime = timelinePositionB.getAsDateTime(zero);
    expect(asDateTime.millisecondsSinceEpoch, 2500);
  });

  test('timeline_times_position_setAsDateTime', () {
    var zero = DateTime.fromMicrosecondsSinceEpoch(0);
    var pos = zero.add(Duration(seconds: 1));
    var fromDateTime = TimelinePosition.fromDateTime(pos, zero);
    expect(fromDateTime.position, 1.0);
  });

  test('timeline_times_position_==', () {
    expect(timelinePositionA == timelinePositionA2, true);
    expect(timelinePositionA == timelinePositionB, false);
  });
  test('timeline_times_position_>', () {
    expect(timelinePositionA > timelinePositionB, false);
    expect(timelinePositionB > timelinePositionA, true);
    expect(timelinePositionA > timelinePositionA2, false);
  });
  test('timeline_times_position_>=', () {
    expect(timelinePositionA >= timelinePositionB, false);
    expect(timelinePositionB >= timelinePositionA, true);
    expect(timelinePositionA >= timelinePositionA2, true);
  });
  test('timeline_times_position_<', () {
    expect(timelinePositionA < timelinePositionB, true);
    expect(timelinePositionB < timelinePositionA, false);
    expect(timelinePositionA < timelinePositionA2, false);
  });
  test('timeline_times_position_<=', () {
    expect(timelinePositionA <= timelinePositionB, true);
    expect(timelinePositionB <= timelinePositionA, false);
    expect(timelinePositionA <= timelinePositionA2, true);
  });
  // #endregion

  // #region Range
  test('timeline_times_range_getAsDuration', () {
    var asDuration = timelineRangeA.getAsDuration();
    expect(asDuration.inMilliseconds, 1500);
  });

  test('timeline_times_range_setAsDuration', () {
    var duration = Duration(milliseconds: 2500);
    var fromDuration = TimelineRange.fromDuration(duration);
    expect(fromDuration.range, 2.5);
  });
  
  test('timeline_times_range_==', () {
    expect(timelineRangeA == timelineRangeA2, true);
    expect(timelineRangeA == timelineRangeB, false);
  });

  test('timeline_times_range_>', () {
    expect(timelineRangeA > timelineRangeB, false);
    expect(timelineRangeB > timelineRangeA, true);
    expect(timelineRangeA > timelineRangeA2, false);
  });

  test('timeline_times_range_>=', () {
    expect(timelineRangeA >= timelineRangeB, false);
    expect(timelineRangeB >= timelineRangeA, true);
    expect(timelineRangeA >= timelineRangeA2, true);
  });

  test('timeline_times_range_<', () {
    expect(timelineRangeA < timelineRangeB, true);
    expect(timelineRangeB < timelineRangeA, false);
    expect(timelineRangeA < timelineRangeA2, false);
  });

  test('timeline_times_range_<=', () {
    expect(timelineRangeA <= timelineRangeB, true);
    expect(timelineRangeB <= timelineRangeA, false);
    expect(timelineRangeA <= timelineRangeA2, true);
  });

  // #endregion

  test('timeline_times_positionRange_fliped', () {
    var f = timelinePositionRangeA2.fliped();
    expect(f.start, timelinePositionRangeB.start);
    expect(f.end, timelinePositionRangeB.end);
  });

  test('timeline_times_positionRange_==', () {
    expect(timelinePositionRangeA == timelinePositionRangeA2, true);
    expect(timelinePositionRangeA == timelinePositionRangeB, false);
    expect(timelinePositionRangeA2 == timelinePositionRangeB, false);
  });
}
