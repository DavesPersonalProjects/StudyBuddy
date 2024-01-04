import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studybuddy/functions/db_helper.dart';
import 'package:studybuddy/functions/task.dart' as tsk;
import 'package:uuid/uuid.dart';

import 'Course_Obj.dart';
import 'http_func.dart';

class Account_User {
  String Username = "";
  String? PFP = "";
  String uid = "";
  String CAPI = "";
  String Cint = "";
  bool Online = false;
  List<Course> Courses = [];

  Account_User._create() {
    var uuid = Uuid();
    uid = uuid.v4();
  }

  /// Public factory
  static Future<Account_User> create() async {
    // Call the private constructor
    var component = Account_User._create();
    // Return the fully initialized object
    return component;
  }

  // Hlper Function that converts the User Object to an Online one
  Future<void> GoOnline() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Online = true;
    dbHelper.FBinitSync(this);
    await _getPFP();
    await _getDBInfo();
  }


  // Helper Function to Get Firebase Data
  Future<void> _getDBInfo () async {
    if (Online) {
      final db = await FirebaseDatabase.instance.ref().child("Users").child(uid).get();
      if (db.exists) {
        Username = db
            .child("name")
            .value as String;
        if (db
            .child("CAPI")
            .value != null) {
          CAPI = db
              .child("CAPI")
              .value as String;
        }
      } else {
        Username = "Database Error";
      }
    }
  }


  // Helper Function that gets PFP file from Firebase Cloud Bucket
  Future<void> _getPFP () async {
    if (Online) {
      final FirebaseStorage storage = FirebaseStorage.instance;
      var imageStorage = storage.ref().child("Users/$uid/profile.jpg");
      try {
        final pickedImage = await imageStorage.getDownloadURL();
        PFP = pickedImage.toString();
      } on FirebaseException catch (e) {
        PFP = "";
        print("Failed with error '${e.code}': ${e.message}");
      }
    }
  }


  // Gets Canvas User ID for UpdateCourses
  Future<void> getCanvasID() async {
    if (CAPI != "" && Cint == "") {
      var data = await getData('https://learn.ontariotechu.ca/api/v1/users/self/profile',CAPI);
      Cint = (data['id']).toString();
    }
  }

  // Builds Courses for Later Implementation
  UpdateCourses() async {
    if (CAPI != "") {
      await getCanvasID();
      final data_enrolled = await getData('https://learn.ontariotechu.ca/api/v1/users/$Cint/enrollments',CAPI);
      if (data_enrolled != null) {
        for (var data in data_enrolled) {
          if (data["grades"]["current_grade"] != null) {
            var data_enrolled = await getData('https://learn.ontariotechu.ca/api/v1/courses/${data['course_id']}',CAPI);
            Courses.add(Course(data_enrolled['name'].split(' - ')[1],data['course_id']));
          }
        }
      }
    }
  }

  // Builds the User's Todo list from Data
  BuildTodo() async {
    if (CAPI != "") {
      final data_todo = await getData('https://learn.ontariotechu.ca/api/v1/users/self/todo',CAPI);
      List <tsk.Task> results = [];
      if (data_todo.length > 0) {
        for (final data in data_todo) {
          results.add(tsk.Task(title: data['assignment']['name'],due: data['assignment']['due_at']));
        }
      }
      return results;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'Username': Username,
      'PFP': PFP,
      'uid': uid,
      'CAPI': CAPI,
      'Cint': Cint
    };
  }

  @override
  String toString() {
    return 'Account_User{Username: $Username, PFP: $PFP, uid: $uid, CAPI: $CAPI, Cint: $Cint, Online: $Online}';
  }
}