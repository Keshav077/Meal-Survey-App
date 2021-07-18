import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  ReportScreen({Key? key, required this.school}) : super(key: key);
  final String school;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map issue = {};

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final fbDB = FirebaseDatabase.instance;

  final fbAuth = FirebaseAuth.instance;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ref = fbDB.reference();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Text("Report Issue"),
      ),
      body: ListView(
        children: [
          Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => issue['subject'] = newValue,
                      validator: (value) => value!.length > 10
                          ? null
                          : "Please provide a valid subject!",
                      decoration: InputDecoration(labelText: "Subject"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      onSaved: (newValue) => issue['issue'] = newValue,
                      maxLines: 10,
                      decoration: InputDecoration(labelText: "Issue"),
                      validator: (value) => value!.length > 50
                          ? null
                          : "Please provide a valid Issue(min 50 chars)!",
                    ),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  formKey.currentState!.save();

                  String key = fbAuth.currentUser!.uid +
                      " " +
                      DateTime.now().toString().split('.')[0];
                  try {
                    await ref
                        .child("schools/${widget.school}/issues/$key")
                        .set(issue)
                        .onError((error, stackTrace) => throw Exception());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Successfully Reported"),
                    ));
                    Navigator.of(context).pop();
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Failed to Report"),
                      backgroundColor: Colors.red,
                    ));
                  }
                  setState(() {
                    if (mounted) isLoading = false;
                  });
                }
              },
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : Text("Report"),
            ),
          ),
        ],
      ),
    );
  }
}
