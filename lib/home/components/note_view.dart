import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';
import 'note_edit.dart';

class NoteView extends StatelessWidget {
  final Note note;
  final NoteRepository noteRepository;

  const NoteView({
    super.key,
    required this.note,
    required this.noteRepository,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng? location = note.location;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEdit(
                    note: note,
                    noteRepository: noteRepository,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                note.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (location != null)
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('note-location'),
                        position: location,
                      ),
                    },
                    zoomControlsEnabled: false,
                  ),
                ),
              const SizedBox(height: 16),
              if (note.imageUrls != null && note.imageUrls!.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: note.imageUrls!.length,
                    itemBuilder: (context, index) {
                      final imageUrl = note.imageUrls![index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(imageUrl),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
