import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The app logo: "ALU-Nexus" set in Sentient, a serif wordmark.
class AppWordmark extends StatelessWidget {
  final double size;
  final Color color;

  const AppWordmark({
    super.key,
    this.size = 24,
    this.color = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'ALU-Nexus',
      style: TextStyle(
        fontFamily: 'Sentient',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
        height: 1.0,
      ),
    );
  }
}
