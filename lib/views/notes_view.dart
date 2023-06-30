import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          /// Define a popup menu that allows the user to log out
          PopupMenuButton<MenuAction>(
            onSelected: (MenuAction value) async {
              switch (value) {
                /// If the user clicks logout, give them a prompt that confirms
                /// their action. If they still choose to logout, sign the user
                /// out and return to the login route
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                  }
                  break;
              }
            },

            /// Define each of the items on the menu dropdown
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            },
          )
        ],
      ),
      body: const Text('Hello world!'),
    );
  }
}

/// A dialog option that confirms whether the user wants to sign out or not
Future<bool> showLogOutDialog(BuildContext context) {
  // Returns a future bool because the user is not going to answer right away
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },

    /// To return a non-null future, we call .then to fully evaluate showDialog
    /// Since the user can click off of the dialog (and close it), there isn't a
    /// guarantee that the actions will return a boolean. Thus, we can default a
    /// value of false
  ).then((value) => value ?? false);
}
