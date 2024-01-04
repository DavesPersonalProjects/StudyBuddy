import 'package:flutter/material.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';
import 'package:studybuddy/pages/calendarpage.dart';
import 'package:studybuddy/pages/homepage.dart';
import 'package:studybuddy/pages/login.dart';
import 'package:studybuddy/pages/profile.dart';
import 'package:studybuddy/pages/subject_manager.dart';
import 'package:studybuddy/pages/taskpage.dart';

import '../pages/study_schedule.dart';
import '../pages/support.dart';

class CustomButton extends StatelessWidget {
  final double width;
  final String onPress;
  final String text;
  VoidCallback? onCustomButtonPressed = () {};

  CustomButton(
      {super.key, required this.width,
      required this.onPress,
      required this.text,
      this.onCustomButtonPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: (onCustomButtonPressed != null)
                  ? onCustomButtonPressed
                  : () {},
              child: Text(text),
            )));
  }
}


void _showAbout(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: "Study Buddy",
    applicationVersion: "1.0.0",
    // Other properties for the about dialog...
  );
}

class NavBar extends StatelessWidget {
  final Account_User profile;
  const NavBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildNavMenuItems(context),
      ],
    ));
  }

  Widget buildNavMenuItems(BuildContext context) {
    return Column(
          children: [
    Container(
        height: 75,
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(color: Colors.deepPurple.shade100),
        child: const Center(heightFactor: 0.1,child: Text('Studdy Buddy', style: TextStyle(fontSize: 20),))),
    ListTile(
      title: const Text("Home"),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage(profile: profile)));
      },
    ),
    ListTile(
      title: const Text('Calendar'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Calendar(profile: profile)));
      },
    ),
    ListTile(
      title: const Text('Task'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              TaskPage(profile: profile)),
        );
      }
    ),
    ListTile(
      title: const Text("Subject Manager"),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SubjectPage(profile: profile)));
      },
    ),
    ListTile(
      title: const Text("Study Schedule"),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WeekdaysPage(profile: profile)));
      },
    ),
    ListTile(
      title: const Text('Profile'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile(profile: profile)));
      },
    ),
    ListTile(
      title: const Text('Login and Registration'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login(profile: profile)));
      },
    ),
    ListTile(
      title: const Text('Support and Feedback'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Support(profile: profile)));
      },
    ),
    ListTile(
        title: const Text('About'),
        onTap: () {
          _showAbout(context);
        }
    ),
          ],
        );
  }
}
