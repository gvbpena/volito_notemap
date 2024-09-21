import 'package:flutter/material.dart';
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
  }

  void onBottomNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget buildNoteView(bool isMapView) {
    return Expanded(
      child: StreamBuilder<List<Note>>(
        stream: noteRepo.getAllNotes(),
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

          final notes = snapshot.data!
              .where((note) =>
                  note.title.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return isMapView
              ? NoteListMap(
                  notes: notes,
                  onNoteTap: (note) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteView(
                        note: note,
                        noteRepository: noteRepo,
                      ),
                    ),
                  ),
                )
              : NoteList(
                  notes: notes,
                  onNoteTap: (note) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteView(
                        note: note,
                        noteRepository: noteRepo,
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout', style: TextStyle(color: Colors.black)),
          content: const Text('Are you sure you want to logout?',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await AuthService().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out!'),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'NoteMap',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: _handleLogout,
            splashRadius: 24,
            tooltip: 'Logout',
            color: Colors.black,
            hoverColor: Colors.grey[200],
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
                      'Welcome, $userName!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Email: ${userEmail ?? 'Not available'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Capture and organize your notes with map integration for easy location tagging and seamless note management.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    hintText: "Search notes",
                    hintStyle:
                        const TextStyle(color: Colors.black38, fontSize: 16),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
            currentIndex == 0 ? buildNoteView(false) : buildNoteView(true),
          ],
        ),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: openAddNoteScreen,
              backgroundColor: Colors.black,
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text('Add Note', style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onBottomNavTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
