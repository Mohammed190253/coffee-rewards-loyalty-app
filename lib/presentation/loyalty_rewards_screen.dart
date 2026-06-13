import 'package:flutter/material.dart';

import 'coming_soon_screen.dart';

class LoyaltyRewardsScreen extends StatelessWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Loyalty Rewards',
      featureLabel: 'Loyalty Rewards & Stars',
    );
  }
}
