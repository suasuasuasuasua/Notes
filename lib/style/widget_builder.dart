import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A function that returns a textform with initialized parameters
Widget textFormBuilder(
    {required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String key,
    bool hidden = false}) {
  return Column(
    children: [
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: switch (defaultTargetPlatform) {
            TargetPlatform.iOS ||
            TargetPlatform.android =>
              MediaQuery.of(context).size.width * 0.8,
            _ => (kIsWeb &&
                    (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android))
                ? MediaQuery.of(context).size.width * 0.8
                : 400.0
          }),
          child: TextFormField(
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

AppBar appBarBuilder({required String title, actions}) {
  return AppBar(
    title: Text(title),
    actions: actions,
    centerTitle: true,
  );
}
