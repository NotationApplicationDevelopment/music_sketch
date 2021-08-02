import 'package:flutter/material.dart';
import 'single_timeline.dart';

class MultiTimeline extends StatelessWidget {
  late final List<SingleTimeline> lines;

  MultiTimeline.test(int lineCount, {Key? key}) : super(key: key) {
    lines =
        List<SingleTimeline>.generate(lineCount, (i) => SingleTimeline.test());
  }

  MultiTimeline.empty(int lineCount, {Key? key}) : super(key: key) {
    lines =
        List<SingleTimeline>.generate(lineCount, (i) => SingleTimeline.empty());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lines,
    );
  }
}
