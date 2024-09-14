import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  LatLng? _selectedLocation;
  List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isLoading = false;

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
      await widget.noteRepository.updateNote(
        widget.note.id!,
        title: _titleController.text,
        content: _contentController.text,
        location: _selectedLocation,
        imageUrls: _imageUrls,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating note: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTap(LatLng location) {
    setState(() => _selectedLocation = location);
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() => _selectedLocation = newPosition);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(); // No images selected

    final newImageUrls = await Future.wait(
      pickedFiles.map((pickedFile) async {
        final file = File(pickedFile.path);
        try {
          final storageRef = _storage
              .ref()
              .child('images/${DateTime.now().millisecondsSinceEpoch}');
          final uploadTask = storageRef.putFile(file);
          final snapshot = await uploadTask.whenComplete(() {});
          return await snapshot.ref.getDownloadURL();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return '';
        }
      }),
    );

    setState(
        () => _imageUrls.addAll(newImageUrls.where((url) => url.isNotEmpty)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateNote,
            ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Title'),
              const SizedBox(height: 16),
              _buildTextField(_contentController, 'Content', maxLines: null),
              const SizedBox(height: 16),
              _buildMap(),
              const SizedBox(height: 16),
              _buildAddImagesButton(),
              const SizedBox(height: 16),
              if (_imageUrls.isNotEmpty) _buildImageList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int? maxLines}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 400,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(14.5995, 120.9842),
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
    return ElevatedButton(
      onPressed: _pickImages,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: const Text('Add Images'),
    );
  }

  Widget _buildImageList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = _imageUrls[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl),
            ),
          );
        },
      ),
    );
  }
}
