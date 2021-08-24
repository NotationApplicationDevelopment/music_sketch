import 'package:flutter/material.dart';

class ScaleFactory {
  double _widthAsUnit;
  late int _length;
  late double _lastWidth;
  double _unitWidth;
  double _height;
  int _subSplit;

  double get widthAsUnit => _widthAsUnit;
  int get length => _length;
  double get lastWidth => _lastWidth;
  set widthAsUnit(double widthAsUnit) {
    assert(widthAsUnit >= 0);
    _widthAsUnit = widthAsUnit;
    int ceil = widthAsUnit.ceil();
    int floor = (widthAsUnit - 1).ceil();
    this._length = ceil;
    this._lastWidth = (widthAsUnit - floor) * _unitWidth;
  }

  double get unitWidth => _unitWidth;
  set unitWidth(double unitWidth) {
    assert(unitWidth >= 0);
    _unitWidth = unitWidth;
  }

  double get height => _height;
  set height(double height) {
    assert(height >= 0);
    _height = height;
  }

  int get subSplit => _subSplit;
  set subSplit(int subSplit) {
    assert(subSplit > 0);
    _subSplit = subSplit;
  }

  String Function(int index, double pos)? text;
  Color color;

  factory ScaleFactory({
    double widthAsUnit = 0,
    double height = 0,
    double unitWidth = 0,
    int subSplit = 0,
    Color color = Colors.grey,
    String Function(int index, double pos)? text,
  }) {
    return ScaleFactory._(
      widthAsUnit,
      height,
      unitWidth,
      subSplit,
      color,
      text,
    );
  }

  ScaleFactory._(
    this._widthAsUnit,
    this._height,
    this._unitWidth,
    this._subSplit,
    this.color,
    this.text,
  ) {
    int ceil = _widthAsUnit.ceil();
    int floor = (_widthAsUnit - 1).ceil();
    this._length = ceil;
    this._lastWidth = (_widthAsUnit - floor) * _unitWidth;
  }

  void updateWith(
      {double? widthAsUnit,
      double? height,
      double? unitWidth,
      int? subSplit,
      Color? color}) {
    if (height != null) {
      this.height = height;
    }
    if (unitWidth != null) {
      this.unitWidth = unitWidth;
    }
    if (subSplit != null) {
      this.subSplit = subSplit;
    }
    if (color != null) {
      this.color = color;
    }
    if (widthAsUnit != null) {
      this.widthAsUnit = widthAsUnit;
    }
  }

  List<ScaleUnit> asUnitList() {
    return List.generate(
      length,
      (index) {
        return asUnitAtIndex(index)!;
      },
    );
  }

  ScaleUnit? asUnitAtIndex(int index) {
    if (index >= length) {
      return null;
    }

    bool isLast = (index == length - 1);
    return ScaleUnit(
      height,
      index,
      isLast ? lastWidth : unitWidth,
      unitWidth,
      subSplit,
      text,
      color,
      isLast,
    );
  }
}

class ScaleUnit extends StatelessWidget {
  final double height;
  final int indexAsUnit;
  final double widthAsUnit;
  final double unitWidth;
  final int subSplit;
  final String Function(int index, double pos)? text;
  final Color color;
  final bool isFinal;

  const ScaleUnit(
    this.height,
    this.indexAsUnit,
    this.widthAsUnit,
    this.unitWidth,
    this.subSplit,
    this.text,
    this.color,
    this.isFinal, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        child: SizedBox(
          width: widthAsUnit,
          height: height,
          child: text == null
              ? null
              : FittedBox(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: text!(indexAsUnit, indexAsUnit * unitWidth),
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
        ),
        painter: _ScalePainter(unitWidth, subSplit, color, isFinal),
      ),
    );
  }
}

class _ScalePainter extends CustomPainter {
  final int subSplit;
  final Color color;
  final double unitWidth;
  final bool drawEndLine;
  late final double _subWidth;

  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );

  _ScalePainter(this.unitWidth, this.subSplit, this.color, this.drawEndLine) {
    _subWidth = unitWidth / subSplit;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint();
    painter.color = color;
    painter.isAntiAlias = false;
    int count = 0;
    painter.strokeWidth = 2 + 2 / 3;

    if (drawEndLine) {
      for (double pos = 0.0; pos <= size.width; pos += _subWidth) {
        canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), painter);
        if (count < subSplit - 1) {
          count++;
          painter.strokeWidth = 2 / 3;
        } else {
          count = 0;
          painter.strokeWidth = 2 + 2 / 3;
        }
      }
    } else {
      for (double pos = 0.0; pos < size.width; pos += _subWidth) {
        canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), painter);
        if (count < subSplit - 1) {
          count++;
          painter.strokeWidth = 2 / 3;
        } else {
          count = 0;
          painter.strokeWidth = 2 + 2 / 3;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScalePainter oldDelegate) {
    return oldDelegate.unitWidth != unitWidth;
  }
}
