import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class MultiHeaderListView extends StatefulWidget {
  final List<Widget> leftHeaders;
  final List<Widget> topHeaders;
  final Widget? topLeftHeader;
  final Map<List<Widget>, Axis> mainChildren;
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final double scrollWidth;
  final double scrollHeight;
  final Offset scrollOffset;
  final LinkedScrollControllerGroup scrollH;
  final LinkedScrollControllerGroup scrollV;

  MultiHeaderListView({
    required this.mainChildren,
    required this.scrollWidth,
    required this.scrollHeight,
    required this.scrollH,
    required this.scrollV,
    required this.scrollOffset,
    this.leftHeaders = const [],
    this.topHeaders = const [],
    this.topLeftHeader,
    this.leftHeaderWidth = 0,
    this.topHeaderHeight = 0,
    Key? key,
  }) : super(key: key);

  @override
  _MultiHeaderListViewState createState() => _MultiHeaderListViewState();
}

class _MultiHeaderListViewState extends State<MultiHeaderListView> {
  List<Widget> get leftHeaders => widget.leftHeaders;
  List<Widget> get topHeaders => widget.topHeaders;
  Widget? get topLeftHeader => widget.topLeftHeader;
  double get leftHeaderWidth => widget.leftHeaderWidth;
  double get topHeaderHeight => widget.topHeaderHeight;
  Map<List<Widget>, Axis> get mainChildren => widget.mainChildren;
  double get scrollWidth => widget.scrollWidth;
  double get scrollHeight => widget.scrollHeight;

  LinkedScrollControllerGroup get scrollH => widget.scrollH;
  LinkedScrollControllerGroup get scrollV => widget.scrollV;
  late ScrollController topH;
  late ScrollController leftV;
  late List<ScrollController> mainH = [];
  late List<ScrollController> mainV = [];
  bool needInitChildrenState = true;
  @override
  void initState() {
    super.initState();
    topH = scrollH.addAndGet();
    leftV = scrollV.addAndGet();
    for (var i = 0; i < mainChildren.length; i++) {
      mainH.add(scrollH.addAndGet());
      mainV.add(scrollV.addAndGet());
    }
    Future.delayed(Duration(milliseconds: 10), () {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext baseContext) {
    if (needInitChildrenState) {
      var x = widget.scrollOffset.dx;
      var y = widget.scrollOffset.dy;
      scrollV.jumpTo(0);
      scrollH.jumpTo(0);
      var ret = _buildWithInitChildrenState(baseContext, true);
      needInitChildrenState = false;
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          scrollH.jumpTo(x);
          scrollV.jumpTo(y);
        });
      });

      return Opacity(
        child: ret,
        opacity: 0,
      );
    }
    needInitChildrenState = true;
    return Opacity(
      child: _buildWithInitChildrenState(baseContext, false),
      opacity: 1,
    );
  }

  Widget _buildWithInitChildrenState(
      BuildContext baseContext, bool initChildState) {
    const physics = BouncingScrollPhysics();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var mainWidth = constraints.maxWidth - leftHeaderWidth;
        var mainHeight = constraints.maxHeight - topHeaderHeight;

        var topLeft = SizedBox(
          width: leftHeaderWidth,
          height: topHeaderHeight,
          child: topLeftHeader,
        );

        var left = SizedBox(
          width: leftHeaderWidth,
          height: mainHeight,
          child: ListView(
            physics: physics,
            cacheExtent: 20,
            scrollDirection: Axis.vertical,
            controller: leftV,
            children: leftHeaders.map(
              (e) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: e,
                );
              },
            ).toList(),
          ),
        );

        var top = SizedBox(
          width: mainWidth,
          height: topHeaderHeight,
          child: ListView(
            physics: physics,
            cacheExtent: 20,
            scrollDirection: Axis.horizontal,
            controller: topH,
            children: topHeaders.map(
              (e) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: e,
                );
              },
            ).toList(),
          ),
        );

        int i = 0;
        var main = SizedBox(
          height: mainHeight,
          width: mainWidth,
          child: Stack(
            children: mainChildren.entries.map<Widget>((e) {
              List<Widget> children = e.key;
              Axis mainAxis = e.value;
              Axis subAxis;
              ScrollController mainController;
              ScrollController subController;
              switch (mainAxis) {
                case Axis.horizontal:
                  subAxis = Axis.vertical;
                  mainController = mainH[i];
                  subController = mainV[i];
                  break;

                case Axis.vertical:
                  subAxis = Axis.horizontal;
                  mainController = mainV[i];
                  subController = mainH[i];
                  break;
              }
              i++;
              return SingleChildScrollView(
                physics: physics,
                scrollDirection: subAxis,
                controller: subController,
                child: SizedBox(
                  height: scrollHeight,
                  width: scrollWidth,
                  child: ListView(
                    physics: physics,
                    cacheExtent: 20,
                    scrollDirection: mainAxis,
                    controller: mainController,
                    children: children.map((e) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: initChildState ? 0 : null,
                          height: initChildState ? 0 : null,
                          child: e,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        );

        return Row(
          children: [
            SizedBox(
              width: leftHeaderWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  topLeft,
                  left,
                ],
              ),
            ),
            SizedBox(
              width: mainWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  top,
                  main,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
