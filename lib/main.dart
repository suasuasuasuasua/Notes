/// https://console.firebase.google.com/u/0/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/views/login_view.dart';
import 'package:notes_app/firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(buildApp());
}

Widget buildApp() {
  return MaterialApp(
    title: 'Notes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
    home: const LoginView(),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          return switch (snapshot.connectionState) {
            ConnectionState.done => const Text('Done'),
            _ => const Center(
                child: CircularProgressIndicator(),
              )
          };
        },
      ),
    );
  }
}
