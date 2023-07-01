import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/util/extensions.dart';

extension PrintException on FirebaseAuthException {
  String toErrorMessage() => '${code.split('-').join(' ').toCapitalized()}.';
}

class AuthException implements Exception {
  final String error;

  AuthException(this.error);
  @override
  String toString() {
    return error;
  }
}

/// Sign-in exceptions
class UserNotFoundAuthException extends AuthException {
  UserNotFoundAuthException()
      : super('A user with this email could not be found.');
}

class WrongPasswordAuthException extends AuthException {
  WrongPasswordAuthException() : super('The email or password is incorrect.');
}

/// Registration exceptions

class PasswordsNotMatching extends AuthException {
  PasswordsNotMatching() : super('Passwords do not match.');
}

class WeakPasswordAuthException extends AuthException {
  WeakPasswordAuthException()
      : super('Weak password.\nPlease use at least 6 characters.');
}

class EmailAlreadyInUseAuthException extends AuthException {
  EmailAlreadyInUseAuthException() : super('This email is already in use.');
}

class InvalidEmailAuthException extends AuthException {
  InvalidEmailAuthException() : super('Invalid email formatting.');
}

/// Generic exceptions
class GenericAuthException extends AuthException {
  GenericAuthException() : super('An error has occured. Try again.');
}

class UserNotLoggedInAuthException extends AuthException {
  UserNotLoggedInAuthException() : super('User is not logged in. Try again.');
}
