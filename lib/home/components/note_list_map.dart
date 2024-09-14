import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/note_model.dart';

class NoteListMap extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note note) onNoteTap;

  const NoteListMap({
    super.key,
    required this.notes,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create a set of markers from the notes
    Set<Marker> createMarkers() {
      return notes.map((note) {
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
            onTap: () => onNoteTap(note), // Navigate when marker is tapped
          ),
        );
      }).toSet();
    }

    // Calculate the initial camera position based on the first note or fallback
    CameraPosition initialCameraPosition() {
      if (notes.isNotEmpty && notes[0].location != null) {
        return CameraPosition(
          target: LatLng(
            notes[0].location!.latitude,
            notes[0].location!.longitude,
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
      appBar: AppBar(
        title: const Text('Notes Map'),
        backgroundColor: Colors.blueAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition(),
        markers: createMarkers(),
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
