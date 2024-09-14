import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';

class NoteAdd extends StatefulWidget {
  final NoteRepository noteRepository;

  const NoteAdd({
    super.key,
    required this.noteRepository,
  });

  @override
  NoteAddState createState() => NoteAddState();
}

class NoteAddState extends State<NoteAdd> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  LatLng? _noteLocation;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final note = Note(
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      location: _noteLocation,
    );

    await widget.noteRepository.addNote(note);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _pickLocation(LatLng location) {
    setState(() {
      _noteLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _addNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Note Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Note Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pick Location (optional):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _noteLocation != null
                ? Text(
                    'Selected Location: ${_noteLocation!.latitude}, ${_noteLocation!.longitude}',
                    style: const TextStyle(fontSize: 16),
                  )
                : const Text('No location selected'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 2,
                ),
                onTap: _pickLocation,
                markers: _noteLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: _noteLocation!,
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
