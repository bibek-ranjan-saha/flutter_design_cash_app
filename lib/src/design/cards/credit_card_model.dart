import '../../../gen/assets.gen.dart';

class CreditCard {
  CreditCard({
    required this.back,
    this.front,
    this.frontVideo,
  }) : assert(
          front != null || frontVideo != null,
          'front or frontVideo must be provided',
        );

  final AssetGenImage back;
  final AssetGenImage? front;
  final String? frontVideo;
}
