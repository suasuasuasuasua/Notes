// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
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
      signinButtonKey = 'signinButton';

  final emailField = find.byKey(const Key(emailTextfieldKey)),
      passwordField = find.byKey(const Key(passwordTextfieldKey)),
      signinButton = find.byKey(const Key(signinButtonKey));

  // /// Define a function that tests inputs on the fields and validates assertions
  // testField(WidgetTester tester,
  //     {required Finder testedField,
  //     required String testMessage,
  //     required String? errorMessage}) async {

  //   await tester.enterText(testedField, testMessage);
  //   await tester.pump(const Duration(seconds: 10));
  //   await tester.tap(signinButton);
  //   await tester.pump(const Duration(seconds: 10));
  //   expect(
  //       find.descendant(
  //           of: testedField, matching: find.text(errorMessage ?? '')),
  //       (errorMessage == null) ? findsNothing : findsOneWidget);
  // }

  group('Initial Build Verification', () {
    testWidgets('Verify text fields and buttons are present',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const HomePage()));
      await tester.pumpAndSettle();

      // Find the register text on the home registration page
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

      // Find the username, password, and confirmation field boxes
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Find the register button on the home registration page
      expect(signinButton, findsOneWidget);
    });

    testWidgets('Verify input is working in the text fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(const HomePage()));
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
}
