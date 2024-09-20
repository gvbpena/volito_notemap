import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0, left: 8.0), // Add left padding
              child: TextButton(
                onPressed: _updateNote,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                        color: Colors.black26), // Optional border
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
              height: 450,
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
            ),
          ],
        ),
      ),
    );
  }
}
