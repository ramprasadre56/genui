# Landscape Architect Flutter Client

A Flutter client for the Landscape Architect AI agent that uses the GenUI SDK to render A2UI interfaces.

## Features

- **Photo Upload**: Capture or select photos of outdoor spaces
- **Dynamic Questionnaire**: AI-generated forms based on photo analysis
- **Design Options**: View personalized landscape design proposals
- **Project Estimates**: Detailed cost breakdowns and timelines

## Prerequisites

- Flutter SDK 3.9+
- Running Landscape Architect server on port 10003

## Running the Client

1. Start the server first (see `samples/agent/adk/landscape_architect/README.md`)

2. Navigate to this directory:
   ```bash
   cd genui/examples/landscape_architect/client
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Generate Riverpod code:
   ```bash
   dart run build_runner build
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── logging.dart          # Logging configuration
│   └── theme.dart            # App theming
└── features/
    ├── ai/
    │   └── ai_provider.dart  # A2A connection providers
    ├── screens/
    │   ├── welcome_screen.dart
    │   ├── upload_photo_screen.dart
    │   ├── questionnaire_screen.dart
    │   ├── design_options_screen.dart
    │   └── estimate_screen.dart
    ├── state/
    │   └── loading_state.dart
    └── widgets/
        ├── app_navigator.dart
        └── global_progress_indicator.dart
```

## User Flow

1. **Welcome** → User starts project
2. **Upload Photo** → User takes/selects landscape photo
3. **Questionnaire** → AI generates custom questions based on photo
4. **Design Options** → User receives personalized design proposals
5. **Estimate** → User views cost breakdown and confirms project
