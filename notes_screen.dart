import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatefulWidget {
  final String? docId;
  final String? existingTitle;
  final String? existingDesc;

  const NotesScreen({
    super.key,
    this.docId,
    this.existingTitle,
    this.existingDesc,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.existingTitle ?? '';
    _descController.text = widget.existingDesc ?? '';
  }

  Future<void> _saveNote() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('User not logged in');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter a title');
      return;
    }

    try {
      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('notes').add({
          'title': _titleController.text.trim(),
          'desc': _descController.text.trim(),
          'uid': user.uid,
          'time': Timestamp.now(),
        });
        _showMessage('Note added successfully');
      } else {
        await FirebaseFirestore.instance.collection('notes').doc(widget.docId).update({
          'title': _titleController.text.trim(),
          'desc': _descController.text.trim(),
        });
        _showMessage('Note updated successfully');
      }

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, '/allNotes');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
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
      backgroundColor: Colors.blueGrey[50], // light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Note Title',
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Note Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: Icon(isEditing ? Icons.save : Icons.note_add),
                  label: Text(isEditing ? 'Update Note' : 'Save Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
