import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../functions/db_helper.dart';
import '../functions/local_UsrObj.dart';
import '../functions/subject_obj.dart';
import '../functions/task.dart';
import '../notifications.dart';
import '../widgets/calendar.dart';
import '../widgets/customwidgets.dart';

class HomePage extends StatefulWidget {
  final Account_User profile;
  HomePage({Key? key, required this.profile}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final CalendarController calendarController = CalendarController();
  static List<Appointment> meetings = <Appointment>[];
  CalendarData calendar = CalendarData(meetings);
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Task> tasks = [];
  List<Subject> subs = [];

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadSubjects();
    _loadMeetings();
  }

  Future<void> _loadTasks() async {
    await dbHelper.initializeDatabase();
    tasks = await dbHelper.getTasks();
    setState(() {});
  }

  Future<void> _loadSubjects() async {
    await dbHelper.initializeDatabase();
    subs = await dbHelper.getSubjects();
    setState(() {});
  }

  Future<void> _loadMeetings() async {
    await dbHelper.initializeDatabase();
    meetings = await dbHelper.getMeetings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
      ),
      drawer: NavBar(profile:widget.profile),
      body: Column (
        children: [
          SfCalendar(
            controller: calendarController,
            view: CalendarView.month,
            dataSource: CalendarData(meetings),
            onTap: (CalendarTapDetails details) {
              calendar.selectDate(details);
            },
          onLongPress: ((CalendarLongPressDetails details) {
            showDialog(
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: Row(children: [
                      Text(details.date.toString().substring(0, 10)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop();
                          })
                    ]),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                          itemCount: details.appointments?.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(details
                                .appointments?[index].subject),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await dbHelper.deleteByID(
                                    details.appointments![index].id,
                                    "meetings",widget.profile);
                                await NotificationService()
                                    .cancelNotification(details
                                    .appointments![index].id);

                                _loadMeetings();
                                Navigator.pop(context, true);
                              },
                            ),
                            subtitle: Text("Start time ${details
                                    .appointments![index].startTime
                                    .toString()
                                    .substring(10, 19)}\nEnd time ${details.appointments![index].endTime
                                    .toString()
                                    .substring(10, 19)}"),
                          )),
                    ),
                  );
                });
          }),
            // Building the calendar
            monthCellBuilder: (BuildContext context, MonthCellDetails details) {
              final bool isToday = DateTime.now().day == details.date.day &&
                  DateTime.now().month == details.date.month &&
                  DateTime.now().year == details.date.year;
              return Container(
                margin: const EdgeInsets.all(4.0), // Add margins
                decoration: BoxDecoration(
                  color: isToday ? Colors.purple.shade100 : Colors.white, // Highlight current day
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    details.date.day.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                // Widget of tasks
                child: ListView.builder(shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tasks[index].title!),
                      leading: Checkbox(
                        value: tasks[index].isDone,
                        onChanged: (bool? value) async {
                          tasks[index].isDone = value!;
                          await dbHelper.updateTable(tasks[index],"tasks", widget.profile);
                          setState(() {});
                        },
                      ),
                    );
                  },
                )
              ),
              Expanded(
                // Widget of subjects
                  child: ListView.builder(shrinkWrap: true,
                    itemCount: subs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(subs[index].name!),
                        leading:CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(subs[index].StudyDay!.substring(0,3)),
                        )
                      );
                    },
                  )
              )
            ],
          )
        ],
      ),
    );
  }
}