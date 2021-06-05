import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GovtRegistrationForm extends StatefulWidget {
  GovtRegistrationForm({Key? key}) : super(key: key);

  @override
  _GovtRegistrationFormState createState() => _GovtRegistrationFormState();
}

class _GovtRegistrationFormState extends State<GovtRegistrationForm> {
  final formKey = GlobalKey<FormState>();
  final fbDB = FirebaseDatabase.instance;
  final fbAuth = FirebaseAuth.instance;

  final Map<String, String> govtData = {};

  bool error = false;

  @override
  Widget build(BuildContext context) {
    final ref = fbDB.reference();
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: (newValue) => govtData["name"] = newValue.toString(),
            validator: (value) {
              return value != null
                  ? value.length >= 3
                      ? null
                      : "Invalid Name"
                  : null;
            },
            decoration: InputDecoration(
              labelText: "Name",
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            onSaved: (newValue) => govtData["officialId"] = newValue.toString(),
            validator: (value) {
              return value != null
                  ? value.length >= 3
                      ? null
                      : "Invalid Id"
                  : null;
            },
            decoration: InputDecoration(
              labelText: "Official Id",
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            onSaved: (newValue) => govtData["location"] = newValue.toString(),
            validator: (value) {
              return value != null
                  ? value.length >= 3
                      ? null
                      : "Invalid Location"
                  : null;
            },
            decoration: InputDecoration(
              labelText: "Location",
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            onSaved: (newValue) => govtData["email"] = newValue.toString(),
            validator: (value) {
              return value != null
                  ? value.contains("@")
                      ? null
                      : "Invalid Email"
                  : null;
            },
            decoration: InputDecoration(
              labelText: "Email",
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            obscureText: true,
            onSaved: (newValue) => govtData["password"] = newValue.toString(),
            validator: (value) {
              return value != null
                  ? value.length >= 3
                      ? null
                      : "Password Must Contain Atleast 8 Characters"
                  : null;
            },
            decoration: InputDecoration(
              labelText: "Password",
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            obscureText: true,
            onSaved: (newValue) =>
                govtData["confirmPassword"] = newValue.toString(),
            validator: (value) {
              return value != null
                  ? value.length >= 3
                      ? null
                      : "Password Must Contain Atleast 8 Characters"
                  : null;
            },
            decoration: InputDecoration(
              labelText: "Confirm Password",
            ),
          ),
          if (error)
            Text(
              "Password doesn't match",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                if (govtData['password'] != govtData['confirmPassword'])
                  setState(() {
                    error = true;
                  });
                else {
                  // Firebase logic for registration and storing user data
                  UserCredential userCredential =
                      await fbAuth.createUserWithEmailAndPassword(
                          email: govtData['email'].toString(),
                          password: govtData['password'].toString());
                  print(govtData);
                  govtData.remove("password");
                  govtData.remove("confirmPassword");
                  govtData['userType'] = 'Govt Official';
                  govtData['status'] = 'created';
                  await ref
                      .child("users/${userCredential.user!.uid}")
                      .set(govtData);
                  if (mounted)
                    setState(() {
                      error = false;
                    });
                }
              }
            },
            child: Text("Register"),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
