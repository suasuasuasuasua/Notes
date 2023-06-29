import 'package:flutter/material.dart';

Widget textFormBuilder(
    {required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String label,
    required TextEditingController controller,
    required String key,
    bool hidden = false}) {
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
            onFieldSubmitted: (value) {
              if (formKey.currentState!.validate()) {
                formKey.currentState?.save();
              }
            },
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
