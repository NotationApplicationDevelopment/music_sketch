import 'package:flutter/widgets.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class MultiHeaderListViewTrack {
  final Axis direction;
  final int count;
  final NullableIndexedWidgetBuilder builder;
  MultiHeaderListViewTrack(this.direction, this.count, this.builder);

  factory MultiHeaderListViewTrack.fromList(
      Axis direction, Iterable<Widget> list) {
    return MultiHeaderListViewTrack(
      direction,
      list.length,
      (_, index) {
        return list.elementAt(index);
      },
    );
  }
}

class MultiHeaderListView extends StatefulWidget {
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final double contentsWidth;
  final double contentsHeight;
  final EdgeInsets scrollMargin;
  final Widget? topLeftHeader;
  final Iterable<MultiHeaderListViewTrack> headers;
  final Iterable<MultiHeaderListViewTrack> mainChildren;

  MultiHeaderListView({
    required this.leftHeaderWidth,
    required this.topHeaderHeight,
    required this.contentsWidth,
    required this.contentsHeight,
    required this.scrollMargin,
    required this.topLeftHeader,
    required this.headers,
    required this.mainChildren,
    Key? key,
  }) : super(key: key);
  @override
  _MultiHeaderListViewState createState() => _MultiHeaderListViewState();
}

class _MultiHeaderListViewState extends State<MultiHeaderListView> {
  double get leftHeaderWidth => widget.leftHeaderWidth;
  double get topHeaderHeight => widget.topHeaderHeight;
  double get contentsWidth => widget.contentsWidth;
  double get contentsHeight => widget.contentsHeight;
  EdgeInsets get scrollMargin => widget.scrollMargin;
  Widget? get topLeftHeader => widget.topLeftHeader;
  Iterable<MultiHeaderListViewTrack> get headers => widget.headers;
  Iterable<MultiHeaderListViewTrack> get mainChildren => widget.mainChildren;

  late final LinkedScrollControllerGroup scrollHorizontal;
  late final LinkedScrollControllerGroup scrollVertical;

  @override
  void initState() {
    super.initState();
    scrollHorizontal = LinkedScrollControllerGroup();
    scrollVertical = LinkedScrollControllerGroup();
  }

