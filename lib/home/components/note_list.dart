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
    final sortedNotes = List<Note>.from(notes);
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
            color: Colors.white, // White background for the card
            elevation: 1, // Minimal shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: const FlutterLogo(size: 40),
              title: Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                note.createdAt != null
                    ? DateFormat.yMMMd().format(note.createdAt!)
                    : 'No date available',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.more_vert,
                  color: Colors.black54), // Black icon
              onTap: () => onNoteTap(note),
            ),
          ),
        );
      },
    );
  }
}
