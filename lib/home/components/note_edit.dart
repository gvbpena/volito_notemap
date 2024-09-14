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
    final action = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 2),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (action == null || action == 2) return; // Cancel or not selected

    XFile? pickedFile;
    if (action == 1) {
      // Gallery
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        final storageRef = _storage
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          _imageUrls.add(downloadUrl);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  void _removeImage(String imageUrl) {
    setState(() {
      _imageUrls.remove(imageUrl);
    });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Content input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Google Maps widget
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation ?? const LatLng(14.5995, 120.9842),
                  zoom: 12,
                ),
                onTap: _onMapTap,
                onCameraMove: (CameraPosition position) {
                  setState(() {
                    _selectedLocation = position.target;
                  });
                },
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
            ),
            const SizedBox(height: 16),

            // Pick images button
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image, color: Colors.white),
              label: const Text(
                'Pick Images',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Display selected images
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _imageUrls[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(imageUrl),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeImage(imageUrl),
                            ),
                          ),
                        ],
                      ),
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
