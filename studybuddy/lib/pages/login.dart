import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/pages/forgot_password.dart';
import 'package:studybuddy/pages/profile.dart';
import 'package:studybuddy/pages/registration.dart';

import '../functions/db_helper.dart';
import '../functions/local_UsrObj.dart';

class Login extends StatefulWidget {
  final Account_User profile;
  const Login({super.key, required this.profile});
  @override
  State<Login> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);},
          ),
          centerTitle: true,
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: const Text("Login"),
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              // Field for entering the email
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Email Adresss";
                    } else if (!value.contains("@")) {
                      return "Enter a Valid Email";
                    }
                    return null;
                  },
                ),
              ),
              // Field for entering the password
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      controller: passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters long";
                        }
                        return null;
                      },
                      onFieldSubmitted: (val) {
                      },
                    ),

                    //Display error message in red below the password textbox
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column (
                  children: [
                    Center(
                      // Login button is pressed
                      child: ElevatedButton(
                        child: const Text('Login'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            login();
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields correctly.'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    ElevatedButton(
                      // Sign up button is pressed, redirect
                      child: const Text('Sign Up'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Registration(profile: widget.profile)),
                        );
                      },
                    ),
                    ElevatedButton(
                      // Forgot my password button is pressed, redirect
                    child: const Text('Forgot my Password'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()),
                        );
                      },
                    ),
                  ],
                )
              )
            ]
            ),
          )
        )
      )
    );
  }

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      ).then((result) async {
        DatabaseHelper dbHelper = DatabaseHelper();
        dbHelper.initializeDatabase();
        var temp_uid = widget.profile.uid;
        widget.profile.uid = result.user!.uid;
        await dbHelper.updateUserbyID(widget.profile, temp_uid);
        await widget.profile.GoOnline();
        await dbHelper.updateUserbyID(widget.profile, widget.profile.uid);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                Profile(profile: widget.profile)));
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }
}
