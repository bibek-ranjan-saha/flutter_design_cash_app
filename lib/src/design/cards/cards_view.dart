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

  late int _currentPage;

  @override
  void initState() {
    super.initState();

    const initialPage = 2;
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
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
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

          bool showFront = rotateXAngle < 90 || rotateXAngle > 270;

          return Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                //* https://stackoverflow.com/questions/73671310/flutter-design-how-to-create-very-complex-only-one-conner-rodent
                ..setEntry(3, 2, .001)
                ..rotateZ(rotateZAngle * math.pi / 180) // Convert degrees to radians
                ..rotateX(-rotateXAngle * math.pi / 180) // Convert degrees to radians
                ..scale(scaleValue, scaleValue),
              child: _Card(
                card: cards[index],
                showFront: showFront,
                isFocused: isCurrentPageAnimating,
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
      width: 350,
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.showFront
            ? frontVideo != null && _controller != null
                ? VideoPlayer(_controller)
                : Image.asset(frontImage!.path, fit: BoxFit.cover)
            : Image.asset(backImage.path, fit: BoxFit.cover),
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
