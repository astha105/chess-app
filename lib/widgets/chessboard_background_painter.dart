import 'package:flutter/material.dart';

class ChessboardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 100;
    final Paint darkPaint = Paint()..color = const Color(0xFF1C1C1C);
    final Paint lightPaint = Paint()..color = const Color(0xFF2A2A2A);

    for (int row = 0; row < (size.height / squareSize).ceil(); row++) {
      for (int col = 0; col < (size.width / squareSize).ceil(); col++) {
        final paint = (row + col) % 2 == 0 ? darkPaint : lightPaint;
        final rect = Rect.fromLTWH(
          col * squareSize,
          row * squareSize,
          squareSize,
          squareSize,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
