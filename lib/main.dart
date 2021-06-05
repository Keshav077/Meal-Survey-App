import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meal_survey/screens/AdminScreen.dart';
import 'package:meal_survey/screens/GovtHomeScreen.dart';
import 'package:meal_survey/screens/StudentHomeScreen.dart';
import 'package:meal_survey/screens/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          inputDecorationTheme: InputDecorationTheme(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(40))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(
                Size(double.infinity, 50),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ),
        // home: AdminScreen(),
        home: StreamBuilder(
          stream:
              FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
            final snap = await FirebaseDatabase.instance
                .reference()
                .child("users/${user!.uid}/userType")
                .once();
            return snap.value;
          }),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            else {
              if (snapshot.hasData) {
                if (snapshot.data.toString() == 'Student')
                  return StudentHomeScreen();
                else if (snapshot.data.toString() == 'Admin')
                  return AdminScreen();
                return GovtHomeScreen();
              }
              return SignInScreen();
            }
          },
        )
        // SignInScreen(),
        );
  }
}
