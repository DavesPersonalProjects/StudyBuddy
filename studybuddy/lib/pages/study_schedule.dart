import 'package:flutter/material.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';

import '../functions/db_helper.dart';
import '../functions/subject_obj.dart';
import '../widgets/customwidgets.dart';

class WeekdaysPage extends StatefulWidget {
  final Account_User profile;
  WeekdaysPage({Key? key, required this.profile}) : super(key: key);

  @override
  _WeekdaysPageState createState() => _WeekdaysPageState();
}

class _WeekdaysPageState extends State<WeekdaysPage> {
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Subject> subs = [];


  Future<void> _loadSubjects() async {
    await dbHelper.initializeDatabase();
    subs = await dbHelper.getSubjects();
    setState(() {});
  }

  Future<void> TimeDatePicker(int index) async {
    String selectedDay = subs[index].StudyDay!;
    TimeOfDay? start;
    TimeOfDay? end;
    final results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
          return AlertDialog(
            title: Text('Set Schedule for ${subs[index].name!}'),
            content: Column (
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selecting the day and the item
                DropdownButton<String>(
                  value: selectedDay,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDay = newValue!;
                    });
                  },
                  items: daysOfWeek.map((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    // Starting and End time of study session
                    ElevatedButton(onPressed: () async {
                      final selectedTime = await showTimePicker(
                        initialTime: (subs[index].StudyStart != null) ?
                        subs[index].StudyStart! : TimeOfDay.now(),
                        context: context,
                      );
                      setState(() {
                        start = selectedTime;
                      });
                    },
                        child: const Text("Start Time")),
                    ElevatedButton(onPressed: () async {
                      final selectedTime = await showTimePicker(
                        initialTime: (subs[index].StudyEnd != null) ? subs[index].StudyEnd! : TimeOfDay.now(),
                        context: context,
                      );
                      setState(() {
                        end = selectedTime;
                      });
                    },
                        child: const Text("End Time"))
                  ],
                )
              ],
            ),
            actions: [
              Center(
                child:ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, [start,end]);
                  },
                  child: const Text("Submit")),
              )
            ],
          );
        }

        );
      },
    );
    if (results != null) {
      setState(() {
        subs[index].StudyEnd = results[1];
        subs[index].StudyStart = results[0];
      });
    }
  }

  @override
  void initState() {
    _loadSubjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Study Schedule'),
      ),
      drawer: NavBar(profile: widget.profile),
      body: (subs.isNotEmpty ) ? ListView.builder(
        itemCount: subs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text(subs[index].name!, style: const TextStyle(fontSize: 15),),
            title: (subs[index].StudyStart != null && subs[index].StudyEnd != null) ? Text("${subs[index].StudyDay} \n ${subs[index].StudyStart?.format(context)} - ${subs[index].StudyEnd?.format(context)}") :
              Text("${subs[index].StudyDay}"),
            trailing:
              ElevatedButton(
                onPressed: () async {
                  await TimeDatePicker(index);
                  dbHelper.updateTable(subs[index],"subjects",widget.profile);
                },
                child: const Icon(Icons.edit),
              )
          );
        },
      ) : Container (
        padding: const EdgeInsets.all(16.0),
        child: const Center (
          child: Text("Add Subjects in the Subject Manager to Assign Study Time", style: TextStyle(fontSize: 35),),
        )),
    );
  }

}