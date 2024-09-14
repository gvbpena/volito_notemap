// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'note_model.dart';

// class NoteRepository {
//   final CollectionReference _noteCollection =
//       FirebaseFirestore.instance.collection('notes');
//   final user = FirebaseAuth.instance.currentUser;

//   // Check if the user is authenticated
//   void _checkAuth() {
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }
//   }

//   // Add a new note to Firestore
//   Future<void> addNote(Note note) async {
//     _checkAuth();
//     try {
//       await _noteCollection.add({
//         'title': note.title,
//         'content': note.content,
//         'createdAt': note.createdAt?.toIso8601String(),
//         'location': note.location != null
//             ? {
//                 'latitude': note.location!.latitude,
//                 'longitude': note.location!.longitude,
//               }
//             : null,
//         'authorId': user!.uid,
//         'imageUrls': note.imageUrls ?? [],
//       });
//     } catch (e) {
//       throw Exception('Error adding note to Firebase: $e');
//     }
//   }

//   // Get a note by ID
//   Future<Note?> getNoteById(String id) async {
//     try {
//       final doc = await _noteCollection.doc(id).get();
//       return doc.exists
//           ? Note.fromMap(doc.data() as Map<String, dynamic>, doc.id)
//           : null;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Retrieve all notes belonging to the current user
//   Stream<List<Note>> getAllNotes() {
//     _checkAuth();
//     return _noteCollection
//         .where('authorId', isEqualTo: user!.uid)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return Note.fromMap(data, doc.id);
//       }).toList();
//     });
//   }

//   // Update a note
//   Future<void> updateNote(String id,
//       {String? title, String? content, LatLng? location}) async {
//     _checkAuth();
//     final updateData = <String, dynamic>{};
//     if (title != null) updateData['title'] = title;
//     if (content != null) updateData['content'] = content;
//     if (location != null) {
//       updateData['location'] = {
//         'latitude': location.latitude,
//         'longitude': location.longitude,
//       };
//     }
//     if (updateData.isEmpty) return; // Nothing to update

//     try {
//       await _noteCollection.doc(id).update(updateData);
//     } catch (e) {
//       throw Exception('Error updating note: $e');
//     }import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'note_model.dart';

// class NoteRepository {
//   final CollectionReference _noteCollection =
//       FirebaseFirestore.instance.collection('notes');

//   // Add a new note to Firestore
//   Future<void> addNote(Note note, List<String> imageUrls) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }

//     try {
//       await _noteCollection.add({
//         'title': note.title,
//         'content': note.content,
//         'createdAt': note.createdAt?.toIso8601String(),
//         'location': note.location != null
//             ? {
//                 'latitude': note.location!.latitude,
//                 'longitude': note.location!.longitude,
//               }
//             : null,
//         'authorId': user.uid,
//         'imageUrls': imageUrls, // Image URLs passed from note_images.dart
//       });
//     } catch (e) {
//       throw Exception('Error adding note to Firebase: $e');
//     }
//   }

//   // Get a note by ID
//   Future<Note?> getNoteById(String id) async {
//     try {
//       final doc = await _noteCollection.doc(id).get();
//       if (doc.exists) {
//         return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Retrieve all notes belonging to the current user
//   Stream<List<Note>> getAllNotes() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }

//     return _noteCollection
//         .where('authorId', isEqualTo: user.uid)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return Note(
//           id: doc.id,
//           title: data['title'] as String,
//           content: data['content'] as String,
//           createdAt: DateTime.parse(data['createdAt'] as String),
//           location: data['location'] != null
//               ? LatLng(
//                   (data['location']['latitude'] as num).toDouble(),
//                   (data['location']['longitude'] as num).toDouble(),
//                 )
//               : null,
//           authorId: data['authorId'] as String?,
//           imageUrls: (data['imageUrls'] as List<dynamic>?)
//               ?.map((e) => e as String)
//               .toList(),
//         );
//       }).toList();
//     });
//   }

//   // Update a note
//   Future<void> updateNote(String id, Note updatedNote,
//       {String? title, String? content, LatLng? location}) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }

//     try {
//       await _noteCollection.doc(id).update({
//         'title': title,
//         'content': content,
//         'location': location != null
//             ? {
//                 'latitude': location.latitude,
//                 'longitude': location.longitude,
//               }
//             : null,
//         'authorId': user.uid,
//       });
//     } catch (e) {
//       throw Exception('Error updating note: $e');
//     }
//   }

//   // Delete a note
//   Future<void> deleteNoteById(String id) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception('User not authenticated');
//     }

//     try {
//       await _noteCollection.doc(id).delete();
//     } catch (e) {
//       throw Exception('Error deleting note: $e');
//     }
//   }
// }

//   }

//   // Delete a note
//   Future<void> deleteNoteById(String id) async {
//     _checkAuth();
//     try {
//       await _noteCollection.doc(id).delete();
//     } catch (e) {
//       throw Exception('Error deleting note: $e');
//     }
//   }
// }
