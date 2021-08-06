import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_sketch/timeline/timeline_events.dart';

void main() {
  var element = TimelineEvents<int>.sample(5);

  testWidgets('timeline_events_widget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: element));
  });
}
