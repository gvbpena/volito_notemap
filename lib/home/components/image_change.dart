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
  final Function() onImagesUpdated;

  const ImageChange({
    super.key,
    required this.note,
    required this.noteRepository,
    required this.onImagesUpdated,
  });

  @override
  _ImageChangeState createState() => _ImageChangeState();
}

class _ImageChangeState extends State<ImageChange> {
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final NoteImages _noteImages = NoteImages();
  final CollectionReference _noteCollection =
      FirebaseFirestore.instance.collection('notes');

  Future<void> _updateImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload the images and get the URLs
      final imageUrls = await _noteImages.uploadImages(_selectedImages);

      // Get the document ID
      String documentId = widget.note.id!;

      // Update Firestore document with new image URLs
      await _noteCollection.doc(documentId).update({
        'imageUrls': FieldValue.arrayUnion(imageUrls),
      });

      // Clear selected images after successful update
      setState(() {
        _selectedImages.clear(); // Clear the selected images list
        widget.note.images.addAll(imageUrls); // Add new image URLs to the note
      });

      // Notify parent widget to refresh data
      widget.onImagesUpdated();

      // Show success message
      _showSnackbar('Images updated successfully');
    } catch (e) {
      _showSnackbar('Failed to update images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        title: const Text('Manage Images'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            IconButton(
              onPressed: _updateImages,
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Selected Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSelectedImagesList(),
            const SizedBox(height: 24),
            const Text(
              'Existing Images',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildExistingImagesList(),
            const SizedBox(height: 24),
            _buildAddImagesButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImagesButton() {
    return Center(
      // Center the button for better alignment
      child: ElevatedButton.icon(
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
      ),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  // Enlarged image size and improved spacing
  Widget _buildSelectedImagesList() {
    if (_selectedImages.isNotEmpty) {
      return SizedBox(
        height: 150, // Increased height for larger images
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
    // Display message when no images are selected
    return const Center(
      child: Text(
        'No selected images yet.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildExistingImagesList() {
    if (widget.note.images.isNotEmpty) {
      return SizedBox(
        height: 150, // Increased height for existing images as well
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
      padding:
          const EdgeInsets.only(right: 12.0), // Increased padding for spacing
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12), // Softer corners
            child: image is File
                ? Image.file(image, width: 120, height: 120, fit: BoxFit.cover)
                : Image.network(image,
                    width: 120, height: 120, fit: BoxFit.cover),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete image from the repository or storage
        await widget.noteRepository.deleteImage(widget.note.id!, imageUrl);

        // Remove image URL from the note's images list
        setState(() {
          widget.note.images.remove(imageUrl);
        });

        // Notify the user and refresh the list
        _showSnackbar('Image deleted successfully');
        widget.onImagesUpdated(); // Notify parent to refresh if necessary
      } catch (e) {
        _showSnackbar('Error deleting image: $e');
      }
    }
  }
}
