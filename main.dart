import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'notes_screen.dart';
import 'all_notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Note App',
    theme: ThemeData(primarySwatch: Colors.blue),
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginScreen(),
      '/addNote': (context) => const NotesScreen(),
      '/allNotes': (context) => const AllNotesScreen(),
    },
  );
  }
}