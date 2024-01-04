import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';
import 'package:studybuddy/pages/login.dart';

import '../widgets/customwidgets.dart';

class Profile extends StatefulWidget {
  final Account_User profile;
  Profile({Key? key, required this.profile}) : super(key: key);

  @override
  State<Profile> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Profile> {
  File? photo;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("Users");

  TextEditingController APIController = TextEditingController();

  @override
  void dispose() {
    APIController.dispose();
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
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Profile"),
        ),
        drawer: NavBar(profile:widget.profile),
        body: (widget.profile.Online) ? Center(
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Displaying the profile picture
                CircleAvatar(
                  radius: 45,
                  backgroundImage:
                  widget.profile.PFP == null || widget.profile.PFP!.isEmpty
                      ? const AssetImage("assets/images/BLANK.jpg")
                      : CachedNetworkImageProvider(widget.profile.PFP!)
                  as ImageProvider,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            // Setting the profile picture as the user wishes
                            title: const Text("Profile Picker"),
                            actions: [
                              TextButton(
                                child: const Text("Upload From Gallery"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  imgGallery(ImageSource.gallery);
                                },
                              ),
                              TextButton(
                                child: const Text("Upload from Camera"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  imgGallery(ImageSource.camera);
                                },
                              )
                            ],
                          );
                        });
                  },
                  icon: (widget.profile.PFP == null || widget.profile.PFP!.isEmpty)
                    ? const Icon(Icons.add_a_photo)
                    : const Icon(null),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(widget.profile.Username),
                    CustomButton(
                      width: 200,
                      onPress: 'Placeholder',
                      text: 'Change Password',
                      onCustomButtonPressed: change_password
                    ),
                    CustomButton(
                      width: 200,
                      onPress: 'Placeholder',
                      text: "Set Canvas API",
                      onCustomButtonPressed: () {
                        // Display an AlertDialog when the button is pressed
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.fromLTRB(23.0,25.0 ,6.0 , 0.0),
                              title: const Text("Canvas API"),
                              content: const Text ("Canvas API Key:"),
                              actions: [
                                // TextFormField for entering the API Key
                                TextFormField(
                                  controller: APIController,
                                  decoration: const InputDecoration(hintText: "API Key"),
                                ),
                                // CustomButton inside the AlertDialog
                                CustomButton(
                                  width: 100,
                                  onPress: "onPress",
                                  text: "Set",
                                  onCustomButtonPressed: () async {
                                    await widget.profile.getCanvasID();
                                    //await set_API();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                      },
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 100),
            CustomButton(
              width: 200,
              onPress: 'Placeholder',
              text: 'Log Out',
              onCustomButtonPressed: signout,
            )
          ]),
        ) : Center(
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    CustomButton(
                      width: 200,
                      onPress: 'Placeholder',
                      text: "Set Canvas API",
                      onCustomButtonPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.fromLTRB(23.0,25.0 ,6.0 , 0.0),
                              title: const Text("Canvas API"),
                              content: const Text ("Canvas API Key:"),
                              actions: [
                                TextFormField(
                                  controller: APIController,
                                  decoration: const InputDecoration(hintText: "API Key"),
                                ),
                                CustomButton(
                                  width: 100,
                                  onPress: "onPress",
                                  text: "Set",
                                  onCustomButtonPressed: () async {
                                    await widget.profile.getCanvasID();
                                    //await set_API();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                      },
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 100),
            CustomButton(
              width: 200,
              onPress: 'Placeholder',
              text: 'Log in',
              onCustomButtonPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)
                => Login(profile: widget.profile,)));
              },
            ),
          ]),
        )
      )
    );
  }

  // Setting a profile picture
  Future imgGallery(ImageSource option) async {
    final pickedFile = await _picker.pickImage(source: option);
    setState(() {
      if (pickedFile != null) {
        photo = File(pickedFile.path);
        uploadFile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected.'),
          ),
        );
      }
    });
  }

  // Uploading a file
  Future uploadFile() async {
    if (photo == null) return;

    var imageStorage = _storage.ref().child("Users/${widget.profile.uid}/profile.jpg");
    final uploadtask = imageStorage.putFile(photo!);

    uploadtask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          break;
        case TaskState.paused:
          break;
        case TaskState.canceled:
          break;
        case TaskState.error:
          break;
        case TaskState.success:
          final pickedImage = await imageStorage.getDownloadURL();
          setState(() {
            widget.profile.PFP = pickedImage.toString();
          });
          break;
      }
    });
  }

  // Error Handler with a variety of inputs
  void Error_Handler(dynamic e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(
          "User Not Found"),));
      Navigator.pop(context);
    } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(
          "Invalid Login Credentials"),));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(
          "$e"),));
      Navigator.pop(context);
    }
  }

  // Changing the password
  Future<void> change_password() async {
    final _auth = FirebaseAuth.instance.currentUser;
    final _formKey = GlobalKey<FormState>();
    TextEditingController oldpass = TextEditingController();
    TextEditingController newpass = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Password'),
          content: Form (
            key: _formKey,
            child: Column (
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldpass,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Enter your Old Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Old Password";
                    }
                    return null;
                  }
                ),

                TextFormField(
                  controller: newpass,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Enter your New Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter New Password";
                    }
                    return null;
                  }
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                try { await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _auth!.email!,
                      password: oldpass.text
                  ).then((result) async {
                    _auth.updatePassword(newpass.text).then((_){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar
                        (content: Text("Password Updated"),));
                      Navigator.pop(context);
                    }).catchError((error){
                      Error_Handler(error);
                    });
                  });
                } on FirebaseAuthException catch (e) {
                  Error_Handler(e);
                }
              }},
              child: const Text("Submit")
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")
            ),
          ],
        );
      },
    );
    oldpass.dispose();
    newpass.dispose();
  }

  Future<void> set_API() async {

    widget.profile.CAPI = APIController.text;

    await dbRef.child(widget.profile.uid).update({
      "CAPI": widget.profile.CAPI,
    });

    await widget.profile.UpdateCourses();
  }

  void signout() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut().then((res) {
      widget.profile.Online = false;
      Navigator.pop(context);
    });
  }
}
