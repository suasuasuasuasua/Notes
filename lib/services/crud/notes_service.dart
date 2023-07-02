/// The note service is responsible for faciliating communication with the
/// database

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

import 'crud_constants.dart';
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  /// Open the database if it is not already open
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    /// Find the database in the path and open it
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create the user and note tables
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException catch (_) {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  /// Close the database if it is open
  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    await db.close();
    _db = null;
  }

  /// Helper function that returns the database, or else throws an exception
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    return db;
  }

  /// Create a user given an email
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    // If we find any results with the email, then the user already exists
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    // insert() returns the id at the insertion
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  /// Delete a user from the user given their email
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    // If we couldn't delete a user with the given email, then throw an error
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  /// Return the Database user class with a given email
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    // Query the database to find the entry with the given email
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    // If the results are empty, then we could not find the user
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    }

    // Return the DatabaseUser from the singular result
    return DatabaseUser.fromRow(results.first);
  }

  /// Create a note given a database user. Here we need to validate ownership
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // Ensure that the owner exists with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    /// Create the note in the table
    const text = '';
    final noteId = await db.insert(noteTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedColumn: true});

    return DatabaseNote(
        id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
  }

  /// Delete a note from the note table given an id
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  /// Delete all notes from the notes table
  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  /// Retrieve a specific note from the table
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }

    return DatabaseNote.fromRow(notes.first);
  }

  /// Return all notes from the notes table
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }

    return notes.map(
      (e) => DatabaseNote.fromRow(e),
    );
  }

  /// Update a given note with text
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();

    // Assure that the note already exists in the database
    await getNote(id: note.id);

    // Update the database with the text and set the synced bit to 0
    final updatedCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedColumn: 0,
    });

    // If the count is 0, then something has gone wrong and we need to throw an
    // exception
    if (updatedCount == 0) {
      throw CouldNotUpdateNoteException();
    }

    // The note should be updated at this point, so we can just return it here
    return await getNote(id: note.id);
  }
}

/// Represents the 'user' table from the sqlite database
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  /// Creates a user from an entry in the database. Note that row entries are
  /// defined as maps since rows are stored in a hash table
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User: $id\tEmail: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents the 'user' table from the sqlite database
@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  /// Creates a user from an entry in the database. Note that row entries are
  /// defined as maps since rows are stored in a hash table
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = map[isSyncedColumn] == 1;

  @override
  String toString() =>
      'Note ID: $id\tUser ID: $userId\tisSynced: $isSyncedWithCloud\n\tText: $text';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}