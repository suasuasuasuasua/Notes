import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_services.dart';

import 'package:notes_app/style/widget_builder.dart';
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
      appBar: appBarBuilder(title: 'Register'),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),

            /// Email Field
            textFieldBuilder(
              context: context,
              label: 'Email',
              controller: _emailController,
              key: 'emailTextfield',
              inputType: TextInputType.emailAddress,
            ),

            /// Password Field
            textFieldBuilder(
              context: context,
              label: 'Password',
              controller: _passwordController,
              key: 'passwordTextfield',
              hidden: true,
              inputType: TextInputType.multiline,
            ),

            /// Confirm Password Field
            textFieldBuilder(
              context: context,
              label: 'Confirm password',
              controller: _confirmPasswordController,
              key: 'confirmTextfield',
              hidden: true,
              inputType: TextInputType.multiline,
            ),

            /// Registration button
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  late final String snackbarMessage;

                  try {
                    /// Create an account for the user and store the information in
                    /// Firebase and catch any errors that may arise
                    await AuthService.firebase().createUser(
                        email: _emailController.text,
                        password: _passwordController.text);

                    /// Ensure that the passwords match between the two fields
                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      throw PasswordsNotMatching();
                    }

                    // /// Send an email verification to the user before they are
                    // /// taken to the next page
                    // await AuthService.firebase().sendEmailVerification();

                    /// After a successful registration, the user needs to
                    /// confirm their email
                    if (context.mounted) {
                      snackbarMessage = 'Successfully registered.';
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    }
                  }
                  // Catch all exceptions and save the toString()
                  catch (e) {
                    snackbarMessage = e.toString();
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
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (Route route) => false,
                  );
                },
                child: const Text('Already registered? Login here!'))
          ],
        ),
      ),
    );
  }
}
