import 'stamp_model.dart';

class User {
  final String name;
  final int currentStars;
  final int totalStarsForNextTier;
  final String tierName;
  final double walletBalance;
  final String qrCodeData;
  final List<StampModel> earnedStamps;

  User({
    required this.name,
    required this.currentStars,
    required this.totalStarsForNextTier,
    required this.tierName,
    required this.walletBalance,
    required this.qrCodeData,
    required this.earnedStamps,
  });
}
