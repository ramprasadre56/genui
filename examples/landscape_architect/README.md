# Landscape Architect Example

A full-stack example demonstrating a Flutter client interacting with a Python-based A2A server for AI-powered landscape design.

## Overview

This example shows how to:
- Analyze landscape photos using Gemini multimodal AI
- Dynamically generate questionnaire forms based on photo analysis
- Render A2UI interfaces in Flutter using the GenUI SDK
- Handle image uploads through the A2A protocol

## Structure

- `client/` - Flutter application using GenUI SDK
- `server/` - Python A2A server (in `samples/agent/adk/landscape_architect/`)

## Quick Start

### 1. Start the Server

```bash
cd ../../samples/agent/adk/landscape_architect
echo "GEMINI_API_KEY=your_key_here" > .env
uv run .
```

### 2. Run the Client

```bash
cd client
flutter pub get
dart run build_runner build
flutter run
```

## See Also

- [Server README](../../samples/agent/adk/landscape_architect/README.md)
- [Client README](client/README.md)
