import 'package:flutter/material.dart';

class Scale extends StatelessWidget {
  final double height;
  final double widthAsUnit;
  final double unitWidth;
  final int subSplit;
  final String Function(int index, double pos)? text;
  final Color color;

  const Scale({
    required this.height,
    required this.widthAsUnit,
    required this.unitWidth,
    required this.subSplit,
    required this.color,
    this.text,
    Key? key,
  }) : super(key: key);

  List<Widget> split() {
    int length = widthAsUnit.ceil();
    double lastWidth = (widthAsUnit - widthAsUnit.floor()) * unitWidth;

    return List.generate(
      length,
      (index) {
        bool isLast = index + 1 == length;
        return _SplitedScale(
          height,
          index,
          isLast ? lastWidth : unitWidth,
          unitWidth,
          subSplit,
          text,
          color,
          isLast,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int length = widthAsUnit.ceil();
    double lastWidth = (widthAsUnit % 1.0) * unitWidth;
    return new RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        child: SizedBox(
          height: height,
          width: widthAsUnit * unitWidth,
          child: text == null
              ? null
              : Row(
                  children: List.generate(
                    length,
                    (index) {
                      bool isLast = index + 1 == length;
                      return SizedBox(
                        width: isLast ? lastWidth : unitWidth,
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              text: text!(index, index * unitWidth),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        painter: _ScalePainter(unitWidth, subSplit, color, true),
      ),
    );
  }
}

class _SplitedScale extends StatelessWidget {
  final double height;
  final int indexAsUnit;
  final double widthAsUnit;
  final double unitWidth;
  final int subSplit;
  final String Function(int index, double pos)? text;
  final Color color;
  final bool isFinal;

  const _SplitedScale(
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
