import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''CREATE TABLE user_badge(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        badge TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      ''');
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'user_badge.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item
  static Future<int> createItem(String? badge) async {
    final db = await DatabaseHelper.db();

    final data = {'badge': badge};
    final id = await db.insert('user_badge', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query('user_badge', orderBy: "id");
  }

  // Get a single item by id
  //We dont use this method, it is for you if you want it.
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('user_badge', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(int id, String badge) async {
    final db = await DatabaseHelper.db();

    final data = {'badge': badge, 'createdAt': DateTime.now().toString()};

    final result =
        await db.update('user_badge', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("user_badge", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an user_badge: $err");
    }
  }
}
