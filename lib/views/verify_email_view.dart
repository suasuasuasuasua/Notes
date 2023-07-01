import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';

import 'package:notes_app/services/auth/auth_services.dart';
import 'package:notes_app/style/widget_builder.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(title: 'Email Verification'),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                      "We've sent an email verification to ${AuthService.firebase().currentUser?.email}."),
                ),
                const SizedBox(height: 15),
                const SizedBox(
                  width: 300,
                  child: Text(
                      "If you haven't received the email verification, click the button below to resend it."),
                ),
                const SizedBox(height: 15),
                // Request Firebase to send an email verification
                OutlinedButton(
                  onPressed: () async {
                    await AuthService.firebase().sendEmailVerification();
                  },
                  child: const Text('Send email verification'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () async {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                  },
                  child: const Text('Return to home page'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
