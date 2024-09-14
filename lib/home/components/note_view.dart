import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';
import 'note_edit.dart';

class NoteView extends StatefulWidget {
  final Note note;
  final NoteRepository noteRepository;

  const NoteView({
    super.key,
    required this.note,
    required this.noteRepository,
  });

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note; // Initialize the note with the passed data
  }

  Future<void> _editNote() async {
    // Navigate to the NoteEdit screen and await the result
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEdit(
          note: _note,
          noteRepository: widget.noteRepository,
        ),
      ),
    );

    // If the user returned with an updated note, update the UI
    if (updatedNote != null) {
      setState(() {
        _note = updatedNote; // Update the current note with the edited one
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editNote, // Edit button to open the NoteEdit screen
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _note.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _note.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (_note.location != null)
              Column(
                children: [
                  Text('Latitude: ${_note.location!.latitude}'),
                  Text('Longitude: ${_note.location!.longitude}'),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _note.location ?? const LatLng(0, 0),
                  zoom: 15,
                ),
                markers: {
                  if (_note.location != null)
                    Marker(
                      markerId: const MarkerId('view_location'),
                      position: _note.location!,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
