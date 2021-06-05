import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class AddSchool extends StatefulWidget {
  AddSchool({Key? key}) : super(key: key);

  @override
  _AddSchoolState createState() => _AddSchoolState();
}

class _AddSchoolState extends State<AddSchool> {
  final schoolData = {};

  final formKey = GlobalKey<FormState>();

  final fbDB = FirebaseDatabase.instance;

  final fbAuth = FirebaseAuth.instance;

  bool isLoading = false;

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    final ref = fbDB.reference();
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.arrow_back_ios),
                            ),
                            Text(
                              "Add School",
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          onSaved: (newValue) =>
                              schoolData["schoolName"] = newValue.toString(),
                          validator: (value) {
                            return value != null
                                ? value.length >= 8
                                    ? null
                                    : "Invalid School Name"
                                : null;
                          },
                          decoration: InputDecoration(labelText: "School Name"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          onSaved: (newValue) => schoolData["schoolLocation"] =
                              newValue.toString(),
                          validator: (value) {
                            return value != null
                                ? value.length >= 4
                                    ? null
                                    : "Invalid School Location"
                                : null;
                          },
                          decoration:
                              InputDecoration(labelText: "School Location"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          onSaved: (newValue) =>
                              schoolData["schoolContact"] = newValue.toString(),
                          validator: (value) {
                            return value != null
                                ? value.length == 10
                                    ? null
                                    : "Contact must have 10 digits"
                                : null;
                          },
                          decoration:
                              InputDecoration(labelText: "School Contact"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          onSaved: (newValue) =>
                              schoolData["studentCount"] = newValue.toString(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return value != null
                                ? isNumeric(value)
                                    ? null
                                    : "Invalid Count"
                                : null;
                          },
                          decoration:
                              InputDecoration(labelText: "Student Count"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              formKey.currentState!.save();
                              final schoolName = schoolData['schoolName'];
                              schoolData.remove('schoolName');
                              await ref
                                  .child("schools/$schoolName/")
                                  .set(schoolData);

                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: Text("Add School"),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
