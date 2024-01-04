import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';
import 'package:studybuddy/widgets/calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../widgets/customwidgets.dart';
import 'package:studybuddy/notifications.dart';
import 'package:intl/intl.dart';
import '../functions/db_helper.dart';


class Calendar extends StatelessWidget {
  final Account_User profile;

  Calendar({super.key, required this.profile});
  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: MyHomePage(),
      home: MyCalendar(profile: profile),
    );
  }
}

class MyCalendar extends StatefulWidget {
  final Account_User profile;
  MyCalendar({Key? key, required this.profile}) : super(key: key);

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  final CalendarController calendarController = CalendarController();
  final TextEditingController subjectController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();
  static List<Appointment> meetings = <Appointment>[];
  CalendarData calendar = CalendarData(meetings);
  final _formKey = GlobalKey<FormState>();
  final snackBar = SnackBar(
    content: Text('Successfully added event'),
    duration: Duration(seconds: 3),
  );
  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    await dbHelper.initializeDatabase();
    meetings = await dbHelper.getMeetings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text("Calendar"),
            ),
            drawer: NavBar(
              profile: widget.profile,
            ),
            body: Center(
              child: Column(children: <Widget>[
                buildCalendar(context),
                SizedBox(height: 16),
                Row(children: [
                  SizedBox(width: 16),
                  FloatingActionButton(
                      heroTag: "add",
                      child: Icon(Icons.add),
                      onPressed: () {
                        calendar.selectedDate == null
                            ? false
                            : showDialog(
                                context: context,
                                builder: (dialogContext) => Form(
                                    key: _formKey,
                                    child: AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Add Event"),
                                              IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  Navigator.of(dialogContext).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                          TimeText(
                                            date: calendar.selectedDate!,
                                            time: calendar.eventStartTime!,
                                            calendar: calendar,
                                            startTime: true,
                                          ),
                                          TimeText(
                                            date: calendar.selectedDate!,
                                            time: calendar.eventEndTime!,
                                            calendar: calendar,
                                            startTime: false,
                                          ),
                                          //Validation for Entering your details before adding
                                          Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: TextFormField(
                                                  controller: subjectController,
                                                  decoration: const InputDecoration(labelText: "Subject"),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return "Enter A Subject";
                                                    } else if (calendar.selectedDate!.isBefore(DateTime.now())) {
                                                      return "Date is in the past!";
                                                    } else if ((calendar.eventStartTime!.hour +
                                                            (calendar.eventStartTime!.minute / 60).floor()) >
                                                        (calendar.eventEndTime!.hour +
                                                            (calendar.eventEndTime!.minute / 60).floor())) {
                                                      return "End time is behind start time!";
                                                    }
                                                  })),
                                          ElevatedButton(
                                            onPressed: () async {
                                              int id;
                                              if (_formKey.currentState!.validate()) {
                                                //Adding an appointment to the database
                                                id = await dbHelper.writeTable(
                                                    calendar.createAppointment(
                                                      calendar.eventStartTime!,
                                                      calendar.eventEndTime!,
                                                      subjectController.text,
                                                    ),
                                                    "meetings",
                                                    widget.profile);
                                                _loadMeetings();
                                                //Schedule a notification 1 day later
                                                NotificationService().scheduledNotification(
                                                    id,
                                                    'Reminder',
                                                    'You have ${subjectController.text} tomorrow',
                                                    DateTime(
                                                        calendar.selectedDate!.year,
                                                        calendar.selectedDate!.month,
                                                        calendar.selectedDate!.day,
                                                        calendar.eventStartTime!.hour,
                                                        calendar.eventStartTime!.minute));

                                                setState(() {});
                                                Navigator.pop(dialogContext, true);

                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              }
                                            },
                                            child: const Text("Save"),
                                          )
                                        ],
                                      ),
                                    )));
                      }),
                  SizedBox(width: 16),
                ])
              ]),
              // This trailing comma makes auto-formatting nicer for build methods.
            )));
  }

  //This method is for building the visible calendar and its functionality
  Widget buildCalendar(BuildContext context) {
    return SfCalendar(
      controller: calendarController,
      view: CalendarView.month,
      dataSource: CalendarData(meetings),
      onTap: (CalendarTapDetails details) {
        calendar.selectDate(details);
      },
      //On long press, open up a list of our events
      onLongPress: ((CalendarLongPressDetails details) {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                title: Container(
                    child: Row(children: [
                  Text(details.date.toString().substring(0, 10)),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ])),
                content: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                      itemCount: details.appointments?.length,
                      itemBuilder: (context, index) => ListTile(
                            title: Text(details.appointments?[index].subject),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              //This button deletes a meeting from database
                              onPressed: () async {
                                await dbHelper.deleteByID(details.appointments![index].id, "meetings", widget.profile);
                                await NotificationService().cancelNotification(details.appointments![index].id);
                                _loadMeetings();
                                Navigator.pop(context, true);
                              },
                            ),
                            subtitle: Text("Start time " +
                                details.appointments![index].startTime.toString().substring(10, 19) +
                                "\n" +
                                "End time " +
                                details.appointments![index].endTime.toString().substring(10, 19)),
                          )),
                ),
              );
            });
      }),
      monthCellBuilder: (BuildContext context, MonthCellDetails details) {
        final bool isToday = DateTime.now().day == details.date.day &&
            DateTime.now().month == details.date.month &&
            DateTime.now().year == details.date.year;
        return Container(
          margin: EdgeInsets.all(4.0), // Add margins to create "grid lines"
          decoration: BoxDecoration(
            color: isToday ? Colors.purple.shade100 : Colors.white, // Highlight current day with orange color
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: Text(
              details.date.day.toString(),
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}

//This widget allows you to choose the time manually
class TimeText extends StatefulWidget {
  DateTime date;
  TimeOfDay time;
  CalendarData calendar;
  bool startTime;

  TimeText({required this.date, required this.time, required this.calendar, required this.startTime});
  @override
  State<StatefulWidget> createState() => TimeTextState();
}
//Creating a state for this widget
class TimeTextState extends State<TimeText> {
  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd-MM-yyyy').format(widget.date);
    String time = "${widget.time.hour}:${widget.time.minute}";

    return Row(children: [
      Text("$date $time"),
      SizedBox(width: 16),
      ElevatedButton(
          onPressed: () async {
            TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: 12, minute: 00),
                initialEntryMode: TimePickerEntryMode.dial);
            if (timeOfDay != null) {
              setState(() {
                widget.time = timeOfDay;
                if (widget.startTime) {
                  widget.calendar.eventStartTime = timeOfDay;
                } else {
                  widget.calendar.eventEndTime = timeOfDay;
                }
              });
            }
          },
          child: widget.startTime ? const Text("Start") : const Text("End"))
    ]);
  }
}
