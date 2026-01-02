// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Singleton class to manage global loading state.
class LoadingState {
  LoadingState._();

  static final LoadingState instance = LoadingState._();

  /// Whether the AI is currently processing.
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);
}
