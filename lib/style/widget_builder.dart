import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final isTargetMobile = defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

/// A function that returns a textform with initialized parameters
Widget textFieldBuilder(
    {required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String key,
    required TextInputType inputType,
    bool hidden = false}) {
  return Column(
    children: [
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              // Set the max width of the text field to 80% of the screen width
              // if the user is viewing from a mobile device. Else, set it to
              // 400. However, if the user is viewing the webpage from a mobile
              // device, then
              maxWidth: (isTargetMobile)
                  ? MediaQuery.of(context).size.width * 0.8
                  : (kIsWeb && isTargetMobile
                      ? MediaQuery.of(context).size.width * 0.8
                      : 450.0)),
          child: TextField(
            decoration: InputDecoration(
              floatingLabelStyle: const TextStyle(fontSize: 11),
              labelText: label,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            controller: controller,
            key: Key(key),
            keyboardType: inputType,
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

AppBar appBarBuilder({required String title, actions}) {
  return AppBar(
    title: Text(title),
    actions: actions,
    centerTitle: true,
  );
}
