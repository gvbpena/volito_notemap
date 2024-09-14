import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    // Load notes in real-time through a stream.
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
          builder: (context) => NoteAdd(noteRepository: noteRepo)),
    );
    // After returning from NoteAdd, notes will automatically refresh since we use StreamBuilder.
  }

  void onBottomNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Home',
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Hi ${user?.email ?? 'there'}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
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
                      .where((note) => note.title
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  // Display either a list or a map of notes.
                  return currentIndex == 0
                      ? NoteList(
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
                        )
                      : NoteListMap(
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddNoteScreen,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
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
