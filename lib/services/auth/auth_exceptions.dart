import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/util/extensions.dart';

extension PrintException on FirebaseAuthException {
  String toErrorMessage() => '${code.split('-').join(' ').toCapitalized()}.';
}

/// Sign-in exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

/// Registration exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

/// Generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
