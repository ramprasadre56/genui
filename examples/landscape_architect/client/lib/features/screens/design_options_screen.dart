// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';

import '../ai/ai_provider.dart';

/// Screen displaying design options generated from the questionnaire.
class DesignOptionsScreen extends ConsumerWidget {
  const DesignOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Options'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/questionnaire'),
        ),
      ),
      body: ref.watch(aiProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (aiState) {
          return ValueListenableBuilder<UiDefinition?>(
            valueListenable: aiState.a2uiMessageProcessor.getSurfaceNotifier('options'),
            builder: (context, definition, child) {
              if (definition == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.design_services, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text('Creating your design options...'),
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: GenUiSurface(
                  host: aiState.a2uiMessageProcessor,
                  surfaceId: 'options',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
