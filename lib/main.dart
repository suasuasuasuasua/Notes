/// https://console.firebase.google.com/u/0/
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      useMaterial3: false,
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // `late` allows these variables to be assigned values 'later'
  late final TextEditingController _email;
  late final TextEditingController _password;

  // Called by Flutter automatically when the home page is created
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // Whenever the home page dies or goes out of memory, Flutter will
  // automatically call dispose to take care of 'loose ends'
  // Since we have created TextEditingControllers, we are also repsonsible for
  // diposing of them when we are finished using them
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      // A future builder waits until the defined 'future' has completed before
      // building the widget for display
      body: FutureBuilder(
        // In this case, the future is to initialize the Firebase app with
        // default options to each platform
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        // The builder has parameters of the context and snapshot. The context
        // is the app's current state. The snapshot is the result of the
        // future; it is a way to get the results of the future's computation,
        // i.e. did it start? did it fail? is it in progress? did it terminate
        // successfully
        builder: (context, snapshot) {
          return switch (snapshot.connectionState) {
            // We only return the sign-in widget view if the future is
            // completely finished
            ConnectionState.done => Column(
                children: [
                  // The username and password fields have a few settings that are standard
                  // for a higher quality user experience
                  // TODO: Add validators
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: _email,
                    key: const Key('Username Field'),
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                  // TODO: Add validators
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    controller: _password,
                    key: const Key('Password Field'),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    // The register button has an asynchronous callback function
                    // because we need to authenticate the user using Firebase.
                    // Authentication does not necessarily happen instananeously
                    // because we can use third party SSO solutions like Apple and
                    // Twitter. Here, we use FirebaseAuth to create a user with the
                    // given email and password
                    onPressed: () async {
                      // Before we can register the user, we need to initialize Firebase
                      // based on the current platform. Moreover, we need to tell
                      // Firebase the authentication method
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _email.text, password: _password.text);
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            // If the future is not finished processing, then simply print a
            // loading screen
            _ => const Center(
                child: CircularProgressIndicator(),
              ),
          };
        },
      ),
    );
  }
}
