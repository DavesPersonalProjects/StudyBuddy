import 'package:flutter/material.dart';

import '../functions/db_helper.dart';
import '../functions/local_UsrObj.dart';
import '../functions/subject_obj.dart';
import '../widgets/customwidgets.dart';


class SubjectPage extends StatefulWidget {
  final Account_User profile;
  SubjectPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<SubjectPage> createState() => _SubPage();
}

class _SubPage extends State<SubjectPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Subject> subs = [];
  List<TextEditingController> namecontrollers = [];
  List<TextEditingController> teachcontrollers = [];
  List<TextEditingController> classcontrollers = [];
  List<TextEditingController> CCcontrollers = [];

  Future<void> _saveSubject(Subject sub) async {
    await dbHelper.initializeDatabase();
    int id = await dbHelper.writeTable(sub,"subjects",widget.profile);
    sub.id = id;
  }

  Future<void> _loadSubjects() async {
    await dbHelper.initializeDatabase();
    subs = await dbHelper.getSubjects();
    for (int i = 0; i < subs.length; i++) {
      TextEditingController nameController = TextEditingController();
      TextEditingController teacherController = TextEditingController();
      TextEditingController classroomController = TextEditingController();
      TextEditingController courseCodeController = TextEditingController();
      nameController.text = subs[i].name!;
      teacherController.text = subs[i].teacher!;
      classroomController.text = subs[i].classroom!;
      courseCodeController.text = subs[i].CCode!;
      namecontrollers.add(nameController);
      teachcontrollers.add(teacherController);
      classcontrollers.add(classroomController);
      CCcontrollers.add(courseCodeController);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (int i = 0; i < namecontrollers.length; i ++) {
      namecontrollers[i].dispose();
      teachcontrollers[i].dispose();
      classcontrollers[i].dispose();
      CCcontrollers[i].dispose();
    }
    super.dispose();
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
        title: const Text("Subject Manager"),
      ),
      drawer: NavBar(profile:widget.profile),
      body:
      ListView.builder(
        itemCount: subs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration (
              border: Border.all(color: Colors.black)
            ),
            child: Column(
              children: [
                Center(
                  child: Text("Subject ${index + 1}", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                ),
                buildTextField("Name", namecontrollers[index]),
                const SizedBox(height: 16.0),
                buildTextField("Teacher", teachcontrollers[index]),
                const SizedBox(height: 16.0),
                buildTextField("Classroom", classcontrollers[index]),
                const SizedBox(height: 16.0),
                buildTextField("Course Code", CCcontrollers[index]),
                Center (
                  child:
                Row(
                  children: [
                    CustomButton(
                      width: 100,
                      onPress: "onPress",
                      text: "Save",
                      onCustomButtonPressed: () {
                        setState(() {
                          subs[index].name = namecontrollers[index].text;
                          subs[index].teacher = teachcontrollers[index].text;
                          subs[index].classroom = classcontrollers[index].text;
                          subs[index].CCode = CCcontrollers[index].text;
                        });
                        _saveSubject(subs[index]);
                      },
                    ),
                    CustomButton(
                      width: 100,
                      onPress: "onPress",
                      text: "Delete",
                      onCustomButtonPressed: () {
                        final name = namecontrollers[index];
                        final teach = teachcontrollers[index];
                        final classroom = classcontrollers[index];
                        final code = CCcontrollers[index];
                        dbHelper.deleteByID(subs[index].id!, "subjects",widget.profile);
                        setState(() {
                          subs.removeAt(index);
                          namecontrollers.removeAt(index);
                          teachcontrollers.removeAt(index);
                          classcontrollers.removeAt(index);
                          CCcontrollers.removeAt(index);
                        });
                        name.dispose();
                        teach.dispose();
                        classroom.dispose();
                        code.dispose();
                      },
                    ),
                  ],
                ))
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addsubject();
        },
        tooltip: 'Add Blank Subject',
        child: const Icon(Icons.add),
      )
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _addsubject() {
    TextEditingController nameController = TextEditingController();
    TextEditingController teacherController = TextEditingController();
    TextEditingController classroomController = TextEditingController();
    TextEditingController courseCodeController = TextEditingController();

    setState(() {
      namecontrollers.add(nameController);
      teachcontrollers.add(teacherController);
      classcontrollers.add(classroomController);
      CCcontrollers.add(courseCodeController);
      subs.add(Subject());
    });

  }
}