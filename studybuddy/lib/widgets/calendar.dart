import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../functions/Meeting.dart';

class CalendarData extends CalendarDataSource {
  CalendarData(List<Appointment> source) {
    appointments = source;
  }

  dynamic selectedAppointment = [];
  DateTime? selectedDate;
  CalendarElement? selectedElement;
  TimeOfDay? eventStartTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? eventEndTime = const TimeOfDay(hour: 12, minute: 0);

  void selectDate(CalendarTapDetails details) {
    selectedAppointment = details.appointments;
    selectedDate = details.date;
    selectedElement = details.targetElement;
  }

  Meeting createAppointment(
      TimeOfDay startTime, TimeOfDay endTime, String subject) {
    return Meeting(
        startTimeYear: selectedDate!.year,
        startTimeMonth: selectedDate!.month,
        startTimeDay: selectedDate!.day,
        startTimeHour: startTime.hour,
        startTimeMinute: startTime.minute,
        endTimeYear: selectedDate!.year,
        endTimeMonth: selectedDate!.month,
        endTimeDay: selectedDate!.day,
        endTimeHour: endTime.hour,
        endTimeMinute: endTime.minute,
        subject: subject);
  }
}
