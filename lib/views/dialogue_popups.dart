import 'package:flutter/material.dart';

void displaySnackbar(BuildContext context, String snackbarMessage) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('registration_snackbar'),
        duration: const Duration(seconds: 1),
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

Future<void> showErrorDialog(
    {required BuildContext context, required String text}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('An error has occurred!'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
