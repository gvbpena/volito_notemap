import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volito_mobile_test/models/note_images.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';

class NoteEdit extends StatefulWidget {
  final Note note;
  final NoteRepository noteRepository;

  const NoteEdit({
    super.key,
    required this.note,
    required this.noteRepository,
  });

  @override
  _NoteEditState createState() => _NoteEditState();
}

class _NoteEditState extends State<NoteEdit> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  LatLng? _selectedLocation;
  List<String> _imageUrls = [];
  bool _isLoading = false;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final NoteImages _noteImages = NoteImages();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedLocation = widget.note.location;
    _imageUrls = widget.note.imageUrls ?? [];
  }

  Future<void> _updateNote() async {
    setState(() => _isLoading = true);

    try {
      List<String> newImageUrls = [];

      if (_selectedImages.isNotEmpty) {
        newImageUrls = await _noteImages.uploadImages(_selectedImages);
      }

      // Update the note's other details
      await widget.noteRepository.updateNote(
        widget.note.id!,
        title: _titleController.text,
        content: _contentController.text,
        location: _selectedLocation,
      );

      // Add new image URLs to the note
      if (newImageUrls.isNotEmpty) {
        await widget.noteRepository
            .addImagesToNote(widget.note.id!, newImageUrls);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating note: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  void _showImage(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(image, fit: BoxFit.contain),
      ),
    );
  }

  void _onMapTap(LatLng location) {
    setState(() => _selectedLocation = location);
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() => _selectedLocation = newPosition);
  }

  void _removeImage(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
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
        await widget.noteRepository.deleteImage(widget.note.id!, imageUrl);
        setState(() {
          _imageUrls.remove(imageUrl);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: TextButton(
                onPressed: _updateNote,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black26),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.black26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_titleController, 'Title'),
            const SizedBox(height: 16),
            _buildTextField(_contentController, 'Content', maxLines: 5),
            const SizedBox(height: 16),
            _buildMap(),
            const Text('Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildAddImagesButton(),
            _buildSelectedImagesList(),
            const SizedBox(height: 16),
            _buildExistingImagesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int? maxLines}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 350,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation ?? const LatLng(14.5995, 120.9842),
          zoom: 12,
        ),
        onTap: _onMapTap,
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('selected-location'),
                  position: _selectedLocation!,
                  draggable: true,
                  onDragEnd: _onMarkerDragEnd,
                ),
              }
            : {},
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
              onTap: () => _showImage(File(imageUrl)),
              child: _buildImageThumbnail(
                  imageUrl, () => _confirmDeleteImage(imageUrl)),
            );
          },
        ),
      );
    } else {
      return const Text("No images uploaded.",
          style: TextStyle(fontSize: 16, color: Colors.grey));
    }
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
}
