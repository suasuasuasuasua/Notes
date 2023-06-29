/// https://console.firebase.google.com/u/0/
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/views/login_view.dart';
import 'package:notes_app/firebase/firebase_options.dart';
import 'package:notes_app/views/register_view.dart';

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
      '/login/': (BuildContext context) => const LoginView(),
      '/register/': (BuildContext context) => const RegisterView(),
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
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return const LoginView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
