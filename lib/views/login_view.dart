import 'package:flutter/material.dart';

import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_services.dart';
import 'package:notes_app/style/widget_builder.dart';
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
      appBar: appBarBuilder(title: 'Sign in'),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),

            /// Email textfield
            textFieldBuilder(
              context: context,
              label: 'Email',
              controller: _emailController,
              key: 'emailTextfield',
              inputType: TextInputType.emailAddress,
            ),

            /// Password textfield
            textFieldBuilder(
              context: context,
              label: 'Password',
              controller: _passwordController,
              key: 'passwordTextfield',
              hidden: true,
              inputType: TextInputType.multiline,
            ),

            /// A button that signs the user in with the given credentials
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  late final String snackbarMessage;

                  try {
                    /// Create an account for the user and store the information in
                    /// Firebase
                    await AuthService.firebase().logIn(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    final user = AuthService.firebase().currentUser;
                    // Ensure that the user has verified their email before
                    // moving to the notes main UI
                    if (user?.isEmailVerified ?? false) {
                      if (context.mounted) {
                        snackbarMessage = 'Successfully signed in!';
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute,
                          (route) => false,
                        );
                      }
                    }
                    // Ensure the user verifies their email before proceding
                    else {
                      snackbarMessage = 'Please verify your email.';
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(
                          verifyEmailRoute,
                        );
                      }
                    }
                  }
                  // Catch all exceptions and save the toString()
                  catch (e) {
                    snackbarMessage = e.toString();
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
