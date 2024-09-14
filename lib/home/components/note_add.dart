import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';
import '../../models/note_images.dart';

class NoteAdd extends StatefulWidget {
  final NoteRepository noteRepository;

  const NoteAdd({super.key, required this.noteRepository});

  @override
  _NoteAddState createState() => _NoteAddState();
}

class _NoteAddState extends State<NoteAdd> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  LatLng? _selectedLocation;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final NoteImages _noteImages = NoteImages();

  // Handle map tap to select location
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  // Pick images from gallery
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  // Save note to Firestore
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields and select a location.')),
      );
      return;
    }

    try {
      final imageUrls = await _noteImages.uploadImages(_selectedImages);
      final note = Note(
        title: title,
        content: content,
        createdAt: DateTime.now(),
        location: _selectedLocation,
        imageUrls: imageUrls,
      );
      await widget.noteRepository.addNote(note);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added successfully')),
      );
      Navigator.pop(context); // Close the add note page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote, // Save the note when check button is pressed
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),

            // Content input
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 16),

            // Google Maps widget
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(14.5995, 120.9842), // Default location
                  zoom: 12,
                ),
                onTap: _onMapTap, // Select location by tapping on the map
                markers: _selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected-location'),
                          position: _selectedLocation!,
                        ),
                      }
                    : {},
              ),
            ),
            const SizedBox(height: 16),

            // Pick images button
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Pick Images'),
            ),
            const SizedBox(height: 16),

            // Display selected images
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(_selectedImages[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
