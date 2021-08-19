import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

enum MultiHeaderListViewPosition {
  top,
  left,
  topLeft,
  view,
}

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
  final Size contentsSize;
  final EdgeInsets scrollMargin;
  final Widget? topLeftHeader;
  final Iterable<MultiHeaderListViewTrack> headers;
  final Iterable<MultiHeaderListViewTrack> mainChildren;

  MultiHeaderListView({
    required this.leftHeaderWidth,
    required this.topHeaderHeight,
    required this.contentsSize,
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
  Size get contentsSize => widget.contentsSize;
  EdgeInsets get scrollMargin => widget.scrollMargin;
  Widget? get topLeftHeader => widget.topLeftHeader;
  Iterable<MultiHeaderListViewTrack> get headers => widget.headers;
  Iterable<MultiHeaderListViewTrack> get mainChildren => widget.mainChildren;

  late final LinkedScrollControllerGroup _scrollHorizontal;
  late final LinkedScrollControllerGroup _scrollVertical;
  late final ScrollController viewScrollH;
  late final ScrollController viewScrollV;

  Size _viewSize = Size.zero;
  bool _isInit = true;
  Size _beforeContentsSize = Size(1, 1);
  List<MultiHeaderListViewTrack> topHeaders = [];
  List<MultiHeaderListViewTrack> leftHeaders = [];

  @override
  void initState() {
    super.initState();
    _scrollHorizontal = _initScrollGroup(
      () => _viewSize.width,
      () => contentsSize.width,
      () => scrollMargin.horizontal,
    );
    _scrollVertical = _initScrollGroup(
      () => _viewSize.height,
      () => contentsSize.height,
      () => scrollMargin.vertical,
    );

    viewScrollH = _scrollHorizontal.addAndGet();
    viewScrollV = _scrollVertical.addAndGet();
  }

  @override
  void dispose() {
    viewScrollH.dispose();
    viewScrollV.dispose();
    super.dispose();
  }

  static LinkedScrollControllerGroup _initScrollGroup(
    double Function() viewSize,
    double Function() contentsSize,
    double Function() scrollMargin,
  ) {
    var group = LinkedScrollControllerGroup();
    return group
      ..addOffsetChangedListener(
        () {
          double contents = contentsSize();
          double max = (viewSize() >= contents)
              ? 0
              : contents - viewSize() + scrollMargin();
          print("${group.offset} / $max");
          if (group.offset > max) {
            Future.microtask(() {
              group.jumpTo(max);
            });
          }
        },
      );
  }

  @override
  Widget build(BuildContext _) {
    if (_isInit) {
      _isInit = false;
    } else {
      var posH = _scrollHorizontal.offset *
          contentsSize.width /
          _beforeContentsSize.width;
      var posV = _scrollVertical.offset *
          contentsSize.height /
          _beforeContentsSize.height;
      _scrollHorizontal.jumpTo(posH);
      _scrollVertical.jumpTo(posV);
    }
    _beforeContentsSize = contentsSize;

    topHeaders = [];
    leftHeaders = [];
    for (var item in headers) {
      if (item.direction == Axis.horizontal) {
        topHeaders.add(item);
      } else {
        leftHeaders.add(item);
      }
    }
    return MultiHeaderListViewInfo(
      state: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var maxSize = Size(
            constraints.maxWidth,
            constraints.minHeight,
          );
          _viewSize = Size(
            maxSize.width - leftHeaderWidth,
            maxSize.height - topHeaderHeight,
          );

          var topLeft = const _ViewOfPosition(
            position: MultiHeaderListViewPosition.topLeft,
          );

          var left = const _ViewOfPosition(
            position: MultiHeaderListViewPosition.left,
          );

          var top = const _ViewOfPosition(
            position: MultiHeaderListViewPosition.top,
          );

          var view = const _ViewOfPosition(
            position: MultiHeaderListViewPosition.view,
          );

          return ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: leftHeaderWidth,
                  height: _viewSize.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: leftHeaderWidth,
                        height: topHeaderHeight,
                        child: topLeft,
                      ),
                      Expanded(child: left),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _viewSize.width,
                        height: topHeaderHeight,
                        child: top,
                      ),
                      Expanded(child: view),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ViewOfPosition extends StatelessWidget {
  final MultiHeaderListViewPosition position;

  const _ViewOfPosition({
    Key? key,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = MultiHeaderListViewInfo.of(
      context,
      position,
    );

    if (model == null) {
      return Text("not find MultiHeaderListViewInfo");
    }

    if (position == MultiHeaderListViewPosition.topLeft) {
      return model._state.topLeftHeader ?? SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size viewSize = Size(constraints.maxWidth, constraints.maxHeight);
        final Size scrollSize;
        final Axis axis;
        final Iterable<MultiHeaderListViewTrack> builders;
        switch (position) {
          case MultiHeaderListViewPosition.top:
            axis = Axis.horizontal;
            scrollSize = Size(model.scrollWidth, model.topHeaderHeight);
            builders = model._state.topHeaders;
            break;

          case MultiHeaderListViewPosition.left:
            axis = Axis.vertical;
            scrollSize = Size(model.leftHeaderWidth, model.scrollHeight);
            builders = model._state.leftHeaders;
            break;

          case MultiHeaderListViewPosition.view:
            axis = Axis.vertical;
            scrollSize = Size(model.scrollWidth, model.scrollHeight);
            builders = model._state.mainChildren;
            break;

          default:
            axis = Axis.vertical;
            scrollSize = Size.zero;
            builders = [];
            break;
        }

        if (builders.length == 0) {
          return SizedBox.fromSize(
            size: viewSize,
            child: Stack(
              children: [
                _CustomListView(
                  filling: true,
                  maxSize: scrollSize,
                  position: position,
                  builder: MultiHeaderListViewTrack.fromList(axis, []),
                ),
              ],
            ),
          );
        }

        var box = SizedBox.fromSize(
          size: viewSize,
          child: Stack(
            children: builders
                .map<Widget>(
                  (e) => _CustomListView(
                    filling: e == builders.last,
                    maxSize: scrollSize,
                    position: position,
                    builder: e,
                  ),
                )
                .toList(),
          ),
        );

        if (position != MultiHeaderListViewPosition.view) {
          return box;
        }

        return Stack(
          children: [
            box,
            _getScrollBar(Axis.vertical, model, viewSize, scrollSize, 20),
            _getScrollBar(Axis.horizontal, model, viewSize, scrollSize, 20),
          ],
        );
      },
    );
  }

  static Widget _getScrollBar(
    Axis axis,
    MultiHeaderListViewInfo model,
    Size viewSize,
    Size scrollSize,
    double thickness,
  ) {
    ScrollController controller;
    Size boxSize;
    double? scrollHeight;
    double? scrollWidth;

    switch (axis) {
      case Axis.horizontal:
        controller = model._state.viewScrollH;
        boxSize = Size(
          viewSize.width,
          thickness,
        );
        scrollWidth = scrollSize.width;
        break;
      case Axis.vertical:
        controller = model._state.viewScrollV;
        boxSize = Size(
          thickness,
          viewSize.height,
        );
        scrollHeight = scrollSize.height;
        break;
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox.fromSize(
        size: boxSize,
        child: Scrollbar(
          controller: controller,
          thickness: thickness,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: axis,
            child: SizedBox(
              width: scrollWidth,
              height: scrollHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomListView extends StatefulWidget {
  final MultiHeaderListViewTrack builder;
  final MultiHeaderListViewPosition position;
  final bool doPadding;
  final Size maxSize;
  final bool filling;
  const _CustomListView({
    required this.maxSize,
    required this.filling,
    required this.position,
    required this.builder,
    this.doPadding = true,
    Key? key,
  }) : super(key: key);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<_CustomListView> {
  MultiHeaderListViewTrack get builder => widget.builder;
  MultiHeaderListViewPosition get position => widget.position;
  bool get doPadding => widget.doPadding;
  Size get maxSize => widget.maxSize;
  bool get filling => widget.filling;
  ScrollController? _controller;
  ScrollController? _subController;
  double cacheExtent = double.infinity;

  @override
  void dispose() {
    _controller?.dispose();
    _subController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = MultiHeaderListViewInfo.of(
      context,
      position,
    );

    if (model == null) {
      return SizedBox();
    }

    if (builder.direction == Axis.horizontal) {
      if (_controller == null) {
        _controller = model.scrollHorizontal.addAndGet();
      }
    } else {
      if (_controller == null) {
        _controller = model.scrollVertical.addAndGet();
      }
    }

    var margin = model.scrollMargin;
    switch (position) {
      case MultiHeaderListViewPosition.top:
        margin = margin.copyWith(top: 0, bottom: 0);
        break;
      case MultiHeaderListViewPosition.left:
        margin = margin.copyWith(left: 0, right: 0);
        break;
      default:
        break;
    }

    var listView = ListView.custom(
      key: ValueKey(_controller),
      controller: _controller,
      physics: filling ? null : NeverScrollableScrollPhysics(),
      cacheExtent: cacheExtent,
      scrollDirection: builder.direction,
      childrenDelegate: _CustomChildrenDelegate(
        maxSize,
        filling,
        margin,
        doPadding,
        builder,
      ),
    );

    if (position != MultiHeaderListViewPosition.view) {
      return listView;
    }

    Axis subDirection;
    if (builder.direction == Axis.vertical) {
      subDirection = Axis.horizontal;
      if (_subController == null) {
        _subController = model.scrollHorizontal.addAndGet();
      }
    } else {
      subDirection = Axis.vertical;
      if (_subController == null) {
        _subController = model.scrollVertical.addAndGet();
      }
    }

    return SingleChildScrollView(
      key: ValueKey(_subController),
      controller: _subController,
      scrollDirection: subDirection,
      child: SizedBox(
        width: model.scrollWidth,
        height: model.scrollHeight,
        child: listView,
      ),
    );
  }
}

class _CustomChildrenDelegate extends SliverChildBuilderDelegate {
  _CustomChildrenDelegate(
    Size maxSize,
    bool filling,
    EdgeInsets margin,
    bool doPadding,
    MultiHeaderListViewTrack builder,
  ) : super(
          (c, i) {
            if (filling && i == builder.count) {
              return SizedBox.fromSize(size: maxSize);
            }

            EdgeInsets padding;

            if (doPadding) {
              if (builder.direction == Axis.horizontal) {
                padding = EdgeInsets.only(
                  top: margin.top,
                  bottom: margin.bottom,
                );

                if (i == 0) {
                  padding += EdgeInsets.only(left: margin.left);
                } else if (i == builder.count - 1) {
                  padding += EdgeInsets.only(right: margin.right);
                }
              } else {
                padding = EdgeInsets.only(
                  left: margin.left,
                  right: margin.right,
                );

                if (i == 0) {
                  padding += EdgeInsets.only(top: margin.top);
                } else if (i == builder.count - 1) {
                  padding += EdgeInsets.only(bottom: margin.bottom);
                }
              }
            } else {
              padding = EdgeInsets.zero;
            }

            return Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.topLeft,
                child: builder.builder(c, i),
              ),
            );
          },
          childCount: filling ? builder.count + 1 : builder.count,
        );
}

class MultiHeaderListViewInfo
    extends InheritedModel<MultiHeaderListViewPosition> {
  final _MultiHeaderListViewState _state;
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final Size contentsSize;
  final EdgeInsets scrollMargin;
  final LinkedScrollControllerGroup scrollHorizontal;
  final LinkedScrollControllerGroup scrollVertical;

  MultiHeaderListViewInfo._(
    this._state, {
    required this.leftHeaderWidth,
    required this.topHeaderHeight,
    required this.contentsSize,
    required this.scrollMargin,
    required this.scrollHorizontal,
    required this.scrollVertical,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  MultiHeaderListViewInfo(
      {required _MultiHeaderListViewState state,
      required Widget child,
      Key? key})
      : this._(
          state,
          leftHeaderWidth: state.leftHeaderWidth,
          topHeaderHeight: state.topHeaderHeight,
          contentsSize: state.contentsSize,
          scrollMargin: state.scrollMargin,
          scrollHorizontal: state._scrollHorizontal,
          scrollVertical: state._scrollVertical,
          child: child,
          key: key,
        );

  double get scrollWidth => contentsSize.width + scrollMargin.horizontal;
  double get scrollHeight => contentsSize.height + scrollMargin.vertical;

  static MultiHeaderListViewInfo? of(
      BuildContext context, MultiHeaderListViewPosition aspect) {
    return InheritedModel.inheritFrom<MultiHeaderListViewInfo>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotify(covariant MultiHeaderListViewInfo old) {
    var ret = (contentsSize != old.contentsSize) ||
        (topHeaderHeight != old.topHeaderHeight) ||
        (leftHeaderWidth != old.leftHeaderWidth);
    return ret;
  }

  @override
  bool updateShouldNotifyDependent(covariant MultiHeaderListViewInfo old,
      Set<MultiHeaderListViewPosition> dependencies) {
    for (var depend in dependencies) {
      switch (depend) {
        case MultiHeaderListViewPosition.topLeft:
          if ((leftHeaderWidth != old.leftHeaderWidth) ||
              (topHeaderHeight != old.topHeaderHeight)) {
            return true;
          }
          break;

        case MultiHeaderListViewPosition.top:
          if ((contentsSize.width != old.contentsSize.width) ||
              (topHeaderHeight != old.topHeaderHeight)) {
            return true;
          }
          break;

        case MultiHeaderListViewPosition.left:
          if ((leftHeaderWidth != old.leftHeaderWidth) ||
              (contentsSize.height != old.contentsSize.height)) {
            return true;
          }
          break;

        case MultiHeaderListViewPosition.view:
          if (contentsSize != old.contentsSize) {
            return true;
          }
          break;
      }
    }
    return false;
  }
}
