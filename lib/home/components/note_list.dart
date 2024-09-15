import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import this for date formatting
import '../../models/note_model.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note note) onNoteTap;

  const NoteList({
    super.key,
    required this.notes,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort notes by createdAt in descending order
    final sortedNotes =
        List<Note>.from(notes); // Create a copy of the notes list
    sortedNotes.sort(
        (a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 1);

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          child: Card(
            elevation: 5, // Added more elevation for a shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Less curved border
            ),
            child: ListTile(
              leading: const FlutterLogo(),
              title: Text(
                note.title,
                style: const TextStyle(
                  fontSize: 14, // Smaller font size for the title
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Format the createdAt date and display it in the subtitle
              subtitle: Text(
                note.createdAt != null
                    ? DateFormat.yMMMd().format(note.createdAt!) // Format date
                    : 'No date available', // Handle null case
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.more_vert),
              onTap: () => onNoteTap(note),
            ),
          ),
        );
      },
    );
  }
}
