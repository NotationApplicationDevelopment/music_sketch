import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class MultiHeaderScrollView extends StatefulWidget {
  final Widget? leftHeader;
  final Widget? topHeader;
  final Widget? topLeftHeader;
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final Widget child;

  MultiHeaderScrollView({
    required this.child,
    this.leftHeader,
    this.topHeader,
    this.topLeftHeader,
    this.leftHeaderWidth = 0,
    this.topHeaderHeight = 0,
    Key? key,
  }) : super(key: key);

  @override
  _MultiHeaderScrollViewState createState() => _MultiHeaderScrollViewState();
}

class _MultiHeaderScrollViewState extends State<MultiHeaderScrollView> {
  Widget? get leftHeader => widget.leftHeader;
  Widget? get topHeader => widget.topHeader;
  Widget? get topLeftHeader => widget.topLeftHeader;
  double get leftHeaderWidth => widget.leftHeaderWidth;
  double get topHeaderHeight => widget.topHeaderHeight;
  Widget get child => widget.child;

  late LinkedScrollControllerGroup _scrollH;
  late LinkedScrollControllerGroup _scrollV;
  late ScrollController mainV;
  late ScrollController leftV;
  late ScrollController mainH;
  late ScrollController topH;

  _MultiHeaderScrollViewState();

  @override
  void initState() {
    super.initState();
    _scrollH = LinkedScrollControllerGroup();
    _scrollV = LinkedScrollControllerGroup();
    mainV = _scrollV.addAndGet();
    leftV = _scrollV.addAndGet();
    mainH = _scrollH.addAndGet();
    topH = _scrollH.addAndGet();
  }

  @override
  Widget build(BuildContext baseContext) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var mainWidth = constraints.maxWidth - leftHeaderWidth;
        var mainHeight = constraints.maxHeight - topHeaderHeight;
        return Row(
          children: [
            Container(
              width: leftHeaderWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //top left
                  Container(
                    height: topHeaderHeight,
                    child: topLeftHeader,
                  ),

                  //left
                  Container(
                    height: mainHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: leftV,
                      child: leftHeader,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: mainWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //top
                  Container(
                    height: topHeaderHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: topH,
                      child: topHeader,
                    ),
                  ),

                  //main
                  Container(
                    height: mainHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: mainV,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: mainH,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
