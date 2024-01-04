import 'package:flutter/material.dart';

class Subject {
  int? id;
  String? name = "";
  String? teacher = "";
  String? classroom = "";
  String? CCode = "";
  String? StudyDay = "Monday";
  bool notify = false;
  TimeOfDay? StudyStart;
  TimeOfDay? StudyEnd;

  Subject({this.id, this.name, this.teacher, this.classroom, this.CCode});

  Map<String, dynamic> toMap() {
    // If the StudyEnd and StudyStart are not null format to String to later easily Parse
    if (StudyEnd != null && StudyStart != null) {
      return {
        'id': id,
        'name': name,
        'teacher': teacher,
        'classroom': classroom,
        'CCode': CCode,
        'StudyDay': "${StudyDay}_${StudyStart.toString()}_${StudyEnd.toString()}"
      };
    } else {
      return {
        'id': id,
        'name': name,
        'teacher': teacher,
        'classroom': classroom,
        'CCode': CCode,
        'StudyDay': StudyDay
      };
    }

  }

  Subject.fromMap(Map map) {
    id = map['id'];
    name = map['name'];
    teacher = map['teacher'];
    classroom = map['classroom'];
    CCode = map['CCode'];

    // Determine if the Data provided from StudyDay needs parsing or can just be passed
    final split = map['StudyDay'].split("_");
    if (split.length == 1) {
      StudyDay = map['StudyDay'];
    } else {
      StudyDay = split[0];
      StudyStart = TimeOfDay(hour: int.parse(split[1].substring(10,12)), minute: int.parse(split[1].substring(13,15)));
      StudyEnd = TimeOfDay(hour: int.parse(split[2].substring(10,12)), minute: int.parse(split[2].substring(13,15)));
    }
  }


}