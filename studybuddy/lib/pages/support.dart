import 'package:flutter/material.dart';
import 'package:studybuddy/functions/local_UsrObj.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/customwidgets.dart';

class Support extends StatefulWidget {
  final Account_User profile;

  Support({required this.profile});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Support> {
  int _rating = 0;
  late TextEditingController _feedbackController;
  late TextEditingController _supportController;

  @override
  void initState() {
    super.initState();
    _rating = 0;
    _feedbackController = TextEditingController();
    _supportController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  //submits to firebase
  void submitFeedback(String feedback) {
    DatabaseReference feedbackRef =
    FirebaseDatabase.instance.reference().child('feedback');

    feedbackRef.push().set({
      'userId': widget.profile.uid,
      'message': feedback,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  //submits to firebase
  void submitSupportRequest(String supportRequest) {
    DatabaseReference supportRef =
    FirebaseDatabase.instance.reference().child('support');

    supportRef.push().set({
      'userId': widget.profile.uid,
      'message': supportRequest,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  //for the feedback dialogue popup
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedback'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your feedback:',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                        ),
                      );
                    }),
                  )
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //for the support request dialogue popup
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _supportController,
                decoration: const InputDecoration(
                  hintText: 'Enter your support request:',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback and Support'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      drawer: NavBar(profile: widget.profile),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _showFeedbackDialog(context);
              },
              child: const Text('Provide Feedback'),
            ),
            ElevatedButton(
              onPressed: () {
                _showSupportDialog(context);
              },
              child: const Text('Get Support'),
            ),
          ],
        ),
      ),
    );
  }
}
