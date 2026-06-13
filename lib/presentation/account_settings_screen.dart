import 'package:flutter/material.dart';

import 'coming_soon_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Account Settings',
      featureLabel: 'Account Settings',
    );
  }
}
