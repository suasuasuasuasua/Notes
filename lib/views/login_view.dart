import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:notes_app/firebase/firebase_options.dart';
import 'package:notes_app/util/extensions.dart';
import 'package:notes_app/util/widget_builder.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController, _passwordController;
  final _formKey = GlobalKey<FormState>();

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

  void authenticateUser() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                "Successfuly signed in!",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      final errorMessage = e.toErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          return Form(
            key: _formKey,
            child: switch (snapshot.connectionState) {
              ConnectionState.done => Column(
                  children: [
                    textFormBuilder(
                      context: context,
                      formKey: _formKey,
                      label: 'Email',
                      controller: _emailController,
                      key: 'emailTextfield',
                    ),
                    textFormBuilder(
                      context: context,
                      formKey: _formKey,
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
                          if (_formKey.currentState!.validate()) {
                            authenticateUser();
                          }
                        },
                        key: const Key('signinButton'),
                        child: const Text('Sign in')),
                  ],
                ),
              _ => const Center(
                  child: CircularProgressIndicator(),
                ),
            },
          );
        },
      ),
    );
  }
}
