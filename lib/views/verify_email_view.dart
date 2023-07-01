import 'package:flutter/material.dart';

import 'package:notes_app/services/auth/auth_services.dart';

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
                SizedBox(
                  width: 300,
                  child: Text(
                      "We've sent you an email verification to ${AuthService.firebase().currentUser?.email}.\n\nPlease verify your email address."),
                ),
                const SizedBox(height: 15),
                const SizedBox(
                  width: 300,
                  child: Text(
                      "If you haven't received the email verification, click the button below."),
                ),
                const SizedBox(height: 15),
                // Request Firebase to send an email verification
                OutlinedButton(
                  onPressed: () async {
                    await AuthService.firebase().sendEmailVerification();
                    await AuthService.firebase().logOut();
                  },
                  child: const Text('Send email verification.'),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
