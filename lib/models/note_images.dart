import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class NoteImages {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String> uploadImage(File image) async {
    try {
      final fileName = path.basename(image.path);
      final storageRef = _storage.ref().child('images/$fileName');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Upload multiple images and return URLs
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final imageUrls =
          await Future.wait(images.map((image) => uploadImage(image)));
      return imageUrls;
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  addImagesToNote(List<File> selectedImages) {}
}
