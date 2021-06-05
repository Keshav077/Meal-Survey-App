import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meal_survey/widgets/MenuButton.dart';
import 'package:timer_builder/timer_builder.dart';

import 'package:flutter/material.dart';
import 'package:meal_survey/Services/studentService.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String name = '';
  final fbDB = FirebaseDatabase.instance;
  final fbAuth = FirebaseAuth.instance;
  bool _isLoading = false;
  String status = 'created';

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    final snap =
        await fbDB.reference().child("users/${fbAuth.currentUser!.uid}").once();
    name = snap.value['name'];
    status = snap.value['status'];
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = fbDB.reference();
    final today = DateTime.now();
    final month = DateTimeFormat.format(today, format: "M"),
        date = DateTimeFormat.format(today, format: "d");
    final mqs = MediaQuery.of(context).size;
    final todayMenu =
        StudentServices.weekScheduleList[today.weekday - 1].split(", ");
    Map<String, bool> selected = {};
    for (int i = 0; i < todayMenu.length; i++) {
      selected[todayMenu[i]] = false;
    }

    return Container(
      color: Colors.white,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Scaffold(
                body: status == 'created'
                    ? NotVerified(
                        fbAuth: fbAuth,
                        name: name,
                      )
                    : status == 'rejected'
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                    "Your request has been rejected by the Admin"),
                                TextButton(
                                  onPressed: () {
                                    fbAuth.signOut();
                                  },
                                  child: Text("Go back"),
                                )
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            fbAuth.signOut();
                                          },
                                          icon: Icon(Icons.logout),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Hello"),
                                    Text(
                                      name,
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    TimerBuilder.periodic(Duration(days: 1),
                                        builder: (ctx) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.all(20),
                                        height: mqs.height * 0.15,
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TimerBuilder.periodic(
                                                Duration(seconds: 1),
                                                builder: (ctx2) {
                                              return AutoSizeText(
                                                DateTimeFormat.format(
                                                    DateTime.now(),
                                                    format: "H:i:s A"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 60),
                                              );
                                            }),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AutoSizeText(
                                                  DateTimeFormat.format(
                                                      DateTime.now(),
                                                      format: "l, d F Y"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    AutoSizeText(
                                      "Today's Menu",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 25),
                                    ),
                                    TimerBuilder.periodic(
                                      Duration(days: 1),
                                      builder: (ctx) {
                                        return Column(
                                          children: todayMenu
                                              .map(
                                                (e) => Container(
                                                  margin: EdgeInsets.all(15),
                                                  alignment: Alignment.center,
                                                  child: MenuButton(
                                                    menuItem: e,
                                                    mqs: mqs,
                                                    selected: selected,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          String school;
                                          final snap = await ref
                                              .child(
                                                  "users/${fbAuth.currentUser!.uid}/school")
                                              .once();
                                          school = snap.value;
                                          await ref
                                              .child(
                                                  "schools/$school/reportedData/$month/$date/${FirebaseAuth.instance.currentUser!.uid}")
                                              .set(selected);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        },
                                        child: Text("Submit"),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
              ),
            ),
    );
  }
}

class NotVerified extends StatelessWidget {
  const NotVerified({
    Key? key,
    required this.name,
    required this.fbAuth,
  }) : super(key: key);

  final String name;
  final FirebaseAuth fbAuth;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(
          "Hello,",
          minFontSize: 17,
          maxLines: 2,
        ),
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          name,
          minFontSize: 25,
          maxLines: 2,
        ),
        SizedBox(
          height: 10,
        ),
        AutoSizeText(
          "Your acount is being verified by the admin",
          minFontSize: 20,
          maxLines: 2,
        ),
        TextButton(
          onPressed: () {
            fbAuth.signOut();
          },
          child: Text("Logout"),
        )
      ],
    ));
  }
}
