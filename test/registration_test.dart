// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/main.dart';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future.delayed(const Duration(minutes: 5));
  }
}

void main() {
  test('Does 1 equal 1?', () {
    expect(1, 1);
  });

  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp(
        name: "UNIT TESTS", options: DefaultFirebaseOptions.currentPlatform);
  });
  tearDown(() async {});

  /// Define the keys and find the fields on the page
  const emailTextfieldKey = 'emailTextfield',
      passwordTextfieldKey = 'passwordTextfield',
      confirmTextfieldKey = 'confirmTextfield',
      registerKey = 'registerButton';

  final emailField = find.byKey(const Key(emailTextfieldKey)),
      passwordField = find.byKey(const Key(passwordTextfieldKey)),
      confirmField = find.byKey(const Key(confirmTextfieldKey)),
      registerButton = find.byKey(const Key(registerKey));

  /// Define the error message that we are looking for
  const emptyEmailMessage = 'Email required',
      invalidEmailMessage = 'Please enter a valid email';

  const emptyPasswordMessage = 'Password required',
      passwordTooShortMessage = 'Password must contain at least six characters',
      passwordMissingSpecialCharMessage =
          'Password must have at least one special character';

  const emptyConfirmMessage = 'Confirm your password',
      confirmationFailMessage = "Those passwords didn't match. Try again.";

  /// Define a function that tests inputs on the fields and validates assertions
  testField(WidgetTester tester,
      {required Finder testedField,
      required String testMessage,
      required String? errorMessage}) async {
    await tester.enterText(testedField, testMessage);
    await tester.pump(const Duration(seconds: 10));
    await tester.tap(registerButton);
    await tester.pump(const Duration(seconds: 10));
    expect(
        find.descendant(
            of: testedField, matching: find.text(errorMessage ?? '')),
        (errorMessage == null) ? findsNothing : findsOneWidget);
  }

  group('Initial Build Verification', () {
    testWidgets('Verify text fields and buttons are present',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Find the register text on the home registration page
      expect(find.widgetWithText(AppBar, 'Registration Page'), findsOneWidget);

      // Find the username, password, and confirmation field boxes
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(confirmField, findsOneWidget);

      // Find the register button on the home registration page
      expect(registerButton, findsOneWidget);
    });

    testWidgets('Verify input is working in the text fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Type in the fields and check that the TextFormFields update
      // correspondingly
      const testEmail = 'tester123@gmail.com';
      await tester.enterText(emailField, testEmail);
      expect(
        (tester.element(emailField).widget as TextFormField).controller?.text,
        testEmail,
      );

      const testPassword = 'password123';
      await tester.enterText(passwordField, testPassword);
      expect(
        (tester.element(passwordField).widget as TextFormField)
            .controller
            ?.text,
        testPassword,
      );
    });
  });

  group('Email Validation', () {
    testWidgets('Valid emails', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var email in [
        'emailWithAtSign@gmail.com',
        'blahblah123456@outlook.com',
        'justinhoang@mines.edu'
      ]) {
        await testField(tester,
            testedField: emailField, testMessage: email, errorMessage: null);
      }
    });

    testWidgets('Invalid empty emails', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await testField(tester,
          testedField: emailField,
          testMessage: '',
          errorMessage: emptyEmailMessage);
    });

    testWidgets('Invalid non-empty emails', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var email in [
        'emailWithNoAtSigns',
        'emailWithTwo@AtSigns@gmail.com',
        'emailWithNonAlphanumericChars#!!@#^&(@gmail.com'
      ]) {
        await testField(tester,
            testedField: emailField,
            testMessage: email,
            errorMessage: invalidEmailMessage);
      }
    });
  });

  group('Password Validation', () {
    testWidgets('Valid passwords', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var password in [
        'abcdef!',
        'blahblah@',
        'thisisaverylongpassword!123'
      ]) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: null);
      }
    });

    testWidgets('Invalid empty passwords', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await testField(tester,
          testedField: passwordField,
          testMessage: '',
          errorMessage: emptyPasswordMessage);
    });

    testWidgets('Invalid not-empty passwords less than six characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      /// Test with malformed emails
      for (var password in ['abc', '!!!2e', 'a!b@']) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: passwordTooShortMessage);
      }
    });

    testWidgets('Invalid not-empty passwords missing special characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      /// Test with malformed emails
      for (var password in [
        'almostagoodpassword',
        'blahblahblah6969',
        'hahahakjsdlfkjashkfjasd123'
      ]) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: passwordMissingSpecialCharMessage);
      }
    });
  });

  group('Password Confirmation Validation', () {
    testWidgets('Password and confirmation match', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var password in [
        'abcdef!',
        'blahblah@',
        'thisisaverylongpassword!123'
      ]) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: null);
        await testField(tester,
            testedField: confirmField,
            testMessage: password,
            errorMessage: null);
      }
    });

    testWidgets('Password and confirmation match, but password is short',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var password in ['abc', 'blah', 'this']) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: passwordTooShortMessage);
        await testField(tester,
            testedField: confirmField,
            testMessage: password,
            errorMessage: null);
      }
    });

    testWidgets('Password and confirmation do not match, but password is short',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var [password, confirmation] in [
        ['abc', 'efg'],
        ['blah', 'babble'],
        ['this', 'issoclose']
      ]) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: passwordTooShortMessage);
        await testField(tester,
            testedField: confirmField,
            testMessage: confirmation,
            errorMessage: confirmationFailMessage);
      }
    });

    testWidgets('Password and confirmation do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (var [password, confirmation] in [
        ['abcdef', 'efghijklmnop'],
        ['mynameisjustin', 'iloveflutter'],
        ['kappacake', 'blah123blah123']
      ]) {
        await testField(tester,
            testedField: passwordField,
            testMessage: password,
            errorMessage: null);
        await testField(tester,
            testedField: confirmField,
            testMessage: confirmation,
            errorMessage: confirmationFailMessage);
      }
    });
  });

  group('Final multi-validation', () {
    testWidgets('Valid entries for all fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await testField(tester,
          testedField: emailField,
          testMessage: 'justinhoang124@gmail.com',
          errorMessage: null);

      await testField(tester,
          testedField: passwordField,
          testMessage: 'blahblahblah123',
          errorMessage: null);

      await testField(tester,
          testedField: confirmField,
          testMessage: 'blahblahblah123',
          errorMessage: null);
    });
  });
}
