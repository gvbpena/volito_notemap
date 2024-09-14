import 'package:google_maps_flutter/google_maps_flutter.dart';

class Note {
  final String? id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final LatLng? location;
  final String? authorId;
  final List<String>? imageUrls; // Add imageUrls field

  Note({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.location,
    this.authorId,
    this.imageUrls,
  });

  factory Note.fromMap(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
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
      imageUrls: (data['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(), // Parse imageUrls
    );
  }
}
