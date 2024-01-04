import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/pages/login.dart';

import '../functions/local_UsrObj.dart';

class Registration extends StatefulWidget {
  final Account_User profile;
  const Registration({super.key, required this.profile});
  @override
  State<Registration> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("Users");
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController CpasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login(profile: widget.profile)));},
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text("Registration"),
              ),
    body: Center(
      child: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Padding(
            // Asking for various user inputs
            padding: const EdgeInsets.all(10),
            child: TextFormField(
            controller: nameController,
            decoration:
            const InputDecoration(labelText: "Username"),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter a Username";
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter a Email";
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter a Password";
                }
                return null;
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              obscureText: true,
              controller: CpasswordController,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              validator: (value) {
                //checking if the password is valid
                if (value!.isEmpty) {
                  return "Please Confirm your Password";
                }
                else if (value != passwordController.text) {
                  return "Your Passwords do not match, try again";
                }
                return null;
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  putitinthebase();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Registration Succesfful"),
                        content: const Text ("Click OK to return to the Login page"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context)
                                  => Login(profile: widget.profile,)),
                                );
                              },
                            child: const Text('OK'),
                        ),
                      ],
                    );
                  },);
                }},
            )
          )
        ]
        ),
      )
      )
    );
  }

  void putitinthebase() {
    firebaseAuth
      .createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text)
        .then((result) {
      dbRef.child(result.user!.uid).set({
        "email": emailController.text,
        "name": nameController.text
      }).then((res) {
      });
    }).catchError((err) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(err.message),
            actions: [
              TextButton(
                child: const Text("Dismiss"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    passwordController.dispose();
    CpasswordController.dispose();
    emailController.dispose();
  }
}
