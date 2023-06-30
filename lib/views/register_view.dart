import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';

import 'package:notes_app/util/widget_builder.dart';
import 'package:notes_app/util/extensions.dart';
import 'package:notes_app/views/dialogue_popups.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _emailController,
      _passwordController,
      _confirmPasswordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          /// Email Field
          textFormBuilder(
            context: context,
            label: 'Email',
            controller: _emailController,
            key: 'emailTextfield',
          ),

          /// Password Field
          textFormBuilder(
            context: context,
            label: 'Password',
            controller: _passwordController,
            key: 'passwordTextfield',
            hidden: true,
          ),

          /// Confirm Password Field
          textFormBuilder(
            context: context,
            label: 'Confirm password',
            controller: _confirmPasswordController,
            key: 'confirmTextfield',
            hidden: true,
          ),

          /// Registration button
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 10,
              ),
              onPressed: () async {
                String snackbarMessage = 'Successfully registered!';

                /// Create an account for the user and store the information in
                /// Firebase and catch any errors that may arise
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text);
                  // Ensure that the passwords match between the two fields
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    throw RegistrationException(
                        cause: 'Passwords do not match.');
                  }
                }
                // Catch any exceptions from Firebase that may arise
                on FirebaseAuthException catch (e) {
                  snackbarMessage = "Registration failed.\n ${switch (e.code) {
                    'unknown' => 'One or more of the fields are empty.',
                    _ => e.message
                  }}";
                }
                // Catch any exceptions on the registration page
                on RegistrationException catch (e) {
                  snackbarMessage = e.toString();
                }
                // Catch generic exceptions
                on Exception catch (e) {
                  snackbarMessage =
                      'An error has occurred (${e.toString()}). Try again.';
                }
                // Display the snackbar with the appropriate message
                finally {
                  displaySnackbar(context, snackbarMessage);
                }
              },
              key: const Key('registerButton'),
              child: const Text('Register')),

          const SizedBox(
            height: 10,
          ),

          /// A button that returns the user to the login page
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (Route route) => false,
                );
              },
              child: const Text('Already registered? Login here!'))
        ],
      ),
    );
  }
}
