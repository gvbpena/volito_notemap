import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'components/note_add.dart';
import 'components/note_list.dart';
import 'components/note_list_map.dart';
import 'components/note_view.dart';
import '../../models/note_model.dart';
import '../../models/note_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final NoteRepository noteRepo = NoteRepository();
  String searchQuery = '';
  int currentIndex = 0;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final authService = AuthService();
    final user = authService.currentUser;
    if (user != null) {
      final name = await authService.getUserName();
      setState(() {
        userName = name ?? 'User';
        userEmail = user.email;
      });
    }
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  Future<void> openAddNoteScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAdd(noteRepository: noteRepo),
      ),
    );
    // After returning from NoteAdd, notes will automatically refresh since we use StreamBuilder.
  }

  void onBottomNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget buildListView() {
    return Expanded(
      child: StreamBuilder<List<Note>>(
        stream: noteRepo.getAllNotes(), // Real-time stream of notes.
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notes available.'));
          }

          // Filter notes based on the search query.
          final notes = snapshot.data!
              .where((note) =>
                  note.title.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return NoteList(
            notes: notes,
            onNoteTap: (note) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteView(
                    note: note,
                    noteRepository: noteRepo,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildMapView() {
    return Expanded(
      child: StreamBuilder<List<Note>>(
        stream: noteRepo.getAllNotes(), // Real-time stream of notes.
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notes available.'));
          }

          // Filter notes based on the search query.
          final notes = snapshot.data!
              .where((note) =>
                  note.title.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return NoteListMap(
            notes: notes,
            onNoteTap: (note) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteView(
                    note: note,
                    noteRepository: noteRepo,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('NoteMap',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: () async {
              await AuthService().signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome $userName!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      'Email: ${userEmail ?? 'Not available'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors
                            .blueGrey[800], // Darker gray for the description
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Capture and organize your notes with map integration for easy location tagging and seamless note management.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors
                            .blueGrey[800], // Darker gray for the description
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.8), // Slightly opaque background
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.blueAccent),
                        hintText: "Search notes",
                        hintStyle:
                            TextStyle(color: Colors.grey[600], fontSize: 16),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16), // Adjust vertical padding for height
                        isDense: false, // Ensures padding changes are applied
                      ),
                      style: const TextStyle(
                          fontSize: 16), // Adjust text size if needed
                    )),
              ),
            ],
            currentIndex == 0 ? buildListView() : buildMapView(),
          ],
        ),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: openAddNoteScreen,
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onBottomNavTap,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
