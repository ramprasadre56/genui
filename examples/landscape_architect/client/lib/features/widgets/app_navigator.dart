// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/loading_state.dart';
import '../../core/logging.dart';

/// Widget that handles navigation based on A2UI surface updates.
class AppNavigator extends StatefulWidget {
  const AppNavigator({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Navigate to a route based on the surface ID.
  void navigateToSurface(String surfaceId) {
    appLogger.info('Navigating to surface: $surfaceId');
    
    final routes = {
      'welcome': '/',
      'upload': '/upload_photo',
      'questionnaire': '/questionnaire',
      'options': '/design_options',
      'estimate': '/estimate',
    };

    final route = routes[surfaceId];
    if (route != null) {
      widget.router.go(route);
    }
  }
}
