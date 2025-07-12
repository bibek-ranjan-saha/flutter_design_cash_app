import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double value;

  WavePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.7),
          Colors.purple.withOpacity(0.7),
          Colors.cyan.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.5);

    for (double i = 0; i <= size.width; i++) {
      double y = sin((i / waveLength * 2 * pi) + (value * 2 * pi)) * waveHeight;
      path.lineTo(i, size.height * 0.5 + y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class ShaderBackground extends StatefulWidget {
  const ShaderBackground({super.key});

  @override
  _ShaderBackgroundState createState() => _ShaderBackgroundState();
}

class _ShaderBackgroundState extends State<ShaderBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Future<ui.FragmentShader> _shader;

  @override
  void initState() {
    super.initState();

    _shader = loadShader();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  Future<ui.FragmentShader> loadShader() async {
    try {
      final program =
      await ui.FragmentProgram.fromAsset('shaders/complex_gradient.frag');
      print("✅ Shader loaded successfully");
      return program.fragmentShader();
    } catch (e) {
      print("❌ Failed to load shader: $e");
      rethrow;
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.FragmentShader>(
      future: _shader,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: ComplexShaderPainter(snapshot.data!, _controller.value),
            );
          },
        );
      },
    );
  }
}

class ComplexShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double value;

  ComplexShaderPainter(this.shader, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, value * 6.28); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y

    final paint = Paint()..shader = shader;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ComplexShaderPainter oldDelegate) => true;
}