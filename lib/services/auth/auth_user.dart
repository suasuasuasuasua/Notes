import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

/// The user class should abstract away the User defined in Firebase
@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;
  const AuthUser(this.isEmailVerified, this.email);

  /// Define a factory function that creates the AuthUser from the Firebase User
  factory AuthUser.fromFirebase(User user) =>
      AuthUser(user.emailVerified, user.email);
}