  @override
  Widget build(BuildContext _) {
    List<MultiHeaderListViewTrack> topHeaders = [];
    List<MultiHeaderListViewTrack> leftHeaders = [];
    for (var item in headers) {
      if (item.direction == Axis.horizontal) {
        topHeaders.add(item);
      } else {
        leftHeaders.add(item);
      }
    }
    return _Model(
      scrollMargin: scrollMargin,
      scrollHorizontal: scrollHorizontal,
      scrollVertical: scrollVertical,
      contentsHeight: contentsHeight + scrollMargin.vertical,
      contentsWidth: contentsWidth + scrollMargin.horizontal,
      leftHeaderWidth: leftHeaderWidth,
      topHeaderHeight: topHeaderHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var maxWidth = constraints.maxWidth;
          var maxHeight = constraints.minHeight;
          var viewWidth = maxWidth - leftHeaderWidth;
          var viewHeight = maxHeight - topHeaderHeight;

          var topLeft = _TopLeft(topLeftHeader);

          var left = _CustomListViewStack(
            dependencies: _Dependencies.left,
            width: leftHeaderWidth,
            height: viewHeight,
            builder: leftHeaders,
          );

          var top = _CustomListViewStack(
            dependencies: _Dependencies.top,
            width: viewWidth,
            height: topHeaderHeight,
            builder: topHeaders,
          );

          var view = _CustomListViewStack(
            dependencies: _Dependencies.view,
            width: viewWidth,
            height: viewHeight,
            builder: mainChildren,
          );

          return Row(
            children: [
              SizedBox(
                width: leftHeaderWidth,
                height: maxHeight,
                child: Column(
                  children: [
                    topLeft,
                    left,
                  ],
                ),
              ),
              SizedBox(
                width: viewWidth,
                height: maxHeight,
                child: Column(
                  children: [
                    top,
                    view,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopLeft extends StatelessWidget {
  final Widget? child;
  const _TopLeft(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = _Model.of(
      context,
      _Dependencies.topLeft,
    );
    return SizedBox(
      width: model?.leftHeaderWidth,
      height: model?.topHeaderHeight,
      child: child,
    );
  }
}

class _CustomListViewStack extends StatelessWidget {
  final Iterable<MultiHeaderListViewTrack> builder;
  final double height;
  final double width;
  final _Dependencies dependencies;

  const _CustomListViewStack({
    Key? key,
    required this.height,
    required this.width,
    required this.dependencies,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: builder
            .map(
              (e) => _CustomListView(dependencies: dependencies, builder: e),
            )
            .toList(),
      ),
    );
  }
}

class _CustomListView extends StatefulWidget {
  final MultiHeaderListViewTrack builder;
  final _Dependencies dependencies;

  const _CustomListView({
    required this.dependencies,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<_CustomListView> {
  MultiHeaderListViewTrack get builder => widget.builder;
  _Dependencies get dependencies => widget.dependencies;
  ScrollController? _controller;
  ScrollController? _controller2;

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller2?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = _Model.of(
      context,
      dependencies,
    );
    double? scrollSize;
    Axis direction2;
    if (builder.direction == Axis.horizontal) {
      direction2 = Axis.vertical;
      scrollSize = model?.contentsWidth;
      _controller = _controller ?? model?.scrollHorizontal.addAndGet();
      _controller2 = _controller2 ?? model?.scrollVertical.addAndGet();
    } else {
      direction2 = Axis.horizontal;
      scrollSize = model?.contentsHeight;
      _controller = _controller ?? model?.scrollVertical.addAndGet();
      _controller2 = _controller2 ?? model?.scrollHorizontal.addAndGet();
    }

    var listView = ListView.custom(
      key: ValueKey(_controller),
      controller: _controller,
      cacheExtent: 20,
      scrollDirection: builder.direction,
      childrenDelegate: _CustomChildrenDelegate(
          scrollSize ?? 0, model?.scrollMargin ?? EdgeInsets.zero, builder),
    );

    if (dependencies != _Dependencies.view) {
      return listView;
    }
    return SingleChildScrollView(
      key: ValueKey(_controller2),
      controller: _controller2,
      scrollDirection: direction2,
      child: SizedBox(
        width: model?.contentsWidth,
        height: model?.contentsHeight,
        child: listView,
      ),
    );
  }
}

class _CustomChildrenDelegate extends SliverChildBuilderDelegate {
  final double scrollSize;
  final EdgeInsets margin;
  _CustomChildrenDelegate(
    this.scrollSize,
    this.margin,
    MultiHeaderListViewTrack builder,
  ) : super(
          (c, i) {
            if (builder.direction == Axis.horizontal) {
              if (i == 0) {
                return SizedBox(
                  width: margin.left,
                  height: 0,
                );
              }
              if (i == builder.count + 1) {
                return SizedBox(
                  width: margin.right,
                  height: 0,
                );
              }

              return Padding(
                padding: EdgeInsets.only(top: margin.top),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: builder.builder(c, i - 1),
                ),
              );
            } else {
              if (i == 0) {
                return SizedBox(
                  width: 0,
                  height: margin.top,
                );
              }
              if (i == builder.count + 1) {
                return SizedBox(
                  width: 0,
                  height: margin.bottom,
                );
              }

              return Padding(
                padding: EdgeInsets.only(left: margin.left),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: builder.builder(c, i - 1),
                ),
              );
            }
          },
          childCount: builder.count + 2,
        );

  @override
  double? estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    return scrollSize;
  }
}

enum _Dependencies {
  top,
  left,
  topLeft,
  view,
}

class _Model extends InheritedModel<_Dependencies> {
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final double contentsHeight;
  final double contentsWidth;
  final EdgeInsets scrollMargin;
  final LinkedScrollControllerGroup scrollHorizontal;
  final LinkedScrollControllerGroup scrollVertical;

  _Model({
    required this.leftHeaderWidth,
    required this.topHeaderHeight,
    required this.contentsHeight,
    required this.contentsWidth,
    required this.scrollMargin,
    required this.scrollHorizontal,
    required this.scrollVertical,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  static _Model? of(BuildContext context, _Dependencies aspect) {
    return InheritedModel.inheritFrom<_Model>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotify(covariant _Model old) {
    return (contentsHeight != old.contentsHeight) ||
        (contentsWidth != old.contentsWidth) ||
        (topHeaderHeight != old.topHeaderHeight) ||
        (leftHeaderWidth != old.leftHeaderWidth);
  }

  @override
  bool updateShouldNotifyDependent(
      covariant _Model old, Set<_Dependencies> dependencies) {
    for (var depend in dependencies) {
      switch (depend) {
        case _Dependencies.top:
          if ((contentsWidth != old.contentsWidth) ||
              (topHeaderHeight != old.topHeaderHeight)) {
            return true;
          }
          break;

        case _Dependencies.left:
          if ((leftHeaderWidth != old.leftHeaderWidth) ||
              (contentsHeight != old.contentsHeight)) {
            return true;
          }
          break;

        case _Dependencies.topLeft:
          if ((leftHeaderWidth != old.leftHeaderWidth) ||
              (topHeaderHeight != old.topHeaderHeight)) {
            return true;
          }
          break;
        case _Dependencies.view:
          if ((contentsWidth != old.contentsWidth) ||
              (contentsHeight != old.contentsHeight)) {
            return true;
          }
          break;
      }
    }
    return false;
  }
}
