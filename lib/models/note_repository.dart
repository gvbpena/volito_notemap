import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'note_model.dart';
import 'note_images.dart';

class NoteRepository {
  final CollectionReference _noteCollection =
      FirebaseFirestore.instance.collection('notes');
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  final NoteImages _noteImages = NoteImages();

  void _checkAuth() {
    if (_userId == null) throw Exception('User not authenticated');
  }

  Future<void> addNote(Note note) async {
    _checkAuth();
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
        'authorId': _userId,
        'imageUrls': note.imageUrls,
      });
    } catch (e) {
      throw Exception('Error adding note to Firebase: $e');
    }
  }

  Future<Note?> getNoteById(String id) async {
    try {
      final doc = await _noteCollection.doc(id).get();
      if (doc.exists) {
        return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving note by ID: $e');
    }
  }

  Stream<List<Note>> getAllNotes() {
    _checkAuth();
    return _noteCollection
        .where('authorId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateNote(
    String id, {
    String? title,
    String? content,
    LatLng? location,
    List<File>? newImages,
    List<String>? imageUrls,
  }) async {
    _checkAuth();
    final updateData = <String, dynamic>{};

    if (title != null) updateData['title'] = title;
    if (content != null) updateData['content'] = content;
    if (location != null) {
      updateData['location'] = {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };
    }

    if (newImages != null && newImages.isNotEmpty) {
      final List<String> uploadedImageUrls =
          await _noteImages.uploadImages(newImages);
      imageUrls ??= [];
      imageUrls.addAll(uploadedImageUrls);
    }

    if (imageUrls != null) updateData['imageUrls'] = imageUrls;

    if (updateData.isNotEmpty) {
      try {
        await _noteCollection.doc(id).update(updateData);
      } catch (e) {
        throw Exception('Error updating note: $e');
      }
    }
  }

  Future<void> addImagesToNote(String noteId, List<String> newImageUrls) async {
    try {
      await _noteCollection.doc(noteId).update({
        'imageUrls': FieldValue.arrayUnion(newImageUrls),
      });
    } catch (e) {
      throw Exception('Error adding images to note: $e');
    }
  }

  Future<void> deleteNoteById(String id) async {
    _checkAuth();
    try {
      await _noteCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }

  Future<void> deleteImage(String noteId, String imageUrl) async {
    _checkAuth();
    try {
      // final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      // await ref.delete();

      final noteDoc = await _noteCollection.doc(noteId).get();
      if (noteDoc.exists) {
        List<dynamic> imageUrls = (noteDoc['imageUrls'] as List<dynamic>);
        imageUrls.remove(imageUrl);

        await _noteCollection.doc(noteId).update({
          'imageUrls': imageUrls,
        });
      }
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }
}
