import 'package:flutter/material.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';

import '../functions/db_helper.dart';
import '../functions/task.dart';
import '../widgets/customwidgets.dart';

class TaskPage extends StatefulWidget {
  final Account_User profile;

  TaskPage({Key? key, required this.profile}) : super(key: key);

  //MyHomePage({Key? key}) : super(key: key);
  @override
  State<TaskPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TaskPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    if (widget.profile.CAPI == "") {
      widget.profile.getCanvasID();
    }
  }

  Future<void> _loadTasks() async {
    await dbHelper.initializeDatabase();
    tasks = await dbHelper.getTasks();
    setState(() {});
  }

  Future<List> _showDateTimePicker()async
  {
    final result = [];
    final DateTime? datePicked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if(datePicked!=null)
    {
      result.add(datePicked);
      final TimeOfDay? timePicked = await showTimePicker(context: context,initialTime: const TimeOfDay(hour: 12,minute:0));
      if(timePicked !=null)
      {
        result.add(timePicked);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: "Import Canvas TODO Items",
            onPressed: () async {
              if (widget.profile.CAPI == "") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Set a Canvas ID in the profile page first"),));
              }
              bool exists = false;
              final new_tasks = await widget.profile.BuildTodo();
              if (new_tasks != null) {
                for (final task in new_tasks) {
                  for (final main_task in tasks) {
                    if (task.title == main_task.title){
                      exists = true;
                    }
                  }
                  if (!exists) {
                    task.id = await dbHelper.writeTable(task,"tasks",widget.profile);
                    await dbHelper.updateTable(task, "tasks", widget.profile);
                  }
                }
              }
              _loadTasks();
              setState(() {});
            },
            icon: const Icon(Icons.download_for_offline))
        ],
      ),
      drawer: NavBar(profile: widget.profile),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tasks[index].title!),
                (tasks[index].due != "") ? Text("Due on ${DateTime.parse(tasks[index].due).toLocal().day}/${DateTime.parse(tasks[index].due).toLocal().month}/${DateTime.parse(tasks[index].due).toLocal().year} at ${TimeOfDay.fromDateTime(DateTime.parse(tasks[index].due).toLocal()).format(context)}") : Container()
              ],
            ),
            leading: Checkbox(
              value: tasks[index].isDone,
              onChanged: (bool? value) async {
                tasks[index].isDone = value!;
                await dbHelper.updateTable(tasks[index], "tasks",widget.profile);
                setState(() {});
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editTask(context, index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteTask(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTask(context);
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTask(BuildContext context) {
    String? due = "";

    TextEditingController taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(hintText: 'Enter your updated task'),
              ),
              const SizedBox(height: 8.0,),
              ElevatedButton(
                  onPressed: () async {
                    final result = await _showDateTimePicker();
                    due = "${result[0].toString().split(" ")[0]} ${result[1].hour}:${result[1].toString().substring(13,15)}:00";
                  },
                  child: const Text("Update Due Date")
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (taskController.text.isNotEmpty) {
                  Task newTask = Task(title: taskController.text,due: due!);
                  newTask.id = await dbHelper.writeTable(newTask, "tasks", widget.profile);
                  await dbHelper.updateTable(newTask, "tasks", widget.profile);
                  _loadTasks();
                  taskController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editTask(BuildContext context, int index) {
    TextEditingController taskController = TextEditingController();
    taskController.text = tasks[index].title!;
    String? due = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(hintText: 'Enter your updated task'),
              ),
              const SizedBox(height: 8.0,),
              ElevatedButton(
                onPressed: () async {
                  final result = await _showDateTimePicker();
                  due = "${result[0].toString().split(" ")[0]} ${result[1].hour}:${result[1].toString().substring(13,15)}:00";
                },
                child: const Text("Update Due Date")
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (taskController.text.isNotEmpty) {
                  tasks[index].title = taskController.text;
                  if (due != "") {
                    tasks[index].due = due!;
                  }
                  await dbHelper.updateTable(tasks[index], "tasks",widget.profile);
                  _loadTasks();
                  taskController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Delete Task Helper
  void _deleteTask(int index) async {
    await dbHelper.deleteByID(tasks[index].id!, "tasks",widget.profile);
    _loadTasks();
  }
}
