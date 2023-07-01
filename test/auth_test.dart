/// Tests for the authentication services using mocking
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {}

class NotInitializedException implements Exception {}

/// Mock class to simulate authentication procedures
class MockAuthProvider implements AuthProvider {
  /// Track whether the authentication service has been initialized yet
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Track the user as an AuthUser
  AuthUser? _user;

  /// Simulate creating a user, which is really just logging them in
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  /// Return the current user
  @override
  AuthUser? get currentUser => _user;

  /// Wait, then set the app to be initialized
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  /// Log the user out (if they are logged in) after a brief delay.
  /// Set the current user to null, meaning that there is no current user
  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  /// Log the user in, but throw exceptions on certain inputs
  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    return Future.value(AuthUser(isEmailVerified: false, email: email));
  }

  /// Ensure that the auth service is initialized and that the user is not null
  /// Then wait a moment before restting isEmailVerified to true on the user
  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));

    _user = AuthUser(isEmailVerified: true, email: user.email);
  }
}
