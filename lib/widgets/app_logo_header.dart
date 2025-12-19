import 'package:flutter/material.dart';

class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Image.asset(
          'assets/images/small_logo.png',
          width: 120,
        ),
      ),
    );
  }
}
