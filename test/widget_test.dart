// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/main.dart';

// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  group('User Registration Tests', () {
    testWidgets('Initial Build Test', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Find the register text on the home registration page
      expect(find.widgetWithText(AppBar, 'Register'), findsOneWidget);

      // Find the username and password field boxes
      expect(find.byKey(const Key('Username Field')), findsOneWidget);
      expect(find.byKey(const Key('Password Field')), findsOneWidget);

      // Find the register button on the home registration page
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    testWidgets('Username and Password Fields Entry Test',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Type in the fields and check that the TextFormFields update
      // correspondingly
      const testEmail = 'tester123@gmail.com';
      final usernameField = find.byKey(const Key('Username Field'));
      await tester.enterText(usernameField, testEmail);
      expect(
        (tester.element(usernameField).widget as TextFormField)
            .controller
            ?.text,
        testEmail,
      );

      const testPassword = 'password123';
      final passwordField = find.byKey(const Key('Password Field'));
      await tester.enterText(passwordField, testPassword);
      expect(
        (tester.element(passwordField).widget as TextFormField)
            .controller
            ?.text,
        testPassword,
      );
    });

    testWidgets('Username Validation', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Ensure that the user typed a valid email address
      const goodEmail0 = 'emailWithAtSign@gmail.com';

      const badEmail0 = 'emailWithNoAtSigns';
      const badEmail1 = 'emailWithTwo@AtSigns@gmail.com';
      const badEmail2 = 'emailWithNonAlphanumericChars@gmail.com';

      // Use regex to validate that the username is correct
      expect(1, 1);
    });
  });

  group('TODO Next Set of Tests', () {
    test('Dummy Test', () async {
      expect(1, 1);
    });
  });
}
