// Copyright 2025 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../primitives/simple_items.dart';
import 'ui_models.dart';

/// A sealed class representing a part of a message.
///
/// This allows for multi-modal content in a single message.
sealed class MessagePart {
  Object? toJson();
}

/// A text part of a message.
final class TextPart implements MessagePart {
  /// The text content.
  final String text;

  /// Creates a [TextPart] with the given [text].
  const TextPart(this.text);

  @override
  Object? toJson() => {'type': 'text', 'text': text};
}

/// A part of a message that represents a UI event.
final class UiEventPart implements MessagePart {
  /// The UI event.
  final UiEvent event;

  /// Creates a [UiEventPart] with the given [event].
  const UiEventPart(this.event);

  @override
  Object? toJson() => {'type': 'uiEvent', 'event': event.toMap()};
}

/// An image part of a message.
///
/// Use the factory constructors to create an instance from different sources.
final class ImagePart implements MessagePart {
  /// The raw image bytes. May be null if created from a URL or Base64.
  final Uint8List? bytes;

  /// The Base64 encoded image string. May be null if created from bytes or URL.
  final String? base64;

  /// The URL of the image. May be null if created from bytes or Base64.
  final Uri? url;

  /// The MIME type of the image (e.g., 'image/jpeg', 'image/png').
  /// Required when providing image data directly.
  final String? mimeType;

  // Private constructor to enforce creation via factories.
  const ImagePart._({this.bytes, this.base64, this.url, this.mimeType});

  /// Creates an [ImagePart] from raw image bytes.
  const factory ImagePart.fromBytes(
    Uint8List bytes, {
    required String mimeType,
  }) = _ImagePartFromBytes;

  /// Creates an [ImagePart] from a Base64 encoded string.
  const factory ImagePart.fromBase64(
    String base64, {
    required String mimeType,
  }) = _ImagePartFromBase64;

  /// Creates an [ImagePart] from a URL.
  const factory ImagePart.fromUrl(Uri url) = _ImagePartFromUrl;

  @override
  Object? toJson() {
    if (bytes != null) {
      return {
        'type': 'image',
        'base64': base64Encode(bytes!),
        'mimeType': mimeType,
      };
    } else if (base64 != null) {
      return {'type': 'image', 'base64': base64, 'mimeType': mimeType};
    } else if (url != null) {
      return {'type': 'image', 'url': url.toString()};
    } else {
      return null;
    }
  }
}

// Private implementation classes for ImagePart factories
final class _ImagePartFromBytes extends ImagePart {
  const _ImagePartFromBytes(Uint8List bytes, {required String mimeType})
    : super._(bytes: bytes, mimeType: mimeType);
}

final class _ImagePartFromBase64 extends ImagePart {
  const _ImagePartFromBase64(String base64, {required String mimeType})
    : super._(base64: base64, mimeType: mimeType);
}

final class _ImagePartFromUrl extends ImagePart {
  const _ImagePartFromUrl(Uri url) : super._(url: url);
}

/// A sealed class representing a message in the chat history.
sealed class ChatMessage {
  /// Creates a [ChatMessage].
  const ChatMessage();

  /// Converts this message to a JSON object.
  JsonMap toJson();
}

/// A message representing a user's message.
final class UserMessage extends ChatMessage {
  /// Creates a [UserMessage] with the given [parts].
  const UserMessage(this.parts);

  /// Creates a [UserMessage] with a single text part.
  factory UserMessage.text(String text) => UserMessage([TextPart(text)]);

  /// Creates a [UserMessage] from a single UI event.
  factory UserMessage.fromEvent(UiEvent event) =>
      UserMessage([UiEventPart(event)]);

  /// The parts of the message.
  final List<MessagePart> parts;

  @override
  JsonMap toJson() => {
    'role': 'user',
    'parts': parts.map((p) => p.toJson()).toList(),
  };
}

/// A message representing a text response from the AI.
final class AiTextMessage extends ChatMessage {
  /// Creates an [AiTextMessage] with the given [parts].
  const AiTextMessage(this.parts);

  /// Creates an [AiTextMessage] with a single text part.
  factory AiTextMessage.text(String text) => AiTextMessage([TextPart(text)]);

  /// The parts of the message.
  final List<MessagePart> parts;
  @override
  JsonMap toJson() => {
    'role': 'model',
    'parts': parts.map((p) => p.toJson()).toList(),
  };
}

/// A message representing a UI response from the AI.
final class AiUiMessage extends ChatMessage {
  /// Creates an [AiUiMessage] with the given UI [definition].
  AiUiMessage({required this.definition, String? surfaceId})
    : uiKey = UniqueKey(),
      surfaceId =
          surfaceId ??
          ValueKey(DateTime.now().toIso8601String()).hashCode.toString();

  /// The UI definition for this message.
  final JsonMap definition;

  /// A unique key for the UI widget.
  final Key uiKey;

  /// The ID of the surface that this UI belongs to.
  final String surfaceId;
  @override
  JsonMap toJson() => {
    'role': 'model',
    'parts': [
      {
        'type': 'ui',
        'definition': {'surfaceId': surfaceId, ...definition},
      },
    ],
  };
}

// The following classes are not intended to be serialized.

/// A message representing an internal message.
final class InternalMessage extends ChatMessage {
  /// Creates an [InternalMessage] with the given [text].
  const InternalMessage(this.text);

  /// The text of the message.
  final String text;
  @override
  JsonMap toJson() => {};
}

/// A message representing a response from a tool.
final class ToolResponseMessage extends ChatMessage {
  /// Creates a [ToolResponseMessage] with the given [results].
  const ToolResponseMessage(this.results);

  /// The results of the tool calls.
  final List<ToolResultPart> results;
  @override
  JsonMap toJson() => {};
}

/// A part of a message representing the result of a tool call.
final class ToolResultPart implements MessagePart {
  /// The ID of the tool call.
  final String callId;

  /// The result of the tool call.
  final String result;

  /// Creates a [ToolResultPart] with the given [callId] and [result].
  const ToolResultPart({required this.callId, required this.result});
  @override
  Object? toJson() => {'callId': callId, 'result': result};
}
