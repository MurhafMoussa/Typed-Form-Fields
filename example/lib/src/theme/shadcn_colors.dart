import 'package:flutter/material.dart';

/// Shadcn UI Slate/Zinc Color Palette Tokens
abstract class ShadcnColors {
  // Slate Neutral Palette
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020817);

  // Zinc Neutral Palette
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // Functional Semantic Tokens - Light
  static const Color lightBackground = slate50;
  static const Color lightCard = Colors.white;
  static const Color lightForeground = slate900;
  static const Color lightPrimary = slate900;
  static const Color lightPrimaryForeground = slate50;
  static const Color lightMuted = slate100;
  static const Color lightMutedForeground = slate500;
  static const Color lightBorder = slate200;
  static const Color lightInput = slate200;
  static const Color lightDestructive = Color(0xFFEF4444);

  // Functional Semantic Tokens - Dark
  static const Color darkBackground = slate950;
  static const Color darkCard = slate900;
  static const Color darkForeground = slate50;
  static const Color darkPrimary = slate50;
  static const Color darkPrimaryForeground = slate900;
  static const Color darkMuted = slate800;
  static const Color darkMutedForeground = slate400;
  static const Color darkBorder = slate800;
  static const Color darkInput = slate800;
  static const Color darkDestructive = Color(0xFFF87171);
}
