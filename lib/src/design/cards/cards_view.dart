import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'cards_data.dart';

class Cards extends StatefulWidget {
  const Cards({super.key});

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  late final PageController _controller;

  late int _currentPage;

  @override
  void initState() {
    super.initState();

    const initialPage = 0;
    _controller = PageController(
      viewportFraction: 0.26,
      initialPage: initialPage,
    );
    _currentPage = initialPage;
    _controller.addListener(() {
      final currentPage = _controller.page?.floor();
      setState(() {
        _currentPage = currentPage!;
      });
      // log("currentPage: $_currentPage");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: cards.length,
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final isCurrentPageAnimating = _currentPage == index;
          final isNextPageAnimating = _currentPage + 1 == index;

          final progress = _controller.page! - _currentPage;
          // log("progress: $progress");

          final indexSmallerThanCurrentPage = _currentPage >= index;

          // ?Rotation
          const maxRotations = 5;
          const oneRotationValue = (360 / maxRotations);
          // Determines the current rotation number (e.g. 1, 2 till [maxRotations])
          final rotationNumber = switch (indexSmallerThanCurrentPage) {
            true => _currentPage - index + 1,
            false => maxRotations - (index - _currentPage - 1),
          };
          // Rotate from 144 to 216
          // Rotation Ending Angle (e.g. 216)
          final rotateXEnd = oneRotationValue * rotationNumber;
          // Rotation Starting Angle (e.g. 144)
          final rotateXStart = rotateXEnd - oneRotationValue;

          final rotateXAngle = rotateXStart + (oneRotationValue * progress);

          const maxRotateZAngle = -7.5;
          final rotateZAngle = isCurrentPageAnimating
              ? maxRotateZAngle * (1 - progress) //
              : isNextPageAnimating
                  ? maxRotateZAngle * progress //
                  : 0;

          // ?Scaling
          const maxScale = 1.1;
          final double scaleValue = isCurrentPageAnimating
              ? 1 + (maxScale - 1) * (1 - progress) //
              : isNextPageAnimating
                  ? 1 + (maxScale - 1) * progress //
                  : 1;

          final backImage = cards[index].back;

          return Center(
            child: Transform(
              alignment: Alignment.center,
              origin: const Offset(0.5, 0),
              transform: Matrix4.identity()
                //* https://stackoverflow.com/questions/73671310/flutter-design-how-to-create-very-complex-only-one-conner-rodent
                ..setEntry(3, 2, .001)
                ..rotateZ(rotateZAngle * math.pi / 180) // Convert degrees to radians
                ..rotateX(rotateXAngle * math.pi / 180) // Convert degrees to radians
                ..scale(scaleValue, scaleValue),
              child: Container(
                width: 350,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: backImage.provider(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
