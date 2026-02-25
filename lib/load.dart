import 'dart:ui' as ui;
import 'package:birthday_eve/scratch_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }

  Future<void> _loadAndNavigate() async {
    final after = await _loadImage('assets/after.png');
    final before = await _loadImage('assets/before.png');

    if (!mounted) return;

    ScratchPainter painter = ScratchPainter(after: after, before: before);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ScratchCardScreen(painter: painter)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,

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
      ),
    );
  }
}
