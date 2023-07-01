/// https://console.firebase.google.com/u/0/
import 'package:flutter/material.dart';

import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_services.dart';
import 'package:notes_app/views/login_view.dart';
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
      verifyEmailRoute: (BuildContext context) => const VerifyEmailView(),
    },
    home: page,
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        return switch (snapshot.connectionState) {
          ConnectionState.done => switch (AuthService.firebase().currentUser) {
              null => const LoginView(),
              _ =>
                (AuthService.firebase().currentUser?.isEmailVerified ?? false)
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
