import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_sketch/timeline/timeline_data.dart';
import 'package:music_sketch/timeline/timeline_element_old.dart';
import 'package:music_sketch/timeline/timeline_times.dart';

void main() {
  var start = TimelinePosition.fromPosition(3);
  var end = TimelinePosition.fromPosition(6);
  var element = TimelineElement(
    elementData: TimelineElementData(
      TimelinePositionRange(start, end),
      null,
    ),
  );
  testWidgets('timeline_element_widget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: element));
  });
}
