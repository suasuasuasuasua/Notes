import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/constants/routes.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
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
                String snackbarMessage = 'Successfully signed in!';
                /// Create an account for the user and store the information in
                /// Firebase
                try {
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
                /// Catch any exceptions that may arise and capture it into a
                /// message that the snackbar can display
                on FirebaseAuthException catch (e) {
                  snackbarMessage = "Sign-in failed.\n ${switch (e.code) {
                    'user-not-found' => 'The given email is invalid.',
                    'wrong-password' => 'The password is invalid.',
                    'unknown' => 'One or more of the fields are empty.',
                    _ => e.message
                  }}";
                }
                /// Display the snackbar message after processing
                finally {
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
              },
              key: const Key('signinButton'),
              child: const Text('Sign-in')),

          const SizedBox(
            height: 10,
          ),

          /// A button that allows the user to register
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Not registered? Register here!'),
          )
        ],
      ),
    );
  }
}
