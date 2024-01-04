import 'dart:convert';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studybuddy/functions/subject_obj.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'local_UsrObj.dart';
import 'meeting.dart' as meeting;
import 'task.dart' as tsk;

class DatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), 'app5.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isDone INTEGER,
            due TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Username TEXT,
            PFP TEXT,
            uid TEXT,
            CAPI TEXT,
            Cint TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE subjects(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            teacher TEXT,
            classroom TEXT,
            CCode TEXT,
            StudyDay TEXT
          )
          ''');

        await db.execute('''
          CREATE TABLE meetings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            startTimeYear INTEGER,
            startTimeMonth INTEGER,
            startTimeDay INTEGER,
            startTimeHour INTEGER,
            startTimeMinute INTEGER,
            endTimeYear INTEGER,
            endTimeMonth INTEGER,
            endTimeDay INTEGER,
            endTimeHour INTEGER,
            endTimeMinute INTEGER,
            subject TEXT
          )
          ''');
      },
    );
  }

  // Data Sync Function
  Future<void> FBinitSync(Account_User user) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Users/${user.uid}");

    // Obtains All Data from Firebase and Local DB
    List<tsk.Task> tasks = await getTasks();
    final List<Map<String, dynamic>> maps = await _database.query('meetings');
    List<meeting.Meeting> meetings = [];
    List<Subject> subjects = await  getSubjects();
    final FBTasks = await ref.child("tasks").get();
    final FBSubs = await ref.child("subjects").get();
    final FBMeetings = await ref.child("meetings").get();
    final List<tsk.Task> FBTasksList = [];
    final List<Subject> FBSubsList = [];
    final List<meeting.Meeting> FBMeetingsList = [];

    // Generates objects from lists of data from Firebase
    for (var snap in FBSubs.children) {
      var data = jsonEncode(snap.value);
      Map mappedData = jsonDecode(data);

      FBSubsList.add(Subject.fromMap(mappedData));
    }
    for (var snap in FBTasks.children) {
      var data = jsonEncode(snap.value);
      Map mappedData = jsonDecode(data);
      FBTasksList.add(tsk.Task.fromMap(mappedData));
    }
    for (var snap in FBMeetings.children) {
      var data = jsonEncode(snap.value);
      Map mappedData = jsonDecode(data);

      FBMeetingsList.add(meeting.Meeting.fromMap(mappedData));
    }

    // Generate Meeting Object from Database Objects
    for (var map in maps) {
      meetings.add(meeting.Meeting.fromMap(map));
    }

    // Combine both sets of Data
    tasks = tasks + FBTasksList;
    meetings = meetings + FBMeetingsList;
    subjects = subjects + FBSubsList;

    // Use Set to determine unique data and keep it
    final ids = Set();
    tasks.retainWhere((x) => ids.add(x.id));
    final ids_1 = Set();
    meetings.retainWhere((x) => ids_1.add(x.id));
    final ids_2 = Set();
    subjects.retainWhere((x) => ids_2.add(x.id));

    int max_len = max(subjects.length,max(tasks.length,meetings.length));
    // Loop through the longest list and Write all to Local DB and Firebase
    for (int i = 0; i < max_len; i++) {
      if (i < tasks.length) {
        writeTable(tasks[i],"tasks",user);
      }
      if (i < meetings.length) {
        writeTable(meetings[i],"meetings",user);
      }
      if (i < subjects.length) {
        writeTable(subjects[i],"subjects",user);
      }
    }


  }

  // Writes Data to Firebase
  Future<void> writeTableFB(dynamic object, String table, Account_User user) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Users/${user.uid}");

    final snap = await ref.get();
    if (!snap.exists) {
      // If user does not exist start by uploading that
      ref.set(user.toMap());

      // Get Objects to Upload to Firebase
      final List<tsk.Task> tasks = await getTasks();
      final List<Map<String, dynamic>> maps = await _database.query('meetings');
      final List<Subject> subjects = await  getSubjects();

      // Loop Through all the Objects and write them
      for (tsk.Task task in tasks) {
        ref.child("tasks/${task.id}").set(task.toMap());
      }

      for (Subject subject in subjects) {
        ref.child("subjects/${subject.id}").set(subject.toMap());
      }

      for (var meetingss in maps) {
        var current = meeting.Meeting.fromMap(meetingss);
        ref.child("subjects/${current.id}").set(current.toMap());
      }

    } else {
      // If user does exist write simply what they want
      ref.child("$table/${object.id}").set(object.toMap());
    }
  }

  // Update Firebase
  Future<void> updateTableFB(dynamic object, String table, Account_User user) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Users/${user.uid}");

    final snap = await ref.get();
    if (!snap.exists) {
      // Check if user exists if not reuse write table to write the data
      writeTableFB(object, table, user);
    } else {
      ref.child("$table/${object.id}").update(object.toMap());
    }
  }

  // Delete Record from Firebase
  Future<void> deleteTableFB(int id, String table, Account_User user) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Users/${user.uid}");

    final snap = await ref.get();
    if (snap.exists) {
      ref.child("$table/${id}").remove();
    }
  }

  // Write Data to Local SQL Database
  Future<int> writeTable(dynamic object, String table, Account_User user) async {
    await initializeDatabase();
    if (user.Online) { // If User is online also write it Firebase to keep in Sync
      writeTableFB(object, table,user);
    }
    return await _database.insert(table, object.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update Local SQL Database
  Future<int> updateTable(dynamic object, String table, Account_User user) async {
    await initializeDatabase();
    if (user.Online) {
      // If User Online also update the the Firebase
      updateTableFB(object, table,user);
    }
    return await _database.update(
      table,
      object.toMap(),
      where: 'id = ?',
      whereArgs: [object.id],
    );
  }

  // Delte Record from local SQL Database
  Future<int> deleteByID(int id, String table, Account_User user) async {
    await initializeDatabase();
    if (user.Online) {
      // If Online also delete from Firebase
      deleteTableFB(id, table,user);
    }
    return await _database.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Helper function that helps updates userid when they login to the unique ID generated by Firebase
  Future<int> updateUserbyID(Account_User user, String uid) async {
    await initializeDatabase();
    return await _database.update(
      'profile',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Helper Function to Read Inital User Data
  Future<Account_User> readUser() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('profile');
    // Generate a Blank User Account
    Account_User user = await Account_User.create();
    // If the query returns empty write blank user to Database
    if (maps.isEmpty) {
      writeTable(user, "profile", user);
    } else {
      // If They Exist Update the User Object with relevant info
      // Should have been done with a toMap Function, for Later Builds
      var data = maps[0];
      if (data['uid'] != null) {
        user.uid = data['uid'];
      }
      if (data['PFP'] != null) {
        user.PFP = data['PFP'];
      }
      if (data['CAPI'] != null) {
        user.CAPI = data['CAPI'];
      }
      if (data['CInt'] != null) {
        user.Cint = data['CInt'];
      }
      if (data['Username'] != null) {
        user.Username = data['Username'];
      }
    }
    return user;
  }

  // Get Task Objects from the Database
  Future<List<tsk.Task>> getTasks() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('tasks');
    List<tsk.Task> results = [];
    for (int i = 0; i < maps.length; i++) {
      results.add(tsk.Task.fromMap(maps[i]));
    }
    return results;
  }

  // Get Appointment Objects from the Database
  Future<List<Appointment>> getMeetings() async {
    await initializeDatabase();
    meeting.Meeting current;
    final List<Map<String, dynamic>> maps = await _database.query('meetings');
    List<Appointment> results = [];
    for (int i = 0; i < maps.length; i++) {
      current = meeting.Meeting.fromMap(maps[i]);
      results.add(Appointment(
          id: current.id,
          startTime: DateTime(
              current.startTimeYear!,
              current.startTimeMonth!,
              current.startTimeDay!,
              current.startTimeHour!,
              current.startTimeMinute!),
          endTime: DateTime(
              current.endTimeYear!,
              current.endTimeMonth!,
              current.endTimeDay!,
              current.endTimeHour!,
              current.endTimeMinute!),
          subject: current.subject!));
    }
    return results;
  }

  // Get Subject Objects from the Database
  Future<List<Subject>> getSubjects() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('subjects');
    List<Subject> results = [];
    for (int i = 0; i < maps.length; i++) {
      results.add(Subject.fromMap(maps[i]));
    }
    return results;
  }
}
