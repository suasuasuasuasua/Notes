/// https://console.firebase.google.com/u/0/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';

import 'package:notes_app/views/login_view.dart';
import 'package:notes_app/firebase/firebase_options.dart';
import 'package:notes_app/views/notes_view.dart';
import 'package:notes_app/views/register_view.dart';
import 'package:notes_app/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Move material app from MyApp template to here to avoid unnecessary cost of
  // rebuliding on each hot reload
  runApp(buildApp(const HomePage()));
}

Widget buildApp(Widget page) {
  return MaterialApp(
    title: 'Notes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
    routes: {
      loginRoute: (BuildContext context) => const LoginView(),
      registerRoute: (BuildContext context) => const RegisterView(),
      notesRoute: (BuildContext context) => const NotesView(),
    },
    home: page,
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        return switch (snapshot.connectionState) {
          ConnectionState.done => switch (FirebaseAuth.instance.currentUser) {
              null => const LoginView(),
              _ => (FirebaseAuth.instance.currentUser!.emailVerified)
                  ? const NotesView()
                  : const VerifyEmailView()
            },
          _ => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
        };
      },
    );
  }
}
