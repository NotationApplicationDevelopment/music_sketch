import 'package:flutter/material.dart';
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

  late final LinkedScrollControllerGroup _scrollHorizontal;
  late final LinkedScrollControllerGroup _scrollVertical;
  double _viewWidth = 0;
  double _viewHeight = 0;
  bool _isInit = true;
  double _beforeContentsWidth = 1;
  double _beforeContentsHeight = 1;
  List<MultiHeaderListViewTrack> topHeaders = [];
  List<MultiHeaderListViewTrack> leftHeaders = [];

  @override
  void initState() {
    super.initState();
    _scrollHorizontal = _initScrollGroup(
        () => _viewWidth, contentsWidth, scrollMargin.horizontal);
    _scrollVertical = _initScrollGroup(
        () => _viewHeight, contentsHeight, scrollMargin.vertical);
  }

  static LinkedScrollControllerGroup _initScrollGroup(
    double Function() viewSize,
    double contentsSize,
    double scrollMargin,
  ) {
    var group = LinkedScrollControllerGroup();
    return group
      ..addOffsetChangedListener(() {
        double max = (viewSize() >= contentsSize)
            ? 0
            : contentsSize - viewSize() + scrollMargin;

        if (group.offset > max) {
          Future.microtask(() {
            group.jumpTo(max);
          });
        }
      });
  }

  @override
  Widget build(BuildContext _) {
    if (_isInit) {
      _isInit = false;
    } else {
      var posH =
          _scrollHorizontal.offset * contentsWidth / _beforeContentsWidth;
      var posV =
          _scrollVertical.offset * contentsHeight / _beforeContentsHeight;
      _scrollHorizontal.jumpTo(posH);
      _scrollVertical.jumpTo(posV);
    }
    _beforeContentsWidth = contentsWidth;
    _beforeContentsHeight = contentsHeight;

    topHeaders = [];
    leftHeaders = [];
    for (var item in headers) {
      if (item.direction == Axis.horizontal) {
        topHeaders.add(item);
      } else {
        leftHeaders.add(item);
      }
    }
    return _Model(
      state: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var maxWidth = constraints.maxWidth;
          var maxHeight = constraints.minHeight;
          _viewWidth = maxWidth - leftHeaderWidth;
          _viewHeight = maxHeight - topHeaderHeight;

          var topLeft = const _ViewOfPosition(
            position: MultiHeaderViewPosition.topLeft,
          );

          var left = const _ViewOfPosition(
            position: MultiHeaderViewPosition.left,
          );

          var top = const _ViewOfPosition(
            position: MultiHeaderViewPosition.top,
          );

          var view = const _ViewOfPosition(
            position: MultiHeaderViewPosition.view,
          );

          return ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Row(
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
                  width: _viewWidth,
                  height: maxHeight,
                  child: Column(
                    children: [
                      top,
                      view,
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
  final MultiHeaderViewPosition position;

  const _ViewOfPosition({
    Key? key,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Iterable<MultiHeaderListViewTrack> builders;
    final double height;
    final double width;

    var model = _Model.of(
      context,
      position,
    );

    if (model == null) {
      height = 0;
      width = 0;
      builders = [];
    } else {
      switch (position) {
        case MultiHeaderViewPosition.top:
          height = model.topHeaderHeight;
          width = model._state._viewWidth;
          builders = model._state.topHeaders;
          break;
        case MultiHeaderViewPosition.left:
          height = model._state._viewHeight;
          width = model.leftHeaderWidth;
          builders = model._state.leftHeaders;
          break;
        case MultiHeaderViewPosition.view:
          height = model._state._viewHeight;
          width = model._state._viewWidth;
          builders = model._state.mainChildren;
          break;
        case MultiHeaderViewPosition.topLeft:
          return SizedBox(
            width: model.leftHeaderWidth,
            height: model.topHeaderHeight,
            child: model._state.topLeftHeader,
          );
      }
    }
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: builders
            .map(
              (e) => _CustomListView(position: position, builder: e),
            )
            .toList(),
      ),
    );
  }
}

class _CustomListView extends StatefulWidget {
  final MultiHeaderListViewTrack builder;
  final MultiHeaderViewPosition position;

  const _CustomListView({
    required this.position,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<_CustomListView> {
  MultiHeaderListViewTrack get builder => widget.builder;
  MultiHeaderViewPosition get position => widget.position;
  ScrollController? _controller;
  ScrollController? _subController;
  double cacheExtent = double.infinity;

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _subController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = _Model.of(
      context,
      position,
    );

    if (model == null) {
      return SizedBox();
    }

    double? scrollSize;

    if (builder.direction == Axis.horizontal) {
      scrollSize = model.scrollWidth;
      if (_controller == null) {
        _controller = model.scrollHorizontal.addAndGet();
      }
    } else {
      scrollSize = model.scrollHeight;
      if (_controller == null) {
        _controller = model.scrollVertical.addAndGet();
      }
    }

    var margin = model.scrollMargin;
    switch (position) {
      case MultiHeaderViewPosition.top:
        margin = margin.copyWith(top: 0, bottom: 0);
        break;
      case MultiHeaderViewPosition.left:
        margin = margin.copyWith(left: 0, right: 0);
        break;
      default:
        break;
    }

    var listView = ListView.custom(
      key: ValueKey(_controller),
      controller: _controller,
      cacheExtent: cacheExtent,
      scrollDirection: builder.direction,
      childrenDelegate: _CustomChildrenDelegate(
        scrollSize,
        margin,
        builder,
      ),
    );

    if (position != MultiHeaderViewPosition.view) {
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
  final double scrollSize;
  final EdgeInsets margin;
  _CustomChildrenDelegate(
    this.scrollSize,
    this.margin,
    MultiHeaderListViewTrack builder,
  ) : super(
          (c, i) {
            EdgeInsets padding;
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

            return Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.topLeft,
                child: builder.builder(c, i),
              ),
            );
          },
          childCount: builder.count,
        );

  @override
  double? estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    return scrollSize;
  }
}

enum MultiHeaderViewPosition {
  top,
  left,
  topLeft,
  view,
}

class _Model extends InheritedModel<MultiHeaderViewPosition> {
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final double contentsHeight;
  final double contentsWidth;
  final EdgeInsets scrollMargin;
  final LinkedScrollControllerGroup scrollHorizontal;
  final LinkedScrollControllerGroup scrollVertical;
  final _MultiHeaderListViewState _state;

  _Model._(
    this._state, {
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

  _Model(
      {required _MultiHeaderListViewState state,
      required Widget child,
      Key? key})
      : this._(
          state,
          leftHeaderWidth: state.leftHeaderWidth,
          topHeaderHeight: state.topHeaderHeight,
          contentsHeight: state.contentsHeight,
          contentsWidth: state.contentsWidth,
          scrollMargin: state.scrollMargin,
          scrollHorizontal: state._scrollHorizontal,
          scrollVertical: state._scrollVertical,
          child: child,
          key: key,
        );

  double get scrollWidth => contentsWidth + scrollMargin.horizontal;
  double get scrollHeight => contentsHeight + scrollMargin.vertical;

  static _Model? of(BuildContext context, MultiHeaderViewPosition aspect) {
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
      covariant _Model old, Set<MultiHeaderViewPosition> dependencies) {
    for (var depend in dependencies) {
      switch (depend) {
        case MultiHeaderViewPosition.top:
          if ((contentsWidth != old.contentsWidth) ||
              (topHeaderHeight != old.topHeaderHeight)) {
            return true;
          }
          break;

        case MultiHeaderViewPosition.left:
          if ((leftHeaderWidth != old.leftHeaderWidth) ||
              (contentsHeight != old.contentsHeight)) {
            return true;
          }
          break;

        case MultiHeaderViewPosition.topLeft:
          if ((leftHeaderWidth != old.leftHeaderWidth) ||
              (topHeaderHeight != old.topHeaderHeight)) {
            return true;
          }
          break;
        case MultiHeaderViewPosition.view:
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
