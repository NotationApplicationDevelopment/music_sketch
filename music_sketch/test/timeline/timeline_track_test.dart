import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_sketch/timeline/timeline_track.dart';

void main() {
  var element = TimelineTrack<int>.sample();

  testWidgets('timeline_track_widget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: element)));
  });
}
