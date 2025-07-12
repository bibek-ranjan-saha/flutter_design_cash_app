import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_design_cash_app/src/test.dart';
import 'src/design/cards/cards_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
        Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          body: FutureBuilder<ui.FragmentProgram>(
            future: ui.FragmentProgram.fromAsset('shaders/complex_gradient.frag'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return ShaderWidget(program: snapshot.data!);
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading shader: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );
    }
  }

  class ShaderWidget extends StatefulWidget {
  final ui.FragmentProgram program;

  const ShaderWidget({Key? key, required this.program}) : super(key: key);

  @override
  _ShaderWidgetState createState() => _ShaderWidgetState();
  }

  class _ShaderWidgetState extends State<ShaderWidget> {
  late ui.FragmentShader shader;

  @override
  void initState() {
  super.initState();
  shader = widget.program.fragmentShader();

  }

  @override
  Widget build(BuildContext context) {
  return CustomPaint(
  painter: ShaderPainter(shader: shader),
  child: Container(),
  );
  }
  }

  class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;

  ShaderPainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
  final paint = Paint()..shader = shader;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }