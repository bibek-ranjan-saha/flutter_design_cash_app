import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_design_cash_app/src/design/cards/credit_card_model.dart';
import 'package:video_player/video_player.dart';

import '../../../gen/assets.gen.dart';
import 'cards_data.dart';

class Cards extends StatefulWidget {
  const Cards({super.key});

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  late final PageController _controller;

  late double _currentPage;

  @override
  void initState() {
    super.initState();

    const initialPage = 2;
    _controller = PageController(
      viewportFraction: 0.24,
      initialPage: initialPage,
    );
    _currentPage = initialPage.toDouble();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0.0;
      });
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
          final progress = _currentPage % 1;

          final currentPageInt = _currentPage.toInt();

          final isCurrentPageAnimating = currentPageInt == index;
          final isNextPageAnimating = currentPageInt + 1 == index;

          final indexSmallerThanCurrentPage = currentPageInt >= index;

          // ?Rotation
          // e.g., ..., -187, -110, 0, 110, 187, ...
          const rotationsAngle = [0, 110, 187, 280, 360];
          final maxRotations = rotationsAngle.length;
          final lastRotationsAngleIndex = maxRotations - 1;
          // Rotate from:
          //   1. 144 to 216
          //   2. -72 to 0

          // Rotation Starting Angle:
          //   1. 144
          //   2. -72
          final rotateXStartIndex = math.min(
            (currentPageInt - index).abs(),
            lastRotationsAngleIndex, // limit till the last index
          );

          // Rotation Ending Angle:
          //   1. 216
          //   2. 0
          final rotateXEndIndex = switch (indexSmallerThanCurrentPage) {
            true => math.min(rotateXStartIndex + 1, lastRotationsAngleIndex),
            false => math.min(rotateXStartIndex - 1, lastRotationsAngleIndex),
          };

          final rotateXStartAngle = rotationsAngle[rotateXStartIndex];
          final rotateXEndAngle = rotationsAngle[rotateXEndIndex];

          final rotateXAngle = switch (indexSmallerThanCurrentPage) {
            true => -(rotateXStartAngle + ((rotateXEndAngle - rotateXStartAngle) * progress)),
            false => (rotateXStartAngle + ((rotateXEndAngle - rotateXStartAngle) * progress)),
          };

          const maxRotateZAngle = -7.5;
          final rotateZAngle = isCurrentPageAnimating
              ? maxRotateZAngle * (1 - progress) //
              : isNextPageAnimating
                  ? maxRotateZAngle * progress //
                  : 0;

          // ?Scaling
          const maxScale = 1.15;
          final double scaleValue = isCurrentPageAnimating
              ? 1 + (maxScale - 1) * (1 - progress) //
              : isNextPageAnimating
                  ? 1 + (maxScale - 1) * progress //
                  : 1;

          bool showFront = rotateXAngle > -90 && rotateXAngle < 90;

          return Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                //* https://stackoverflow.com/questions/73671310/flutter-design-how-to-create-very-complex-only-one-conner-rodent
                ..setEntry(3, 2, .001)
                ..rotateZ(rotateZAngle * math.pi / 180) // Convert degrees to radians
                ..rotateX(rotateXAngle * math.pi / 180) // Convert degrees to radians
                ..scale(scaleValue, scaleValue),
              child: _Card(
                card: cards[index],
                showFront: showFront,
                isFocused: isCurrentPageAnimating || isNextPageAnimating,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatefulWidget {
  const _Card({
    required this.card,
    required this.isFocused,
    required this.showFront,
  });

  final bool showFront;
  final bool isFocused;
  final CreditCard card;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  late final VideoPlayerController? _controller;

  bool get _isVideoControllerInitialized =>
      frontVideo != null && (_controller?.value.isInitialized ?? false);

  AssetGenImage get backImage => widget.card.back;
  AssetGenImage? get frontImage => widget.card.front;
  String? get frontVideo => widget.card.frontVideo;

  @override
  void initState() {
    if (frontVideo != null) {
      _controller = VideoPlayerController.asset(frontVideo!);
      _controller?.initialize().whenComplete(() {
        // Ensure the first frame is shown after the video is initialized
        return setState(() {
          determineVideoState();
        });
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _Card oldWidget) {
    if (oldWidget != widget) {
      if (!_isVideoControllerInitialized) return;

      determineVideoState();
    }
    super.didUpdateWidget(oldWidget);
  }

  void determineVideoState() {
    if (widget.showFront && widget.isFocused) {
      playVideo();
    } else {
      pauseVideo();
    }
  }

  Future<void> playVideo() async {
    await _controller?.setLooping(true);
    await _controller?.play();
  }

  Future<void> pauseVideo() async {
    await _controller?.pause();
  }

  @override
  Widget build(BuildContext context) {
    if (frontVideo != null && !_isVideoControllerInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 300,
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.showFront
            ? frontVideo != null && _controller != null
                ? VideoPlayer(_controller)
                : Image.asset(frontImage!.path, fit: BoxFit.cover)
            : Transform.flip(
                flipY: true,
                child: Image.asset(backImage.path, fit: BoxFit.cover),
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_isVideoControllerInitialized) {
      _controller?.dispose();
    }
  }
}
