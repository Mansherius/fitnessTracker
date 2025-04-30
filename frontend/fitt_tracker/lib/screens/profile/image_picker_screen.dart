import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitt_tracker/services/image_picking_service.dart';
import 'package:fitt_tracker/utils/session_manager.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final ImagePickingService _imagePickingService = ImagePickingService();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = pickedFile;
    });
  }

  Future<void> _uploadImage() async {
  if (_selectedImage == null) return;

  final userId = await SessionManager.getUserId();
  if (userId == null) return;

  final success = await _imagePickingService.uploadProfilePicture(userId, _selectedImage!);
  if (success) {
    Navigator.pop(context, true); // Return to profile screen and trigger reload
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to upload profile picture')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile Picture'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Column(
                children: [
                  Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: const Text('Choose This Image'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Choose Different'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Icon(Icons.image, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Choose Image'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}