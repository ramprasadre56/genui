// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

// Color palette for Landscape Architect
const _primaryGreen = Color(0xFF4CAF50);
const _darkGreen = Color(0xFF2E7D32);
const _lightGreen = Color(0xFF81C784);
const _backgroundColor = Color(0xFFF5F5F5);
const _surfaceColor = Colors.white;

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryGreen,
    brightness: Brightness.light,
    primary: _primaryGreen,
    secondary: _darkGreen,
    surface: _surfaceColor,
    background: _backgroundColor,
  ),
  scaffoldBackgroundColor: _backgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: _primaryGreen,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: _surfaceColor,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  ),
  fontFamily: 'Roboto',
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryGreen,
    brightness: Brightness.dark,
    primary: _lightGreen,
    secondary: _primaryGreen,
  ),
  fontFamily: 'Roboto',
);
