import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

enum MultiHeaderListViewPosition {
  top,
  left,
  topLeft,
  view,
}

enum MultiHeaderListViewUpdateType {
  contentsWidth,
  contentsHeight,
  leftHeaderWidth,
  topHeaderHeight,
  none,
}

class MultiHeaderListViewTrack {
  final Axis direction;
  final int Function() count;
  final NullableIndexedWidgetBuilder builder;
  MultiHeaderListViewTrack(this.direction, this.count, this.builder);

  factory MultiHeaderListViewTrack.fromList(
      Axis direction, Iterable<Widget> list) {
    return MultiHeaderListViewTrack(
      direction,
      () => list.length,
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
  Size _scrollMax = Size.zero;
  bool _isInit = true;
  Size _beforeContentsSize = Size(1, 1);
  List<MultiHeaderListViewTrack> topHeaders = [];
  List<MultiHeaderListViewTrack> leftHeaders = [];

  @override
  void initState() {
    super.initState();
    _scrollHorizontal = LinkedScrollControllerGroup();
    _scrollVertical = LinkedScrollControllerGroup();
    viewScrollH = _scrollHorizontal.addAndGet();
    viewScrollV = _scrollVertical.addAndGet();
  }

  @override
  void dispose() {
    viewScrollH.dispose();
    viewScrollV.dispose();
    super.dispose();
  }

  ScrollController _getScroller(Axis axis) {
    var controller =
        (axis == Axis.horizontal ? _scrollHorizontal : _scrollVertical)
            .addAndGet();
    controller.addListener(
      () {
        double max;
        switch (axis) {
          case Axis.horizontal:
            max = _scrollMax.width;
            break;
          case Axis.vertical:
            max = _scrollMax.height;
            break;
        }

        var p = controller.position;
        print("${p.maxScrollExtent} / $max");
        if (p.maxScrollExtent < max) {
          print("extent");
          Future.microtask(() {
            //無限ループ回避の条件
            if (p.maxScrollExtent < max) {
              p.applyContentDimensions(p.minScrollExtent, max);
            }
          });
        }
        if (p.pixels > max) {
          Future.microtask(() {
            //無限ループ回避の条件
            if (p.pixels > max) {
              p.applyContentDimensions(p.minScrollExtent, max);
              p.correctPixels(max);
              p.notifyListeners();
              print("over max");
            }
          });
        }
      },
    );

    return controller;
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
          _viewSize = Size(
            constraints.maxWidth - leftHeaderWidth,
            constraints.maxHeight - topHeaderHeight,
          );

          _scrollMax = Size(
            max(0.0,
                contentsSize.width - _viewSize.width + scrollMargin.horizontal).ceilToDouble(),
            max(0.0,
                contentsSize.height - _viewSize.height + scrollMargin.vertical).ceilToDouble(),
          );

          var topLeft = const _ViewOfPosition(
            key: ValueKey(MultiHeaderListViewPosition.topLeft),
            position: MultiHeaderListViewPosition.topLeft,
          );

          var left = const _ViewOfPosition(
            key: ValueKey(MultiHeaderListViewPosition.left),
            position: MultiHeaderListViewPosition.left,
          );

          var top = const _ViewOfPosition(
            key: ValueKey(MultiHeaderListViewPosition.top),
            position: MultiHeaderListViewPosition.top,
          );

          var view = const _ViewOfPosition(
            key: ValueKey(MultiHeaderListViewPosition.view),
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
      MultiHeaderListViewUpdateType.none,
    );

    if (model == null) {
      return Text("not find MultiHeaderListViewInfo");
    }

    if (position == MultiHeaderListViewPosition.topLeft) {
      return model._state.topLeftHeader ?? SizedBox();
    }
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
      return SizedBox.expand(
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

    var box = SizedBox.expand(
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
        _getScrollBar(Axis.vertical, model, scrollSize, 20),
        _getScrollBar(Axis.horizontal, model, scrollSize, 20),
      ],
    );
  }

  static Widget _getScrollBar(
    Axis axis,
    MultiHeaderListViewInfo model,
    Size scrollSize,
    double thickness,
  ) {
    ScrollController controller;
    Size boxSize;
    MultiHeaderListViewUpdateType updateType;
    switch (axis) {
      case Axis.horizontal:
        controller = model._state.viewScrollH;
        boxSize = Size(
          double.infinity,
          thickness,
        );
        updateType = MultiHeaderListViewUpdateType.contentsWidth;
        break;
      case Axis.vertical:
        controller = model._state.viewScrollV;
        boxSize = Size(
          thickness,
          double.infinity,
        );
        updateType = MultiHeaderListViewUpdateType.contentsHeight;
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
            child: Builder(builder: (context) {
              var model = MultiHeaderListViewInfo.of(context, updateType);
              return SizedBox(
                width: model!.scrollWidth,
                height: model.scrollHeight,
              );
            }),
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
      MultiHeaderListViewUpdateType.none,
    );

    if (model == null) {
      return SizedBox();
    }

    if (builder.direction == Axis.horizontal) {
      if (_controller == null) {
        _controller = model._state._getScroller(Axis.horizontal);
      }
    } else {
      if (_controller == null) {
        _controller = model._state._getScroller(Axis.vertical);
      }
    }

    var margin = model._state.scrollMargin;
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
        _controller!,
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

    MultiHeaderListViewUpdateType updateType;
    Axis subDirection;
    if (builder.direction == Axis.vertical) {
      subDirection = Axis.horizontal;
      updateType = MultiHeaderListViewUpdateType.contentsWidth;
      if (_subController == null) {
        _subController = model._state._getScroller(Axis.horizontal);
      }
    } else {
      subDirection = Axis.vertical;
      updateType = MultiHeaderListViewUpdateType.contentsHeight;
      if (_subController == null) {
        _subController = model._state._getScroller(Axis.vertical);
      }
    }

    return SingleChildScrollView(
      key: ValueKey(_subController),
      controller: _subController,
      scrollDirection: subDirection,
      child: Builder(builder: (context) {
        MultiHeaderListViewInfo.of(context, updateType);
        return SizedBox(
          width: model.scrollWidth,
          height: model.scrollHeight,
          child: listView,
        );
      }),
    );
  }
}

class _CustomChildrenDelegate extends SliverChildBuilderDelegate {
  _CustomChildrenDelegate(
    ScrollController controller,
    Size maxSize,
    bool filling,
    EdgeInsets margin,
    bool doPadding,
    MultiHeaderListViewTrack _builder,
  ) : super(
          (c, i) => myBuilder(
              c, i, controller, maxSize, filling, margin, doPadding, _builder),
          childCount: filling ? _builder.count() + 1 : _builder.count(),
        );

  static Widget myBuilder(
      BuildContext c,
      int i,
      ScrollController controller,
      Size maxSize,
      bool filling,
      EdgeInsets margin,
      bool doPadding,
      MultiHeaderListViewTrack builder) {
    if (filling && i == builder.count()) {
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
        } else if (i == builder.count() - 1) {
          padding += EdgeInsets.only(right: margin.right);
        }
      } else {
        padding = EdgeInsets.only(
          left: margin.left,
          right: margin.right,
        );

        if (i == 0) {
          padding += EdgeInsets.only(top: margin.top);
        } else if (i == builder.count() - 1) {
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
  }
}

class MultiHeaderListViewInfo
    extends InheritedModel<MultiHeaderListViewUpdateType> {
  final _MultiHeaderListViewState _state;
  final double leftHeaderWidth;
  final double topHeaderHeight;
  final double contentsWidth;
  final double contentsHeight;

  MultiHeaderListViewInfo._(
    this._state, {
    required this.leftHeaderWidth,
    required this.topHeaderHeight,
    required this.contentsWidth,
    required this.contentsHeight,
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
          contentsWidth: state.contentsSize.width,
          contentsHeight: state.contentsSize.height,
          child: child,
          key: key,
        );

  double get scrollWidth =>
      _state.contentsSize.width + _state.scrollMargin.horizontal;
  double get scrollHeight =>
      _state.contentsSize.height + _state.scrollMargin.vertical;

  static MultiHeaderListViewInfo? of(
      BuildContext context, MultiHeaderListViewUpdateType aspect) {
    return InheritedModel.inheritFrom<MultiHeaderListViewInfo>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotify(covariant MultiHeaderListViewInfo old) {
    var ret = (topHeaderHeight != old.topHeaderHeight) ||
        (leftHeaderWidth != old.leftHeaderWidth) ||
        (contentsWidth != old.contentsWidth) ||
        (contentsHeight != old.contentsHeight);
    return ret;
  }

  @override
  bool updateShouldNotifyDependent(covariant MultiHeaderListViewInfo old,
      Set<MultiHeaderListViewUpdateType> dependencies) {
    for (var depend in dependencies) {
      switch (depend) {
        case MultiHeaderListViewUpdateType.contentsWidth:
          if (contentsWidth != old.contentsWidth) {
            return true;
          }
          break;
        case MultiHeaderListViewUpdateType.contentsHeight:
          if (contentsHeight != old.contentsHeight) {
            return true;
          }
          break;
        case MultiHeaderListViewUpdateType.leftHeaderWidth:
          if (leftHeaderWidth != old.leftHeaderWidth) {
            return true;
          }
          break;
        case MultiHeaderListViewUpdateType.topHeaderHeight:
          if (topHeaderHeight != old.topHeaderHeight) {
            return true;
          }
          break;

        default:
          break;
      }
    }
    return false;
  }
}
