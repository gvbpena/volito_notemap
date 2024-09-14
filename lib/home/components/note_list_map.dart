import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/note_model.dart';

class NoteListMap extends StatefulWidget {
  final List<Note> notes;
  final void Function(Note note) onNoteTap;

  const NoteListMap({
    super.key,
    required this.notes,
    required this.onNoteTap,
  });

  @override
  _NoteListMapState createState() => _NoteListMapState();
}

class _NoteListMapState extends State<NoteListMap> {
  Note? _selectedNote;

  // Method to display image in a dialog
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

  // Method to build the image carousel
  Widget _buildImageCarousel(List<String>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a set of markers from the notes
    Set<Marker> createMarkers() {
      return widget.notes.map((note) {
        final LatLng location = LatLng(
          note.location?.latitude ?? 0, // Use 0 as fallback for latitude
          note.location?.longitude ?? 0, // Use 0 as fallback for longitude
        );

        return Marker(
          markerId: MarkerId(note.title),
          position: location,
          infoWindow: InfoWindow(
            title: note.title,
            snippet: note.content,
            onTap: () {
              setState(() {
                _selectedNote = note;
              });
              widget.onNoteTap(note); // Notify the parent
            },
          ),
        );
      }).toSet();
    }

    // Calculate the initial camera position based on the first note or fallback
    CameraPosition initialCameraPosition() {
      if (widget.notes.isNotEmpty && widget.notes[0].location != null) {
        return CameraPosition(
          target: LatLng(
            widget.notes[0].location!.latitude,
            widget.notes[0].location!.longitude,
          ),
          zoom: 10,
        );
      }
      // Fallback position if no notes have a valid location
      return const CameraPosition(
        target: LatLng(0, 0), // Default to 0,0 if no location is found
        zoom: 2,
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition(),
              markers: createMarkers(),
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
          if (_selectedNote != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedNote!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedNote!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImageCarousel(_selectedNote!.imageUrls),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
