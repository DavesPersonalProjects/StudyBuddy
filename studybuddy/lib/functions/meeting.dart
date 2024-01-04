class Meeting {
  int? id;
  int? startTimeYear = 0,
      startTimeMonth = 0,
      startTimeDay = 0,
      startTimeHour = 0,
      startTimeMinute = 0;
  int? endTimeYear = 0,
      endTimeMonth = 0,
      endTimeDay = 0,
      endTimeHour = 0,
      endTimeMinute = 0;
  String? subject = "";
  Meeting({
    this.id,
    required this.startTimeYear,
    required this.startTimeMonth,
    required this.startTimeDay,
    required this.startTimeHour,
    required this.startTimeMinute,
    required this.endTimeYear,
    required this.endTimeMonth,
    required this.endTimeDay,
    required this.endTimeHour,
    required this.endTimeMinute,
    required this.subject,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTimeYear': startTimeYear,
      'startTimeMonth': startTimeMonth,
      'startTimeDay': startTimeDay,
      'startTimeHour': startTimeHour,
      'startTimeMinute': startTimeMinute,
      'endTimeYear': endTimeYear,
      'endTimeMonth': endTimeMonth,
      'endTimeDay': endTimeDay,
      'endTimeHour': endTimeHour,
      'endTimeMinute': endTimeMinute,
      'subject': subject,
    };
  }

  Meeting.fromMap(Map map) {
    id = map['id'];
    startTimeYear = map['startTimeYear'];
    startTimeMonth = map['startTimeMonth'];
    startTimeDay = map['startTimeDay'];
    startTimeHour = map['startTimeHour'];
    startTimeMinute = map['startTimeMinute'];
    endTimeYear = map['endTimeYear'];
    endTimeMonth = map['endTimeMonth'];
    endTimeDay = map['endTimeDay'];
    endTimeHour = map['endTimeHour'];
    endTimeMinute = map['endTimeMinute'];
    subject = map['subject'];
  }
}
