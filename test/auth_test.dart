/// Tests for the authentication services using mocking
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final MockAuthProvider provider = MockAuthProvider();
    test('Provider should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot logout if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Initialize should be true after initialization', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () async {
      await provider.initialize();
      expect(provider.currentUser, null);
    });

    test('Provider should be able to initialize in less than two seconds',
        () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to the logIn function', () async {
      await provider.initialize();

      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'blahblahblah',
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: 'blahblah@gmail.com',
        password: 'foobar',
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'blah',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to verify their email', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

/// Mock class to simulate authentication procedures
class MockAuthProvider implements AuthProvider {
  /// Track whether the authentication service has been initialized yet
  /// On start, the initialization should be false
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
    _user = AuthUser(isEmailVerified: false, email: email);
    return Future.value(_user);
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
