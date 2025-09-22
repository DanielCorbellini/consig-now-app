import 'package:flutter/material.dart';

class MinhasCores {
  static const Color roxo = Color(0xFFE0BBE4);

  // Verdes pastéis
  static const Color verdeTopo = Color(0xFF8FD9A8); // Verde pastel mais forte
  static const Color verdeBaixo = Color(0xFFDFF5E3); // Verde pastel bem claro

  static const MaterialColor verdeTopoGradiente =
      MaterialColor(_verdetopogradientePrimaryValue, <int, Color>{
        50: Color(0xFFEAF8F0),
        100: Color(0xFFCFF0DA),
        200: Color(0xFFB3E8C3),
        300: Color(0xFF96E0AD),
        400: Color(0xFF80DA9B),
        500: Color(_verdetopogradientePrimaryValue),
        600: Color(0xFF79D497),
        700: Color(0xFF6ECD8D),
        800: Color(0xFF64C783),
        900: Color(0xFF52BB71),
      });
  static const int _verdetopogradientePrimaryValue = 0xFF8FD9A8;

  static const MaterialColor verdeTopoGradienteAccent =
      MaterialColor(_verdetopogradienteAccentValue, <int, Color>{
        100: Color(0xFFFFFFFF),
        200: Color(_verdetopogradienteAccentValue),
        400: Color(0xFFD2F8E0),
        700: Color(0xFFB8F2CE),
      });
  static const int _verdetopogradienteAccentValue = 0xFFEAFBF0;

  static const MaterialColor verdeBaixoGradiente =
      MaterialColor(_verdebaixogradientePrimaryValue, <int, Color>{
        50: Color(0xFFF7FEFA),
        100: Color(0xFFEFFCF3),
        200: Color(0xFFE6FAED),
        300: Color(0xFFDFF8E7),
        400: Color(0xFFD9F7E2),
        500: Color(_verdebaixogradientePrimaryValue),
        600: Color(0xFFD6F6DF),
        700: Color(0xFFD0F5DA),
        800: Color(0xFFCBF4D6),
        900: Color(0xFFC1F2CE),
      });
  static const int _verdebaixogradientePrimaryValue = 0xFFDFF5E3;

  static const MaterialColor verdeBaixoGradienteAccent =
      MaterialColor(_verdebaixogradienteAccentValue, <int, Color>{
        100: Color(0xFFFFFFFF),
        200: Color(_verdebaixogradienteAccentValue),
        400: Color(0xFFFFFFFF),
        700: Color(0xFFFFFFFF),
      });
  static const int _verdebaixogradienteAccentValue = 0xFFFFFFFF;
}
