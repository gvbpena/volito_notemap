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

  Future<void> _deleteNoteAndNavigate(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this note?'),
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

    if (shouldDelete == true) {
      try {
        await noteRepository.deleteNoteById(note.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully')),
        );
        Navigator.pushReplacementNamed(
            context, '/home'); // Navigate back to home screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')),
        );
      }
    }
  }

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? location = note.location;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
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
          IconButton(
            icon:
                const Icon(Icons.delete, color: Colors.red), // Red delete icon
            onPressed: () => _deleteNoteAndNavigate(context),
          ),
        ],
        backgroundColor: Colors.blue, // Blue theme color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Blue theme color
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              if (location != null)
                Container(
                  height: 400, // Increased height for the map
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                ),
              const SizedBox(height: 16),
              if (note.imageUrls != null && note.imageUrls!.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: note.imageUrls!.length,
                    itemBuilder: (context, index) {
                      final imageUrl = note.imageUrls![index];
                      return GestureDetector(
                        onTap: () => _showImage(context, imageUrl),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
