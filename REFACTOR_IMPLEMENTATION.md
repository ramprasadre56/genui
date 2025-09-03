# `simple_chat` to `genui_client` Example: Implementation Plan

This document outlines the step-by-step plan to refactor the `simple_chat` example into a new example for the `genui_client` package.

## Phased Implementation

### Phase 1: Project Scaffolding and Dependency Setup

- [x] Create a new Flutter project in `packages/genui_client/example`.
- [x] Remove the default `main.dart` and `test/` directory.
- [x] Update `pubspec.yaml` to remove `flutter_lints` and add a path dependency on `genui_client` and a dependency on `logging`.
- [x] Create a new `analysis_options.yaml` that includes `package:flutter_lints/flutter.yaml` and ignores generated files.
- [x] Create a `README.md` with initial setup instructions for the server and client.

**Post-Phase 1 Steps:**
- [x] Run `dart_fix` and `dart_format` to clean up any generated Dart code.
- [x] Run `analyze_files` and fix any reported issues.
- [x] Run tests to ensure all pass (Note: there may be no tests in this phase).
- [x] Run `dart_format` again to ensure correct formatting.
- [x] Use `git diff` to verify changes, then prepare a commit message for approval.
- [x] Update the "Journal" section below with the current state.
- [x] Wait for approval before committing and proceeding.

### Phase 2: Porting and Refactoring the Application Logic

- [ ] Copy the `lib/main.dart` from `examples/simple_chat` to `packages/genui_client/example/lib/main.dart`.
- [ ] Remove the `firebase_core` import and `Firebase.initializeApp()` call.
- [ ] Replace the `flutter_genui` import with `package:genui_client/genui_client.dart`.
- [ ] In `_ChatScreenState`, replace the `flutter_genui` `UiAgent` with the `genui_client` `UiAgent`.
- [ ] Implement an `_init()` method in `_ChatScreenState` to call `_uiAgent.startSession()`.
- [ ] Remove the `_messages` list and `_onSurfaceAdded` callback.
- [ ] Replace the main `Column` in the `build` method with the `GenUiChat` widget.
- [ ] Remove the `MessageController` and `MessageView` classes (and the `message.dart` file).
- [ ] Update the `_sendMessage` method to use the new `_uiAgent.sendRequest`.

**Post-Phase 2 Steps:**

- [ ] Run `dart_fix` and `dart_format` to clean up the ported Dart code.
- [ ] Run `analyze_files` and fix any reported issues.
- [ ] Run tests to ensure all pass.
- [ ] Run `dart_format` again to ensure correct formatting.
- [ ] Use `git diff` to verify changes, then prepare a commit message for approval.
- [ ] Update the "Journal" section below with the current state.
- [ ] Wait for approval before committing and proceeding.

### Phase 3: Finalization and Documentation

- [ ] Ensure the `README.md` is comprehensive and accurate.
- [ ] Run the example to verify it works as expected with a local `genui_server`.
- [ ] Delete the now-unused `lib/message.dart` file.

**Post-Phase 3 Steps:**

- [ ] Run `dart_fix` and `dart_format` on any modified files.
- [ ] Run `analyze_files` and fix any reported issues.
- [ ] Run tests to ensure all pass.
- [ ] Run `dart_format` again to ensure correct formatting.
- [ ] Use `git diff` to verify changes, then prepare a commit message for approval.
- [ ] Update the "Journal" section below with the final state.
- [ ] Wait for approval before committing.

---

## Journal

### Phase 1: Project Scaffolding and Dependency Setup

Completed the initial project scaffolding for the new `genui_client` example. Created the Flutter project, updated dependencies, and added initial documentation. Encountered and resolved some issues with file paths and dependency management during the process. The project is now ready for the application logic to be ported in Phase 2.
