import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'note_model.dart';

class NoteRepository {
  final CollectionReference _noteCollection =
      FirebaseFirestore.instance.collection('notes');

  // Add a new note to Firestore
  Future<void> addNote(Note note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _noteCollection.add({
        'title': note.title,
        'content': note.content,
        'createdAt': note.createdAt?.toIso8601String(),
        'location': note.location != null
            ? {
                'latitude': note.location!.latitude,
                'longitude': note.location!.longitude,
              }
            : null,
        'authorId': user.uid,
        'imageUrls': note.imageUrls, // Save the image URLs
      });
    } catch (e) {
      throw Exception('Error adding note to Firebase: $e');
    }
  }

  // Get a note by ID
  Future<Note?> getNoteById(String id) async {
    try {
      final doc = await _noteCollection.doc(id).get();
      if (doc.exists) {
        return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Retrieve all notes belonging to the current user
  Stream<List<Note>> getAllNotes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _noteCollection
        .where('authorId', isEqualTo: user.uid) // Filter by authorId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Note(
          id: doc.id,
          title: data['title'] as String,
          content: data['content'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          location: data['location'] != null
              ? LatLng(
                  (data['location']['latitude'] as num).toDouble(),
                  (data['location']['longitude'] as num).toDouble(),
                )
              : null,
          authorId: data['authorId'] as String?,
        );
      }).toList();
    });
  }

  // Update a note
  Future<void> updateNote(String id,
      {String? title, String? content, LatLng? location}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _noteCollection.doc(id).update({
        'title': title,
        'content': content,
        'location': location != null
            ? {
                'latitude': location.latitude,
                'longitude': location.longitude,
              }
            : null,
        'authorId': user.uid, // Ensure the authorId is updated
      });
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNoteById(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _noteCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }

  // Search notes by title or content for the current user
  List<Note> searchNotes(String query) {
    if (query.isEmpty) {
      return _allNotes;
    }

    return _allNotes.where((note) {
      final noteTitle = note.title.toLowerCase();
      final noteContent = note.content.toLowerCase();
      final searchQuery = query.toLowerCase();
      return noteTitle.contains(searchQuery) ||
          noteContent.contains(searchQuery);
    }).toList();
  }

  // This will hold the in-memory list of notes
  List<Note> _allNotes = [];

  // Call this method to start listening to notes changes
  Stream<List<Note>> getNoteStream() {
    return getAllNotes().map((notes) {
      _allNotes = notes;
      return notes;
    });
  }
}
