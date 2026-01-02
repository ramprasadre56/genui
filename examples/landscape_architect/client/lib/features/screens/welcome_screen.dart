// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';

import '../ai/ai_provider.dart';
import '../../core/logging.dart';

/// The welcome screen that greets users and starts the landscape design flow.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _initialRequestSent = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AiClientState>>(aiProvider, (previous, next) {
      if (next is AsyncData && !_initialRequestSent) {
        setState(() {
          _initialRequestSent = true;
        });
        final AiClientState? aiState = next.value;
        aiState?.conversation.sendRequest(
          UserMessage.text('Hello, start'),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ref.watch(aiProvider).when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Connecting to Landscape Architect...'),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: $error', textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(aiProvider),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (aiState) {
            return ValueListenableBuilder<UiDefinition?>(
              valueListenable: aiState.a2uiMessageProcessor.getSurfaceNotifier('welcome'),
              builder: (context, definition, child) {
                if (definition == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.landscape, size: 100, color: Colors.green),
                        const SizedBox(height: 24),
                        Text(
                          '🌿 Landscape Architect AI',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading...',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: GenUiSurface(
                    host: aiState.a2uiMessageProcessor,
                    surfaceId: 'welcome',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
