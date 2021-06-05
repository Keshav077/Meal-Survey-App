import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentRegistrationForm extends StatefulWidget {
  StudentRegistrationForm({Key? key}) : super(key: key);

  @override
  _StudentRegistrationFormState createState() =>
      _StudentRegistrationFormState();
}

class _StudentRegistrationFormState extends State<StudentRegistrationForm> {
  final formKey = GlobalKey<FormState>();
  final fbDB = FirebaseDatabase.instance;

  final Map<String, String> userData = {};
  bool _isLoading = false;
  List schools = [];

  bool error = false;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    final snap =
        await FirebaseDatabase.instance.reference().child('schools/').once();
    snap.value.keys.forEach((val) {
      schools.add(val);
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = fbDB.reference();
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  onSaved: (newValue) => userData["name"] = newValue.toString(),
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
                DropdownButtonFormField(
                  hint: Text("School"),
                  validator: (value) =>
                      value != null ? null : "Select your school",
                  onChanged: (value) {
                    userData["school"] = value.toString();
                    print(userData);
                  },
                  onSaved: (value) => userData["school"] = value.toString(),
                  items: schools.map((e) {
                    print(e);
                    return DropdownMenuItem(
                      child: Text(e),
                      value: e,
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onSaved: (newValue) =>
                      userData["email"] = newValue.toString(),
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
                  onSaved: (newValue) =>
                      userData["password"] = newValue.toString(),
                  validator: (value) {
                    return value != null
                        ? value.length >= 8
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
                      userData["confirmPassword"] = newValue.toString(),
                  validator: (value) {
                    return value != null
                        ? value.length >= 8
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
                      if (userData['password'] != userData['confirmPassword'])
                        setState(() {
                          error = true;
                        });
                      else {
                        // Firebase logic for registration and storing user data

                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: userData['email'].toString(),
                                password: userData['password'].toString());
                        userData.remove("password");
                        userData.remove("confirmPassword");
                        userData['status'] = 'created';
                        userData['userType'] = 'Student';
                        ref
                            .child(
                                "users/${FirebaseAuth.instance.currentUser!.uid}")
                            .set(userData);
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
