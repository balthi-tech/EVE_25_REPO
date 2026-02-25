import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double canvasWidth = 400;
const double canvasHeight = 560;
const double scratchRadius = 25.0;

void main() => runApp(
  MaterialApp(home: ScratchCardScreen(), debugShowCheckedModeBanner: false),
);

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  List<Offset> paths = [];
  bool revealed = false;
  double percent = 0;
  bool loaded = false;
  ui.Image? after;
  ui.Image? before;
  late ScratchPainter painter;
  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }

  Future<void> loadImages() async {
    after = await _loadImage('assets/after.png');
    before = await _loadImage('assets/before.png');
    setState(() {
      loaded = true;
      painter = ScratchPainter(after: after!, before: before!);
    });
  }

  double _calculateScratchPercent() {
    final totalArea = canvasWidth * canvasHeight; // Canvas
    final radius = scratchRadius; // ✅ VOTRE rayon
    final circleArea = 3.14 * radius * radius * 0.10; // 30% overlap
    final pathArea = paths.length * circleArea;
    return (pathArea / totalArea).clamp(0.0, 1.0);
  }

  void resetScratch() {
    setState(() {
      paths.clear(); // ✅ Efface paths
      percent = 0.0; // ✅ Reset %
      revealed = false; // ✅ Reset texte
      painter.revealed = false; // ✅ Painter reset
    });
  }

  void addScratch(Offset p) {
    print('Adding scratch at: $p');
    setState(() {
      paths.add(p);
      percent = _calculateScratchPercent();
      if (percent > 0.9) {
        revealed = true;
        painter.revealed = true;
        paths = []; // Reset
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFc91712).withValues(alpha: 0.9),
              Color(0xFF25221e).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '💌 Gratte moi !',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                Spacer(),
                IconButton(
                  onPressed: resetScratch,
                  icon: Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),

            SizedBox(height: 30),
            if (!loaded)
              Container(
                width: canvasWidth,
                height: canvasHeight,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(blurRadius: 25, color: Colors.black26)],
                ),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              ),
            if (loaded)
              GestureDetector(
                onPanUpdate: (e) => addScratch(e.localPosition),
                child: Container(
                  width: canvasWidth,
                  height: canvasHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(blurRadius: 25, color: Colors.black26),
                    ],
                  ),
                  child: CustomPaint(painter: painter..paths = paths),
                ),
              ),
            SizedBox(height: 20),
            Text(
              revealed ? "Je t'aime ❤️" : '${(percent * 100).round()}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ScratchPainter extends CustomPainter {
  final ui.Image after;
  final ui.Image before;

  ScratchPainter({required this.after, required this.before});

  List<Offset> paths = [];
  bool revealed = false;

  @override
  void paint(ui.Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      after.width.toDouble(),
      after.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    if (revealed) {
      // ✅ 90% → after.png COMPLET
      canvas.drawImageRect(after, src, dst, Paint());
      return;
    }

    // Normal
    canvas.drawImageRect(after, src, dst, Paint());

    canvas.saveLayer(dst, Paint());
    canvas.drawImageRect(before, src, dst, Paint());

    final clear = Paint()..blendMode = ui.BlendMode.dstOut;
    for (var p in paths) {
      canvas.drawCircle(p, scratchRadius, clear); // ✅ 10px
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}
