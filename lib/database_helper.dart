import 'package:mmm_sheeting_app_ios_flutter/models/feedback.dart';
import 'package:mmm_sheeting_app_ios_flutter/print_text.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MMMLocal.db";
  static const _databaseVersion = 2;

  static const feedbackTable = 'feedback_table';
  static const columnId = '_id';
  static const columnImagePath = 'image_path';
  static const columnImageName = 'image_name';
  static const columnPredictionType = 'prediction_type';
  static const columnPredictionColor = 'prediction_color';
  static const columnFeedback = 'feedback';
  static const columnCorrectAnsType= 'correct_ans_type';
  static const columnCorrectAnsColor= 'correct_ans_color';
  static const columnFlash= 'flash';
  static const columnTimeStamp='time_stamp';
  static const columnStatus = 'status'; // default 1,

  late Database _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void>  init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $feedbackTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnImagePath TEXT NOT NULL,
            $columnPredictionType TEXT ,
            $columnPredictionColor TEXT ,
            $columnImageName TEXT NOT NULL,            
            $columnFeedback TEXT NOT NULL,
            $columnCorrectAnsType TEXT NOT NULL,
            $columnCorrectAnsColor TEXT NOT NULL,
            $columnFlash TEXT NOT NULL,
            $columnTimeStamp TEXT NOT NULL,
            $columnStatus INTEGER DEFAULT 1 NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insertFeedback(Map<String, dynamic> row) async {
    return await _db.insert(feedbackTable, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(feedbackTable);
  }

    Future<List<Map<String, dynamic>>>  queryAllRowsStatus1() async {
      return await _db.query(feedbackTable,
      where: "status = 1",);
    }
//
  Future<List<Map<String, dynamic>>>  queryAllRowsStatus2() async {
    return await _db.query(feedbackTable,
      where: "status = 2",);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsStatusNot0() async {
    return await _db.query(feedbackTable,
      where: "status != 0",);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCountStatus0() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $feedbackTable where status = 0');
    return Sqflite.firstIntValue(results) ?? 0;
  }

    updateFeedbackStatusTo2(FeedbackModel feedbackToUpdate) async {
    final results = await _db.rawUpdate('Update $feedbackTable set status =2 where _id = ?',[feedbackToUpdate.id]);
    printLine(results);
  }

  updateStatusTo0(FeedbackModel feedbackToUpdate) async {
    final results = await _db.rawUpdate('Update $feedbackTable set status =0 where _id = ?',[feedbackToUpdate.id]);
    printLine("Status 0:  $results");
  }


  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      feedbackTable,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      feedbackTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}