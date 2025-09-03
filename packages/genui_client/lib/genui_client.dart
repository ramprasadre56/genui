// Copyright 2025 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The high-level API for the genui_client package.
///
/// This library exports the primary facade `UiAgent`, the necessary widgets for
/// rendering, and the core data models.
library;

export 'src/core_catalog.dart';
export 'src/genui_surface.dart' show GenUiSurface;
export 'src/model/catalog.dart';
export 'src/model/catalog_item.dart' show CatalogItem, WidgetValueStore;
export 'src/model/chat_box.dart';
export 'src/model/chat_message.dart';
export 'src/model/ui_models.dart' show UiDefinition;
export 'src/ui_agent.dart';
export 'src/widgets/chat_widget.dart' show GenUiChat;
export 'src/widgets/conversation_widget.dart';
export 'src/primitives/logging.dart';
