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
  NoteEditState createState() => NoteEditState();
}

class NoteEditState extends State<NoteEdit> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  LatLng? _location;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _location = widget.note.location ??
        const LatLng(0, 0); // Default location if not set
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final updatedTitle = _titleController.text;
    final updatedContent = _contentController.text;

    // Update the note in the repository
    await widget.noteRepository.updateNote(
      widget.note.id!,
      title: updatedTitle,
      content: updatedContent,
      location: _location, // Save the updated location
    );

    // Create an updated Note object
    final updatedNote = Note(
      id: widget.note.id,
      title: updatedTitle,
      content: updatedContent,
      createdAt: widget.note.createdAt,
      location: _location,
      authorId: widget.note.authorId,
    );

    // Pass the updated note back to the previous screen
    // ignore: use_build_context_synchronously
    Navigator.pop(context, updatedNote); // Pass the updated note
  }

  void _onMapCreated(GoogleMapController controller) {}

  // This method updates the location when the user taps on the map
  void _onMapTapped(LatLng position) {
    setState(() {
      _location = position; // Update the note's location
    });
  }

  // This method updates the location when the marker is dragged
  void _onMarkerDragged(LatLng newPosition) {
    setState(() {
      _location = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _location ??
                      const LatLng(0, 0), // Start at the current note location
                  zoom: 15,
                ),
                markers: {
                  if (_location != null)
                    Marker(
                      markerId: const MarkerId('editable_location'),
                      position: _location!,
                      draggable: true,
                      onDragEnd:
                          _onMarkerDragged, // Update location when marker is dragged
                    ),
                },
                onTap: _onMapTapped, // Update location when the map is tapped
              ),
            ),
            const SizedBox(height: 16),
            if (_location != null)
              Column(
                children: [
                  Text('Latitude: ${_location!.latitude}'),
                  Text('Longitude: ${_location!.longitude}'),
                ],
              ),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
