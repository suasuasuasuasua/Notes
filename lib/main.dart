/// https://console.firebase.google.com/u/0/
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Move material app from MyApp template to here to avoid unnecessary cost of
  // rebuliding on each hot reload
  runApp(buildApp());
}

Widget buildApp() {
  return MaterialApp(
    title: 'Notes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

mixin WidgetBuilders {
  Widget textFormBuilder(
      BuildContext context,
      String label,
      TextEditingController controller,
      String key,
      String? Function(String?) validator,
      {bool hidden = false}) {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextFormField(
              decoration: InputDecoration(
                floatingLabelStyle: const TextStyle(fontSize: 11),
                labelText: label,
                filled: true,
              ),
              controller: controller,
              key: Key(key),
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: hidden,
            ),
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}

class _HomePageState extends State<HomePage> with WidgetBuilders {
  // Define controllers for the text fields to access data stored in these fields
  late final TextEditingController _emailController,
      _passwordController,
      _confirmPasswordController;

  final _formKey = GlobalKey<FormState>();

  // Called by Flutter automatically when the home page is created
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  // Whenever the home page dies or goes out of memory, Flutter will
  // automatically call dispose to take care of 'loose ends'
  // Since we have created TextEditingControllers, we are also repsonsible for
  // diposing of them when we are finished using them
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
        title: const Text('Registration Page'),
        centerTitle: true,
      ),
      // A future builder waits until the defined function that returns a result
      // in the future has completed before building the widget for display
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        // The builder has parameters of the context and snapshot. The context
        // is the app's current state. The snapshot is the result of the
        // future; it is a way to get the results of the future's computation,
        // i.e. did it start? did it fail? is it in progress? did it terminate
        // successfully
        builder: (context, snapshot) {
          return Form(
            key: _formKey,
            child: switch (snapshot.connectionState) {
              // We only return the sign-in widget view if the future is finished
              ConnectionState.done => Column(
                  children: [
                    /// Email Field
                    textFormBuilder(
                      context,
                      'Email',
                      _emailController,
                      'emailTextfield',
                      MultiValidator([
                        RequiredValidator(errorText: 'Email required'),
                        EmailValidator(errorText: 'Please enter a valid email')
                      ]),
                    ),
                    textFormBuilder(
                      context,
                      'Password',
                      _passwordController,
                      'passwordTextfield',
                      MultiValidator([
                        RequiredValidator(errorText: 'Password required'),
                        MinLengthValidator(6,
                            errorText:
                                'Password must contain at least six characters'),
                        PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                            errorText:
                                'Password must have at least one special character')
                      ]),
                      hidden: true,
                    ),

                    /// Confirm Password Field
                    textFormBuilder(
                      context,
                      'Confirm password',
                      _confirmPasswordController,
                      'confirmTextfield',
                      (password) {
                        return (password!.isEmpty)
                            ? 'Confirm your password'
                            : MatchValidator(
                                    errorText:
                                        "Those passwords didn't match. Try again.")
                                .validateMatch(
                                    password, _passwordController.text);
                      },
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
                          // Validate the form fields. If any of the fields fail,
                          // stop
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          // Else, create an account for the user and store the
                          // information in Firebase
                          var response = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text);

                          // Check that the current context is in the widget
                          // tree to act on it. We need this guard after the
                          // async gap
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(
                                  child: Text(
                                    "Successfuly authenticated!",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        key: const Key('registerButton'),
                        child: const Text('Register')),
                  ],
                ),
              // If the future is not finished processing, then simply print a
              // loading screen
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
