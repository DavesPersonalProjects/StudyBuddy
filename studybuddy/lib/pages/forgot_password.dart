import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/widgets/customwidgets.dart';

class ForgotPassword extends StatefulWidget {

  const ForgotPassword({super.key});
  @override
  State<ForgotPassword> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //User? result = FirebaseAuth.instance.currentUser;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Forgot my Password"),
          ),
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  // Validating the email
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
              // Resetting the password
              CustomButton(
                width: 300,
                onPress: "onPress",
                text: "Reset Password",
                onCustomButtonPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final _auth = FirebaseAuth.instance;
                    await _auth
                      .sendPasswordResetEmail(email: emailController.text)
                      .then((value) => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text(
                        "Password Reset Email Sent, Check Junk Mail"),)))
                      .catchError((e) => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text(
                        "Error Occurred, Please Try again later"),)));
                  }}
              ),
            ]
            ),
          )
        )
      )
    );
  }
}

