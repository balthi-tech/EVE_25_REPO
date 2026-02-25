import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScratchPainter extends CustomPainter {
  final List<Offset> paths;
  ui.Image? _revealImage;
  ui.Image? _gratterImage;

  ScratchPainter({this.paths = const []}) {
    _loadImages();
  }

  Future<void> _loadImages() async {
    // Charge reveal.png
    final ByteData revealData = await rootBundle.load(
      'assets/images/reveal.png',
    );
    final codec = await ui.instantiateImageCodec(
      revealData.buffer.asUint8List(),
    );
    _revealImage = (await codec.getNextFrame()).image;

    // Charge gratter.png
    final ByteData gratterData = await rootBundle.load(
      'assets/images/gratter.png',
    );
    final gCodec = await ui.instantiateImageCodec(
      gratterData.buffer.asUint8List(),
    );
    _gratterImage = (await gCodec.getNextFrame()).image;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_revealImage == null || _gratterImage == null) {
      // Loading...
      final paint = Paint()..color = Colors.grey;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    // 1. Reveal en fond (scale)
    final srcRect = Rect.fromLTWH(
      0,
      0,
      _revealImage!.width.toDouble(),
      _revealImage!.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(_revealImage!, srcRect, dstRect, Paint());

    // 2. Layer scratch
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 3. Gratter overlay
    canvas.drawImageRect(_gratterImage!, srcRect, dstRect, Paint());

    // 4. Efface paths (BlendMode.clear = destination-out)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    for (Offset point in paths) {
      canvas.drawCircle(point, 35, clearPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
