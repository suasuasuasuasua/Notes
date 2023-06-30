import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/util/widget_builder.dart';
import 'package:notes_app/views/dialogue_popups.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController, _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Email textfield
            textFormBuilder(
              context: context,
              label: 'Email',
              controller: _emailController,
              key: 'emailTextfield',
            ),

            /// Password textfield
            textFormBuilder(
              context: context,
              label: 'Password',
              controller: _passwordController,
              key: 'passwordTextfield',
              hidden: true,
            ),

            /// A button that signs the user in with the given credentials
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  String snackbarMessage = 'Successfully signed in!';

                  try {
                    /// Create an account for the user and store the information in
                    /// Firebase
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text);

                    /// If the sign-in attempt was succesful, then move to the
                    /// notes route
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                      );
                    }
                  }
                  // Catch any exceptions from Firebase that may arise
                  on FirebaseAuthException catch (e) {
                    snackbarMessage = "Sign-in failed.\n ${switch (e.code) {
                      'user-not-found' => 'The given email is invalid.',
                      'wrong-password' => 'The password is invalid.',
                      'unknown' => 'One or more of the fields are empty.',
                      _ => e.message
                    }}";
                  }
                  // Catch generic exceptions
                  on Exception catch (e) {
                    snackbarMessage =
                        'An error has occurred ${e.toString()}. Try again.';
                  }
                  // Display the snackbar message after processing
                  finally {
                    displaySnackbar(context, snackbarMessage);
                  }
                },
                key: const Key('signinButton'),
                child: const Text('Sign-in')),

            const SizedBox(
              height: 10,
            ),

            /// A button that allows the user to sign in
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (Route route) => false,
                );
              },
              child: const Text('Not registered? Register here!'),
            )
          ],
        ),
      ),
    );
  }
}
