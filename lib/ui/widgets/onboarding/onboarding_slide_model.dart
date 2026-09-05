import 'package:flutter/material.dart';

/// Modelo de datos para cada diapositiva interactiva del Onboarding
class OnboardingSlideModel {
  final String badgeText;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final String? highlightTip;

  const OnboardingSlideModel({
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    this.highlightTip,
  });
}
