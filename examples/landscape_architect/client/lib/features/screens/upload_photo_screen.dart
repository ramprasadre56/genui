// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../ai/ai_provider.dart';
import '../../core/logging.dart';

/// Screen for uploading or taking a photo of the landscape.
class UploadPhotoScreen extends ConsumerStatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  ConsumerState<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends ConsumerState<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageMimeType;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        
        setState(() {
          _imageBytes = bytes;
          _imageMimeType = mimeType;
        });
        
        appLogger.info('Image selected: ${image.path}, size: ${bytes.length} bytes');
      }
    } catch (e) {
      appLogger.severe('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_imageBytes == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final aiState = await ref.read(aiProvider.future);
      
      appLogger.info('Uploading image for analysis...');
      
      // Send the image to the agent for analysis
      await aiState.conversation.sendRequest(
        UserMessage([
          const DataPart({
            'userAction': {
              'name': 'submit_photo',
              'sourceComponentId': 'upload_button',
              'context': <String, Object?>{},
            },
          }),
          ImagePart.fromBytes(_imageBytes!, mimeType: _imageMimeType ?? 'image/jpeg'),
        ]),
      );
      
      if (mounted) {
        context.go('/questionnaire');
      }
    } catch (e) {
      appLogger.severe('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Your Space'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '📸 Capture Your Outdoor Space',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Take or upload a photo of your yard. Our AI will analyze it and create a custom questionnaire.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Image preview or placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.landscape, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'No photo selected',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Tips card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for best results:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Capture the full area you want to transform'),
                    const Text('• Include structures like fences, patios, or sheds'),
                    const Text('• Natural daylight works best'),
                    const Text('• Show existing plants and features'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _imageBytes != null && !_isUploading
                  ? _uploadAndAnalyze
                  : null,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analyze My Space'),
            ),
          ],
        ),
      ),
    );
  }
}
