import 'package:music_sketch/timeline/timeline_data.dart';
import 'package:music_sketch/timeline/timeline_times.dart';
import 'package:test/test.dart';

class _TestFuctry extends TimelineDataFactry {
  Map<String, List<TimelineElementData>> datas = {"0": []};
  @override
  Map<String, List<TimelineElementData>> getDatas() {
    return datas;
  }

  void add(TimelineElementData data) {
    datas["0"]!.add(data);
  }

  void set(int index, TimelineElementData data) {
    datas["0"]![index] = data;
  }

  void reset() {
    datas = {"0": []};
  }
}

void main() {
  var fact = _TestFuctry();
  var timelineData = TimelineData(fact);
  var data1 = TimelineElementData(
      TimelinePositionRange(TimelinePosition(0, 0), TimelinePosition(0, 0)),
      "test1");
  var data2 = TimelineElementData(
      TimelinePositionRange(TimelinePosition(0, 0), TimelinePosition(0, 0)),
      "test2");

  test('timeline_data_test_add', () {
    fact.add(data1);
    timelineData.update();
    expect(timelineData.dataList["0"]?[0].info, "test1");
  });

  test('timeline_data_test_set', () {
    fact.set(0, data2);
    timelineData.update();
    expect(timelineData.dataList["0"]?[0].info, "test2");
  });

  test('timeline_data_test_reset', () {
    fact.reset();
    timelineData.update();
    expect(timelineData.dataList["0"]?.length, 0);
  });
}
