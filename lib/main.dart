import 'package:flutter/material.dart';

void main() {
  // Move material app from MyApp template to here to avoid unnecessary cost of
  // rebuliding on each hot reload
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: false,
      ),
      home: const HomePage(),
    ),
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
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Email'),
            controller: _email,
          ),
          TextField(
            decoration: const InputDecoration(hintText: 'Password'),
            controller: _password,
          ),
          TextButton(
            // The register button has an asynchronous callback function because
            // we need to authenticate the user using Firebase. Authentication
            // does not necessarily happen instananeously because we can use third
            // party SSO solutions like Apple and Twitter.
            onPressed: () async => {},
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
