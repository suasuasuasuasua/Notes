import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/util/widget_builder.dart';

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

  /// Register the user with the given credentials
  void authenticateUser() async {
    String snackbarMessage = 'Successfully signed in!';
    // Create an account for the user and store the information in Firebase
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      snackbarMessage = "Sign-in failed.\n ${switch (e.code) {
        'user-not-found' => 'The given email is invalid.',
        'wrong-password' => 'The password is invalid.',
        'unknown' => 'One or more of the fields are empty.',
        _ => e.message
      }}";
    } finally {
      // Check that the current context is in the widget tree to act on it. We
      // need this guard after the async gap
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('registration_snackbar'),
            duration: const Duration(seconds: 2),
            content: Center(
              child: Text(
                snackbarMessage,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        textFormBuilder(
          context: context,
          label: 'Email',
          controller: _emailController,
          key: 'emailTextfield',
        ),
        textFormBuilder(
          context: context,
          label: 'Password',
          controller: _passwordController,
          key: 'passwordTextfield',
          hidden: true,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 10,
            ),
            onPressed: () async {
              authenticateUser();
            },
            key: const Key('signinButton'),
            child: const Text('Sign-in')),
      ],
    );
  }
}
