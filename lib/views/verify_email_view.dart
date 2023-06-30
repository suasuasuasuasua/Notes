import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      "We've sent you an email verification. Please verify your email address."),
                ),
                const SizedBox(height: 15),
                const SizedBox(
                  width: 300,
                  child: Text(
                      "If you haven't received the email verification, click the button below"),
                ),
                const SizedBox(height: 15),
                // Request Firebase to send an email verification
                OutlinedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  },
                  child: const Text('Send email verification.'),
                ),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Sign out and return to registration.'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
