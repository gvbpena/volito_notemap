import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volito_mobile_test/models/note_images.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';

class ImageChange extends StatefulWidget {
  final Note note;
  final NoteRepository noteRepository;

  const ImageChange({
    super.key,
    required this.note,
    required this.noteRepository,
  });

  @override
  _ImageChangeState createState() => _ImageChangeState();
}

class _ImageChangeState extends State<ImageChange> {
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final List<String> _imageUrls = [];
  final NoteImages _noteImages = NoteImages();
  final CollectionReference _noteCollection =
      FirebaseFirestore.instance.collection('notes');

  Future<void> _updateImages() async {
    setState(() {
      _isLoading = true;
    });
    final imageUrls = await _noteImages.uploadImages(_selectedImages);
    await _noteCollection.add({
      'imageUrls': imageUrls,
    });
    setState(() {
      _isLoading = false;
    });
    _showSnackbar('Images updated successfully');
  }

  void _removeImage(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title:
            const Text('Manage Images', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            IconButton(
              onPressed: _updateImages,
              icon: const Icon(Icons.save, color: Colors.black),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1.5),
            _buildSelectedImagesList(),
            _buildExistingImagesList(),
            const SizedBox(height: 20), // Space between elements
            _buildAddImagesButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImagesButton() {
    return ElevatedButton.icon(
      onPressed: _pickImages,
      icon: const Icon(Icons.add_a_photo, color: Colors.black),
      label: const Text('Add Images', style: TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  Widget _buildSelectedImagesList() {
    if (_selectedImages.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            final image = _selectedImages[index];
            return _buildImageThumbnail(image, () => _removeImage(image));
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildExistingImagesList() {
    if (widget.note.images.isNotEmpty) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.note.images.length,
          itemBuilder: (context, index) {
            final imageUrl = widget.note.images[index];
            return GestureDetector(
              onTap: () => _showImageDialog(imageUrl),
              child: _buildImageThumbnail(
                imageUrl,
                () => _confirmDeleteImage(imageUrl),
              ),
            );
          },
        ),
      );
    }
    return const Text(
      "No images uploaded.",
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Widget _buildImageThumbnail(dynamic image, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image is File
                ? Image.file(image, fit: BoxFit.cover)
                : Image.network(image, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }

  Future<void> _confirmDeleteImage(String imageUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.noteRepository.deleteImage(widget.note.id!, imageUrl);
        setState(() {
          _imageUrls.remove(imageUrl);
        });
        _showSnackbar('Image deleted successfully');
      } catch (e) {
        _showSnackbar('Error deleting image: $e');
      }
    }
  }
}
