import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notes_screen.dart';

class AllNotesScreen extends StatelessWidget {
  const AllNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference notesCollection =
    FirebaseFirestore.instance.collection('notes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: notesCollection
            .where('uid', isEqualTo: uid)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet. Tap + to create one!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = notes[index];
              final noteId = note.id;
              final title = note['title'] ?? 'Untitled';
              final desc = note['desc'] ?? '';

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  title: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotesScreen(
                                docId: noteId,
                                existingTitle: title,
                                existingDesc: desc,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await notesCollection.doc(noteId).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Note deleted'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red[400],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          Navigator.pushNamed(context, '/addNote');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
