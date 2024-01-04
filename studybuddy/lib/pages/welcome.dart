import 'package:flutter/material.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';

import '../functions/db_helper.dart';
import '../widgets/customwidgets.dart';
import 'homepage.dart';
import 'login.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => WelcomePage();
}

class WelcomePage extends State<MyHomePage> {
  late Account_User user;

  @override
  void initState() {
    CheckDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to StuddyBuddy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              width: 200,
              onPress: 'Placeholder',
              text: "Login/Sign-Up",
              onCustomButtonPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login(profile: user)));
              }
            ),
            const SizedBox(height: 10),
            CustomButton(
              width: 200,
              onPress: 'Placeholder',
              text: "Welcome",
              onCustomButtonPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => HomePage(profile: user)));
              }
            ),
          ],
        ),
      ),
    );
  }

  // Function to Check if user has a Database Entry
  Future<void> CheckDB() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.initializeDatabase();
    Account_User user_p = await dbHelper.readUser();
    user = user_p;
    if (user.CAPI != "") {
      //user.UpdateCourses(); // To be Implemented in later revisions
    }
  }
}