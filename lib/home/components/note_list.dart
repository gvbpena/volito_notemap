import 'package:flutter/material.dart';
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
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.content), // Note content
              const SizedBox(height: 4), // Spacing
              // Text('ID: ${note.id}'), // Note ID displayed here
            ],
          ),
          onTap: () => onNoteTap(note),
        );
      },
    );
  }
}
