import 'package:flutter/material.dart';

class HexPainter extends CustomPainter {
  final Color _foregroundColor;
  final Color _backgroundColor;

  HexPainter({
    Color? backgroundColor,
    Color? foregroundColor,
  })  : _backgroundColor = backgroundColor ?? Colors.white,
        _foregroundColor = foregroundColor ?? Colors.black,
        super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    drawHexagon(canvas, size, paint);
    drawButton(canvas, size, paint);
  }

  /// Draws rounded hexagon shape imitating Humon Hex device.
  void drawHexagon(Canvas canvas, Size size, Paint paint) {
    paint.color = _backgroundColor;
    paint.strokeWidth = size.width * 0.5;
    paint.strokeJoin = StrokeJoin.round;
    paint.style = PaintingStyle.stroke;
    var path = Path();
    path.addPolygon([
      Offset(size.width * 0.25, size.height * 0.375),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.375),
      Offset(size.width * 0.75, size.height * 0.625),
      Offset(size.width * 0.5, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.625)
    ], true);
    canvas.drawPath(path, paint);
  }

  /// Draws Humon Hex button.
  void drawButton(Canvas canvas, Size size, Paint paint) {
    paint.color = _foregroundColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.23),
        size.height * 0.08, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
