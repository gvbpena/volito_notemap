// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:volito_mobile_test/models/note_images.dart';
// import '../../models/note_model.dart';
// import '../../models/note_repository.dart';

// class NoteEdit extends StatefulWidget {
//   final Note note;
//   final NoteRepository noteRepository;

//   const NoteEdit({
//     super.key,
//     required this.note,
//     required this.noteRepository,
//   });

//   @override
//   _NoteEditState createState() => _NoteEditState();
// }

// class _NoteEditState extends State<NoteEdit> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();
//   final NoteImages _noteImages = NoteImages();
//   List<File> _imageFiles = [];
//   List<File> _selectedImages = [];
//   final ImagePicker _picker = ImagePicker();

//   late CameraPosition _initialPosition;
//   GoogleMapController? _mapController;

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = widget.note.title;
//     _contentController.text = widget.note.content;

//     // Set initial position for the Google Map based on the note's location
//     _initialPosition = CameraPosition(
//       target: LatLng(
//         widget.note.location['latitude'] ?? 0.0,
//         widget.note.location['longitude'] ?? 0.0,
//       ),
//       zoom: 15,
//     );

//     _imageFiles = widget.note.imageUrls != null
//         ? widget.note.imageUrls!.map((url) => File(url)).toList()
//         : [];
//   }

//   Future<void> _pickImages() async {
//     final pickedFiles = await _picker.pickMultiImage();
//     setState(() {
//       _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
//     });
//   }

//   Future<void> _saveNote() async {
//     final updatedNote = Note(
//       id: widget.note.id,
//       title: _titleController.text,
//       content: _contentController.text,
//       createdAt: DateTime.now(),
//       location: widget.note.location,
//       authorId: widget.note.authorId,
//       imageUrls: await _noteImages.uploadImages(_imageFiles),
//     );

//     try {
//       await widget.noteRepository.updateNote(updatedNote.id!,
//           title: updatedNote.title,
//           content: updatedNote.content,
//           location: updatedNote.location,
//           imageUrls: updatedNote.imageUrls);
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving note: $e')),
//       );
//     }
//   }

//   void _showImage(File image) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: SizedBox(
//           width: double.infinity,
//           height: double.infinity,
//           child: Image.file(
//             image,
//             fit: BoxFit.contain,
//           ),
//         ),
//       ),
//     );
//   }

//   void _removeImage(File image) {
//     setState(() {
//       _selectedImages.remove(image);
//     });
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Note'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save, color: Colors.black),
//             onPressed: _saveNote,
//           ),
//         ],
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Title'),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _contentController,
//                 decoration: const InputDecoration(labelText: 'Content'),
//                 maxLines: null,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Images',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Divider(),
//               ElevatedButton.icon(
//                 onPressed: _pickImages,
//                 icon: const Icon(Icons.image, color: Colors.white),
//                 label: const Text(
//                   'Pick Images',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               if (widget.note.images.isNotEmpty)
//                 SizedBox(
//                   height: 120,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: widget.note.images.length,
//                     itemBuilder: (context, index) {
//                       final imageUrl = widget.note.images[index];
//                       return GestureDetector(
//                         onTap: () => _showImage(File(imageUrl)),
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 8.0),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               imageUrl,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               else
//                 const Text(
//                   "No images uploaded.",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               // const Text(
//               //   'Note Location',
//               //   style: TextStyle(
//               //     fontSize: 20,
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//               // const Divider(),
//               // SizedBox(
//               //   height: 300,
//               //   child: GoogleMap(
//               //     initialCameraPosition: _initialPosition,
//               //     onMapCreated: _onMapCreated,
//               //     markers: {
//               //       Marker(
//               //         markerId: const MarkerId('noteLocation'),
//               //         position: LatLng(
//               //           widget.note.location['latitude'] ?? 0.0,
//               //           widget.note.location['longitude'] ?? 0.0,
//               //         ),
//               //       )
//               //     },
//               //   ),
//               // ),
//               // const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
