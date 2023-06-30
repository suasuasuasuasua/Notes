import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/util/widget_builder.dart';
import 'package:notes_app/util/extensions.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Define controllers for the text fields to access data stored in these
  // fields
  late final TextEditingController _emailController,
      _passwordController,
      _confirmPasswordController;

  // Called by Flutter automatically when the home page is created
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  // Whenever the home page dies or goes out of memory, Flutter will
  // automatically call dispose to take care of 'loose ends' Since we have
  // created TextEditingControllers, we are also repsonsible for diposing of
  // them when we are finished using them
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffolds are generic containers that are more presentable because they
    // automatically include a titlebar, floating buttons, main text, etc.
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
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 10,
              ),
              // The register button has an asynchronous callback
              // function because we need to authenticate the user using
              // Firebase. Authentication does not necessarily happen
              // instananeously because we can use third party SSO
              // solutions like Apple and Twitter. Here, we use
              // FirebaseAuth to create a user with the given email and
              // password
              onPressed: () async {
                String snackbarMessage = 'Successfully registered!';
                // Create an account for the user and store the information in Firebase
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text);
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    throw RegistrationException(
                        cause: 'Passwords do not match.');
                  }
                } on FirebaseAuthException catch (e) {
                  snackbarMessage = "Registration failed.\n ${switch (e.code) {
                    'unknown' => 'One or more of the fields are empty.',
                    _ => e.message
                  }}";
                } on RegistrationException catch (e) {
                  snackbarMessage = e.toString();
                } finally {
                  // Check that the current context is in the widget tree to act on it. We
                  // need this guard after the async gap
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        key: const Key('registrationSnackbar'),
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
              key: const Key('registerButton'),
              child: const Text('Register')),
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login/',
                  (route) => false,
                );
              },
              child: const Text('Already registered? Login here!'))
        ],
      ),
    );
  }
}
