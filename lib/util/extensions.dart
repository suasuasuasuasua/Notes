import 'package:firebase_auth/firebase_auth.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension PrintException on FirebaseAuthException {
  String toErrorMessage() => '${code.split('-').join(' ').toCapitalized()}.';
}
