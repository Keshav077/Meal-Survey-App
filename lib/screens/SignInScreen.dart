import 'package:flutter/material.dart';
import '../widgets/GovtForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/StudentForm.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  bool showSignIn = true;
  String userType = "Select User Type";

  Map<String, String> userData = {};

  @override
  Widget build(BuildContext context) {
    final testStyle = TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(25),
        child: Form(
          key: formKey,
          child: ListView(
            children: !showSignIn
                ? [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Register",
                          style: testStyle,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    DropdownButtonFormField(
                      items: [
                        DropdownMenuItem(
                          child: Text("Select User Type"),
                          value: "Select User Type",
                        ),
                        DropdownMenuItem(
                          child: Text("Student"),
                          value: "Student",
                        ),
                        DropdownMenuItem(
                          child: Text("Govt. Inspector"),
                          value: "Govt. Inspector",
                        )
                      ],
                      isExpanded: true,
                      value: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value.toString();
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (userType == "Student") StudentRegistrationForm(),
                    if (userType == "Govt. Inspector") GovtRegistrationForm(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showSignIn = true;
                          userType = "Select User Type";
                        });
                      },
                      child: Text("Already registered? Login."),
                    ),
                  ]
                : [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "LOGIN",
                          style: testStyle,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
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
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(
                      height: 30,
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
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Login"),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: userData['email'].toString(),
                                          password:
                                              userData['password'].toString());
                                } on FirebaseAuthException catch (error) {
                                  String errorMessage;
                                  print(error.code);
                                  switch (error.code) {
                                    case "invalid-email":
                                      errorMessage =
                                          "Your email address appears to be malformed.";
                                      break;
                                    case "wrong-password":
                                      errorMessage = "Your password is wrong.";
                                      break;
                                    case "user-not-found":
                                      errorMessage =
                                          "User with this email doesn't exist.";
                                      break;

                                    default:
                                      errorMessage =
                                          "Something went wrong please try again!";
                                  }
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Register"),
                            onPressed: () {
                              setState(() {
                                showSignIn = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
