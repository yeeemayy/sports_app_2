import 'package:flutter/material.dart';

class DiagonalSplitBanner extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;
  final Color leftColor;
  final Color rightColor;
  final int leftFlex;
  final int rightFlex;
  final double cutWidth;
  final double height;

  const DiagonalSplitBanner({
    super.key,
    required this.leftChild,
    required this.rightChild,
    required this.leftColor,
    required this.rightColor,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.cutWidth = 24,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DiagonalPainter(
          leftColor: leftColor,
          rightColor: rightColor,
          cutWidth: cutWidth,
          leftFlex: leftFlex,
          rightFlex: rightFlex,
        ),
        child: Row(
          children: [
            Expanded(
              flex: leftFlex,
              child: Center(child: leftChild),
            ),
            Expanded(
              flex: rightFlex,
              child: Center(child: rightChild),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;
  final double cutWidth;
  final int leftFlex;
  final int rightFlex;

  _DiagonalPainter({
    required this.leftColor,
    required this.rightColor,
    required this.cutWidth,
    required this.leftFlex,
    required this.rightFlex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final leftPaint = Paint()..color = leftColor;
    final rightPaint = Paint()..color = rightColor;

    final mid = size.width * leftFlex / (leftFlex + rightFlex);

    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(mid, 0)
      ..lineTo(mid - cutWidth, size.height)
      ..lineTo(0, size.height)
      ..close();

    final rightPath = Path()
      ..moveTo(mid, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(mid - cutWidth, size.height)
      ..close();

    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalPainter oldDelegate) =>
      oldDelegate.leftColor != leftColor ||
      oldDelegate.rightColor != rightColor ||
      oldDelegate.cutWidth != cutWidth ||
      oldDelegate.leftFlex != leftFlex ||
      oldDelegate.rightFlex != rightFlex;
}
